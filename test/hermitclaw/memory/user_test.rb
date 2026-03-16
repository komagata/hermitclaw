# frozen_string_literal: true

require "test_helper"

class UserMemoryTest < Minitest::Test
  def setup
    @db_path = File.join(TMP_DIR, "user_test_#{object_id}.sqlite3")
    FileUtils.rm_f(@db_path)
    @memory = HermitClaw::Memory::User.new(@db_path)
  end

  def test_store_and_retrieve
    @memory.store("user1", "user", "hello")
    @memory.store("user1", "assistant", "hi there")

    history = @memory.history("user1")

    assert_equal 2, history.length
    assert_equal "user", history.first[:role]
    assert_equal "hello", history.first[:content]
    assert_equal "assistant", history.last[:role]
    assert_equal "hi there", history.last[:content]
  end

  def test_isolates_users
    @memory.store("user1", "user", "hello")
    @memory.store("user2", "user", "world")

    assert_equal 1, @memory.history("user1").length
    assert_equal 1, @memory.history("user2").length
    assert_equal "hello", @memory.history("user1").first[:content]
    assert_equal "world", @memory.history("user2").first[:content]
  end

  def test_max_history_limit
    25.times { |i| @memory.store("user1", "user", "msg #{i}") }

    history = @memory.history("user1")

    assert_equal 20, history.length
    assert_equal "msg 5", history.first[:content]
    assert_equal "msg 24", history.last[:content]
  end

  def test_preserves_order
    @memory.store("user1", "user", "first")
    @memory.store("user1", "assistant", "second")
    @memory.store("user1", "user", "third")

    history = @memory.history("user1")

    assert_equal %w[first second third], history.map { |m| m[:content] }
  end
end
