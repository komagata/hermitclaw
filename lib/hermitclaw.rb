# frozen_string_literal: true

require_relative "hermitclaw/config"
require_relative "hermitclaw/logger"
require_relative "hermitclaw/memory/soul"
require_relative "hermitclaw/memory/shared"
require_relative "hermitclaw/memory/user"
require_relative "hermitclaw/guardrails"
require_relative "hermitclaw/agent"
require_relative "hermitclaw/channels/discord"
require_relative "hermitclaw/channels/webhook"
require_relative "hermitclaw/scheduler"
require_relative "hermitclaw/engine"

module HermitClaw
  VERSION = "0.1.0"
end
