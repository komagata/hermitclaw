# frozen_string_literal: true

require 'test_helper'

class ConfigTest < Minitest::Test
  def test_loads_config_file
    path = File.join(TMP_DIR, 'config.yml')
    File.write(path, <<~YAML)
      llm:
        provider: anthropic
        model: claude-sonnet-4-20250514
      soul: SOUL.md
      memory:
        database: db/test.sqlite3
        shared: SHARED_MEMORY.md
    YAML

    config = HermitClaw::Config.new(path)

    assert_equal 'anthropic', config.llm_provider
    assert_equal 'claude-sonnet-4-20250514', config.llm_model
    assert_equal 'SOUL.md', config.soul_path
    assert_equal 'db/test.sqlite3', config.db_path
    assert_equal 'SHARED_MEMORY.md', config.shared_memory_path
  end

  def test_defaults
    path = File.join(TMP_DIR, 'minimal_config.yml')
    File.write(path, "llm:\n  provider: openai\n")

    config = HermitClaw::Config.new(path)

    assert_equal 'openai', config.llm_provider
    assert_equal 'claude-sonnet-4-20250514', config.llm_model
    assert_equal 'SOUL.md', config.soul_path
    assert_equal 'db/hermitclaw.sqlite3', config.db_path
    assert_equal 'SHARED_MEMORY.md', config.shared_memory_path
  end
end
