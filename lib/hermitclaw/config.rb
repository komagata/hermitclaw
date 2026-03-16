# frozen_string_literal: true

require "yaml"
require "dotenv"

module HermitClaw
  class Config
    attr_reader :data

    def initialize(path = "config.yml")
      Dotenv.load
      @data = YAML.load_file(path)
    end

    def llm_provider = data.dig("llm", "provider") || "anthropic"
    def llm_model = data.dig("llm", "model") || "claude-sonnet-4-20250514"
    def soul_path = data["soul"] || "SOUL.md"
    def db_path = data.dig("memory", "database") || "db/hermitclaw.sqlite3"
    def discord_token = ENV["DISCORD_BOT_TOKEN"]
    def anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
  end
end
