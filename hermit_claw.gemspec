# frozen_string_literal: true

require_relative 'lib/hermitclaw'

Gem::Specification.new do |spec|
  spec.name          = 'hermit_claw'
  spec.version       = HermitClaw::VERSION
  spec.authors       = ['komagata']
  spec.email         = ['komagata@gmail.com']

  spec.summary       = 'An AI character that lives in your service'
  spec.description   = 'A Service AI Agent Runtime built in Ruby. ' \
                       'Define a personality in SOUL.md and deploy an AI character ' \
                       'that serves end-users on Discord, Telegram, and webhooks.'
  spec.homepage      = 'https://github.com/komagata/hermitclaw'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.2.0'

  spec.files = Dir.chdir(__dir__) do
    Dir['{lib,templates}/**/*', 'LICENSE', 'README.md']
  end
  spec.bindir        = 'exe'
  spec.executables   = ['hermitclaw']

  spec.add_dependency 'discordrb', '~> 3.7'
  spec.add_dependency 'dotenv', '~> 3.0'
  spec.add_dependency 'ruby_llm', '~> 1.0'
  spec.add_dependency 'rufus-scheduler', '~> 3.9'
  spec.add_dependency 'sqlite3', '~> 2.0'
  spec.add_dependency 'webrick', '~> 1.8'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
end
