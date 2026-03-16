# frozen_string_literal: true

require "open3"
require "timeout"

module HermitClaw
  module Sandbox
    class Process < Base
      def available?
        true # Always available as fallback
      end

      def execute(command:, timeout: 30, env: {})
        output = nil
        error = nil
        status = nil

        Timeout.timeout(timeout) do
          output, error, status = Open3.capture3(env, command)
        end

        {
          stdout: output,
          stderr: error,
          success: status.success?,
          exit_code: status.exitstatus
        }
      rescue Timeout::Error
        { stdout: "", stderr: "Execution timed out after #{timeout}s", success: false, exit_code: -1 }
      rescue => e
        { stdout: "", stderr: e.message, success: false, exit_code: -1 }
      end
    end
  end
end
