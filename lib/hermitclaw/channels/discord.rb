# frozen_string_literal: true

require "discordrb"

module HermitClaw
  module Channels
    class Discord
      DISCORD_MAX_LENGTH = 2000

      def initialize(token:, agent:, logger: nil)
        @bot = Discordrb::Bot.new(
          token: token,
          intents: %i[server_messages server_message_reactions direct_messages]
        )
        @agent = agent
        @logger = logger
      end

      def start
        @bot.mention do |event|
          content = strip_mentions(event.message.content)
          next if content.strip.empty?

          user = event.user.username
          channel = event.channel.name

          @logger&.info("IN  [##{channel}] @#{user}: #{content}")

          event.channel.start_typing

          response = @agent.respond(
            user_id: event.user.id,
            message: content
          )

          @logger&.info("OUT [##{channel}] → @#{user}: #{response[0..200]}#{"..." if response.length > 200}")

          send_split(event, response)
        end

        puts "🐚 HermitClaw is online (Discord)"
        @bot.run
      end

      def stop
        @bot.stop
      end

      private

      def strip_mentions(text)
        text.gsub(/<@!?\d+>/, "").strip
      end

      def send_split(event, text)
        chunks = text.scan(/.{1,#{DISCORD_MAX_LENGTH}}/m)
        chunks.each { |chunk| event.respond(chunk) }
      end
    end
  end
end
