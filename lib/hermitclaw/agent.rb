# frozen_string_literal: true

require "ruby_llm"

module HermitClaw
  class Agent
    def initialize(config:, soul:, shared:, user_memory:)
      @config = config
      @soul = soul
      @shared = shared
      @user_memory = user_memory

      RubyLLM.configure do |c|
        c.anthropic_api_key = config.anthropic_api_key
      end
    end

    def respond(user_id:, message:)
      @user_memory.store(user_id, "user", message)
      history = @user_memory.history(user_id)

      chat = RubyLLM.chat(model: @config.llm_model)
      chat.with_instructions(system_prompt)

      # Replay history to build context
      history[0..-2].each do |msg|
        chat.add_message(role: msg[:role], content: msg[:content])
      end

      # Ask the latest message
      response = chat.ask(history.last[:content])
      content = response.content || "..."

      @user_memory.store(user_id, "assistant", content)
      content
    rescue => e
      $stderr.puts "Error: #{e.class} #{e.message}"
      "Error: #{e.class} #{e.message}"[0..3999]
    end

    private

    def system_prompt
      parts = [@soul.to_s]
      unless @shared.empty?
        parts << "\n## Shared Knowledge\n\n#{@shared}"
      end
      parts.join("\n")
    end
  end
end
