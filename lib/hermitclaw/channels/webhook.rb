# frozen_string_literal: true

require "webrick"
require "json"

module HermitClaw
  module Channels
    class Webhook
      def initialize(agent:, config:, logger: nil)
        @agent = agent
        @config = config
        @logger = logger
        @port = config.dig("channels", "webhook", "port") || 4567
        @token = ENV["HERMITCLAW_WEBHOOK_TOKEN"]
      end

      def start
        @server = WEBrick::HTTPServer.new(
          Port: @port,
          Logger: WEBrick::Log.new("/dev/null"),
          AccessLog: []
        )

        @server.mount_proc "/webhook" do |req, res|
          handle_webhook(req, res)
        end

        @server.mount_proc "/health" do |_req, res|
          res.content_type = "application/json"
          res.body = { status: "ok", version: HermitClaw::VERSION }.to_json
        end

        puts "🌐 Webhook server listening on port #{@port}"
        @logger&.info("Webhook server started on port #{@port}")

        Thread.new { @server.start }
      end

      def stop
        @server&.shutdown
      end

      private

      def handle_webhook(req, res)
        res.content_type = "application/json"

        unless req.request_method == "POST"
          res.status = 405
          res.body = { error: "Method not allowed" }.to_json
          return
        end

        unless authorized?(req)
          res.status = 401
          res.body = { error: "Unauthorized" }.to_json
          @logger&.warn("Webhook: unauthorized request from #{req.peeraddr[2]}")
          return
        end

        body = JSON.parse(req.body)
        user_id = body["user_id"] || "webhook-anonymous"
        message = body["message"]
        metadata = body["metadata"] || {}

        unless message && !message.strip.empty?
          res.status = 400
          res.body = { error: "Missing 'message' field" }.to_json
          return
        end

        @logger&.info("WEBHOOK IN [#{metadata["source"] || "unknown"}] @#{user_id}: #{message}")

        response = @agent.respond(user_id: "webhook:#{user_id}", message: message)

        @logger&.info("WEBHOOK OUT → @#{user_id}: #{response[0..200]}#{"..." if response.length > 200}")

        res.status = 200
        res.body = {
          response: response,
          user_id: user_id,
          metadata: metadata
        }.to_json
      rescue JSON::ParserError
        res.status = 400
        res.body = { error: "Invalid JSON" }.to_json
      rescue => e
        $stderr.puts "Webhook error: #{e.class} #{e.message}"
        @logger&.error("Webhook error: #{e.class} #{e.message}")
        res.status = 500
        res.body = { error: "Internal server error" }.to_json
      end

      def authorized?(req)
        return true unless @token

        auth = req["Authorization"]
        auth == "Bearer #{@token}"
      end
    end
  end
end
