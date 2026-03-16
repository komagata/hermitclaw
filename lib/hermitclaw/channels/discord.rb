# frozen_string_literal: true

require "discordrb"

module HermitClaw
  module Channels
    class Discord
      def initialize(token:, agent:)
        @bot = Discordrb::Bot.new(
          token: token,
          intents: %i[server_messages server_message_reactions direct_messages]
        )
        @agent = agent
      end

      def start
        @bot.mention do |event|
          content = strip_mentions(event.message.content)
          next if content.strip.empty?

          event.channel.start_typing

          response = @agent.respond(
            user_id: event.user.id,
            message: content
          )

          event.respond(response)
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
    end
  end
end
