# frozen_string_literal: true

require 'rufus-scheduler'

module HermitClaw
  class Scheduler
    def initialize(config:)
      @config = config
      @scheduler = Rufus::Scheduler.new
      @jobs = []
    end

    def register(name, interval, &)
      job = @scheduler.every(interval, name: name, &)
      @jobs << job
      puts "📅 Scheduled: #{name} (every #{interval})"
    end

    def start
      # Scheduler runs in background threads automatically
    end

    def stop
      @scheduler.shutdown
    end
  end
end
