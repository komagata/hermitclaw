# frozen_string_literal: true

module HermitClaw
  class Engine
    def initialize(config_path: "config.yml")
      @config = Config.new(config_path)
      @soul = Memory::Soul.new(@config.soul_path)
      @shared = Memory::Shared.new(@config.shared_memory_path)
      @user_memory = Memory::User.new(@config.db_path)
      @agent = Agent.new(config: @config, soul: @soul, shared: @shared, user_memory: @user_memory)
      @scheduler = Scheduler.new(config: @config)
    end

    def start
      puts "🐚 Starting HermitClaw v#{VERSION}..."

      @scheduler.start

      discord = Channels::Discord.new(token: @config.discord_token, agent: @agent)
      discord.start
    end
  end
end
