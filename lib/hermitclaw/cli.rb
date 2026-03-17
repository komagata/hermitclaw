# frozen_string_literal: true

require_relative '../hermitclaw'

module HermitClaw
  module CLI
    TEMPLATES_DIR = File.expand_path('../../templates', __dir__)
    PID_FILE = 'tmp/hermitclaw.pid'

    def self.run(args)
      command = args.first

      case command
      when 'init'
        init(args[1])
      when 'start'
        start
      when 'stop'
        stop
      when 'status'
        status
      when 'version', '-v', '--version'
        puts "hermitclaw #{HermitClaw::VERSION}"
      else
        usage
      end
    end

    def self.init(dir = '.')
      dir ||= '.'
      target = File.expand_path(dir)
      FileUtils.mkdir_p(target)

      files = {
        'config.yml' => 'config.yml',
        'SOUL.md' => 'SOUL.md',
        'SHARED_MEMORY.md' => 'SHARED_MEMORY.md',
        '.env' => 'env',
        '.gitignore' => 'gitignore'
      }

      files.each do |dest_name, template_name|
        dest = File.join(target, dest_name)
        if File.exist?(dest)
          puts "  skip  #{dest_name} (already exists)"
        else
          src = File.join(TEMPLATES_DIR, template_name)
          FileUtils.cp(src, dest)
          puts "  create  #{dest_name}"
        end
      end

      puts
      puts '🐚 HermitClaw initialized!'
      puts
      puts 'Next steps:'
      puts '  1. Edit SOUL.md to define your character'
      puts '  2. Edit .env to set your API keys'
      puts '  3. Run: hermitclaw start'
    end

    def self.start
      unless File.exist?('config.yml')
        warn 'Error: config.yml not found. Run `hermitclaw init` first.'
        exit 1
      end

      write_pid
      at_exit { remove_pid }

      Signal.trap('INT') { exit }
      Signal.trap('TERM') { exit }

      Engine.new.start
    end

    def self.stop
      pid = read_pid
      unless pid
        warn 'HermitClaw is not running (no PID file found).'
        exit 1
      end

      begin
        Process.kill('TERM', pid)
        puts "🐚 HermitClaw stopped (PID: #{pid})"
        remove_pid
      rescue Errno::ESRCH
        warn "Process #{pid} not found. Removing stale PID file."
        remove_pid
      rescue Errno::EPERM
        warn "Permission denied to stop process #{pid}."
        exit 1
      end
    end

    def self.status
      pid = read_pid
      unless pid
        puts '🐚 HermitClaw is not running.'
        return
      end

      begin
        Process.kill(0, pid)
        puts "🐚 HermitClaw is running (PID: #{pid})"
      rescue Errno::ESRCH
        puts '🐚 HermitClaw is not running (stale PID file).'
        remove_pid
      rescue Errno::EPERM
        puts "🐚 HermitClaw is running (PID: #{pid}, different user)"
      end
    end

    def self.usage
      puts <<~USAGE
        Usage: hermitclaw <command>

        Commands:
          init [dir]   Create a new HermitClaw project
          start        Start the bot (requires config.yml)
          stop         Stop the running bot
          status       Show whether the bot is running
          version      Show version

      USAGE
    end

    def self.write_pid
      FileUtils.mkdir_p(File.dirname(PID_FILE))
      File.write(PID_FILE, Process.pid.to_s)
    end

    def self.read_pid
      return nil unless File.exist?(PID_FILE)

      pid = File.read(PID_FILE).strip.to_i
      pid.positive? ? pid : nil
    end

    def self.remove_pid
      FileUtils.rm_f(PID_FILE)
    end

    private_class_method :write_pid, :read_pid, :remove_pid
  end
end
