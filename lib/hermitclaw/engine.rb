# frozen_string_literal: true

module HermitClaw
  class Engine
    def initialize(config_path: "config.yml")
      @config = Config.new(config_path)
      @logger = AppLogger.build(@config.data)
      @soul = Memory::Soul.new(@config.soul_path)
      @shared = Memory::Shared.new(@config.shared_memory_path)
      @user_memory = Memory::User.new(@config.db_path)
      @guardrails = Guardrails.new(config: @config)
      @agent = Agent.new(
        config: @config, soul: @soul, shared: @shared,
        user_memory: @user_memory, guardrails: @guardrails
      )
    end

    def start
      puts "🐚 Starting HermitClaw v#{VERSION}..."
      @logger.info("Starting HermitClaw v#{VERSION}")

      @scheduler = Scheduler.new(config: @config)
      @scheduler.start

      # Start webhook server if configured
      if @config.data.dig("channels", "webhook")
        @webhook = Channels::Webhook.new(
          agent: @agent, config: @config.data, logger: @logger
        )
        @webhook.start
      end

      # Start Discord bot (blocking)
      if @config.discord_token && !@config.discord_token.empty?
        discord = Channels::Discord.new(
          token: @config.discord_token, agent: @agent, logger: @logger
        )
        discord.start
      else
        # No Discord, keep process alive for webhook
        puts "🐚 Running in webhook-only mode"
        sleep
      end
    end
  end
end
