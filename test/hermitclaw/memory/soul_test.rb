# frozen_string_literal: true

require 'test_helper'

class SoulTest < Minitest::Test
  def test_loads_file_content
    path = File.join(TMP_DIR, 'soul.md')
    File.write(path, "# TestBot\nI am a test bot.")

    soul = HermitClaw::Memory::Soul.new(path)

    assert_includes soul.to_s, 'TestBot'
    assert_includes soul.to_s, 'I am a test bot.'
  end
end
