# frozen_string_literal: true

require 'test_helper'

class SharedTest < Minitest::Test
  def test_loads_existing_file
    path = File.join(TMP_DIR, 'shared.md')
    File.write(path, "# Events\nGraduation in March")

    shared = HermitClaw::Memory::Shared.new(path)

    refute_empty shared
    assert_includes shared.to_s, 'Graduation'
  end

  def test_handles_missing_file
    shared = HermitClaw::Memory::Shared.new(File.join(TMP_DIR, 'nonexistent.md'))

    assert_empty shared
  end
end
