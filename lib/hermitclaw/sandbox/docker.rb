# frozen_string_literal: true

require "open3"
require "json"
require "timeout"

module HermitClaw
  module Sandbox
    class Docker < Base
      IMAGE = "hermitclaw-sandbox"

      def initialize(config: {})
        @memory_limit = config["memory_limit"] || "128m"
        @cpu_limit = config["cpu_limit"] || "0.5"
        @network = config["network"] || "none"
      end

      def available?
        _, status = Open3.capture2("docker", "info")
        status.success?
      rescue Errno::ENOENT
        false
      end

      def execute(command:, timeout: 30, env: {})
        args = [
          "docker", "run",
          "--rm",
          "--memory=#{@memory_limit}",
          "--cpus=#{@cpu_limit}",
          "--network=#{@network}",
          "--read-only",
          "--no-new-privileges",
          "--cap-drop=ALL",
          "--tmpfs=/tmp:size=10m",
          "--user=nobody",
        ]

        env.each { |k, v| args.push("--env", "#{k}=#{v}") }

        args.push(IMAGE, "sh", "-c", command)

        output = nil
        error = nil
        status = nil

        Timeout.timeout(timeout) do
          output, error, status = Open3.capture3(*args)
        end

        {
          stdout: output,
          stderr: error,
          success: status.success?,
          exit_code: status.exitstatus
        }
      rescue Timeout::Error
        # Kill any running container
        { stdout: "", stderr: "Execution timed out after #{timeout}s", success: false, exit_code: -1 }
      rescue => e
        { stdout: "", stderr: e.message, success: false, exit_code: -1 }
      end

      def self.build_sandbox_image
        dockerfile = <<~DOCKERFILE
          FROM ruby:3.2-slim
          RUN useradd -m sandbox
          USER sandbox
          WORKDIR /sandbox
        DOCKERFILE

        IO.popen(["docker", "build", "-t", IMAGE, "-"], "r+") do |io|
          io.write(dockerfile)
          io.close_write
          io.read
        end
      end
    end
  end
end
