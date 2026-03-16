# frozen_string_literal: true

require_relative 'sandbox/base'
require_relative 'sandbox/docker'
require_relative 'sandbox/process'

module HermitClaw
  module Sandbox
    def self.create(config = {})
      backend = config['backend'] || 'process'

      case backend
      when 'docker'
        docker = Docker.new(config: config)
        if docker.available?
          puts '🐳 Sandbox: Docker'
          docker
        else
          warn '⚠️  Docker not available, falling back to process sandbox'
          Process.new
        end
      when 'process'
        puts '🔧 Sandbox: Process'
        Process.new
      else
        raise "Unknown sandbox backend: #{backend}"
      end
    end
  end
end
