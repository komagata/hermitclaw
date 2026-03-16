# frozen_string_literal: true

require "logger"
require "fileutils"

module HermitClaw
  class AppLogger
    def self.build(config = nil)
      log_path = config&.dig("logging", "file") || "log/hermitclaw.log"
      FileUtils.mkdir_p(File.dirname(log_path))

      logger = Logger.new(log_path)
      logger.level = Logger::INFO
      logger.formatter = proc do |severity, datetime, _progname, msg|
        "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
      end
      logger
    end
  end
end
