# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module HermitClaw
  class Agent
    API_URL = "https://api.anthropic.com/v1/messages"

    def initialize(config:, soul:, user_memory:)
      @config = config
      @soul = soul
      @user_memory = user_memory
    end

    def respond(user_id:, message:)
      @user_memory.store(user_id, "user", message)
      history = @user_memory.history(user_id)

      messages = history.map { |msg| { role: msg[:role], content: msg[:content] } }

      response = call_anthropic(messages)
      @user_memory.store(user_id, "assistant", response)
      response
    end

    private

    def call_anthropic(messages)
      uri = URI(API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["content-type"] = "application/json"
      request["x-api-key"] = @config.anthropic_api_key
      request["anthropic-version"] = "2023-06-01"

      request.body = {
        model: @config.llm_model,
        max_tokens: 1024,
        system: @soul.to_s,
        messages: messages
      }.to_json

      response = http.request(request)
      body = JSON.parse(response.body)

      if response.code == "200"
        body.dig("content", 0, "text") || "..."
      else
        $stderr.puts "API error: #{response.code} #{body}"
        "API error #{response.code}: #{body.dig("error", "message") || body}"
      end
    rescue => e
      $stderr.puts "Error: #{e.class} #{e.message}"
      "Error: #{e.class} #{e.message}"
    end
  end
end
