# frozen_string_literal: true

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'minitest/autorun'
require 'fileutils'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

ENV['DISCORD_BOT_TOKEN'] ||= 'test-token'
ENV['ANTHROPIC_API_KEY'] ||= 'test-key'

require 'hermitclaw'

TMP_DIR = File.expand_path('../tmp/test', __dir__)
FileUtils.mkdir_p(TMP_DIR)
