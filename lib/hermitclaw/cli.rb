# frozen_string_literal: true

require_relative '../hermitclaw'

module HermitClaw
  module CLI
    TEMPLATES_DIR = File.expand_path('../../templates', __dir__)

    def self.run(args)
      command = args.first

      case command
      when 'init'
        init(args[1])
      when 'start'
        start
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

      Engine.new.start
    end

    def self.usage
      puts <<~USAGE
        Usage: hermitclaw <command>

        Commands:
          init [dir]   Create a new HermitClaw project
          start        Start the bot (requires config.yml)
          version      Show version

      USAGE
    end
  end
end
