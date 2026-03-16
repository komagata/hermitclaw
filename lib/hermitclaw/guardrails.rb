# frozen_string_literal: true

module HermitClaw
  class Guardrails
    def initialize(config:)
      @rules = config.guardrails
    end

    # Check inbound user message before sending to LLM
    def check_input(message)
      return nil unless @rules

      if blocked_patterns.any? { |p| message.match?(p) }
        return "I can't help with that topic. Please ask a human mentor instead."
      end

      nil # nil = message is OK
    end

    # Check outbound LLM response before sending to user
    def check_output(response)
      return response unless @rules

      # Redact anything that looks like a secret
      redacted = response
                 .gsub(/sk-[a-zA-Z0-9\-_]{20,}/, '[REDACTED]')
                 .gsub(/xoxb-[a-zA-Z0-9-]+/, '[REDACTED]')
                 .gsub(/MTQ[a-zA-Z0-9._-]{50,}/, '[REDACTED]')

      # Check max response length
      max_length = @rules['max_response_length']
      redacted = "#{redacted[0...max_length]}\n\n(response truncated)" if max_length && redacted.length > max_length

      redacted
    end

    private

    def blocked_patterns
      patterns = @rules&.dig('blocked_patterns') || []
      patterns.map { |p| Regexp.new(p, Regexp::IGNORECASE) }
    rescue RegexpError => e
      warn "Invalid guardrail pattern: #{e.message}"
      []
    end
  end
end
