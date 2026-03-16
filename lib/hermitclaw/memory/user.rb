# frozen_string_literal: true

require "sqlite3"
require "json"
require "fileutils"

module HermitClaw
  module Memory
    class User
      MAX_HISTORY = 20

      def initialize(db_path)
        FileUtils.mkdir_p(File.dirname(db_path))
        @db = SQLite3::Database.new(db_path)
        setup_schema
      end

      def history(user_id)
        rows = @db.execute(<<~SQL, [user_id.to_s, MAX_HISTORY])
          SELECT role, content FROM messages
          WHERE user_id = ?
          ORDER BY created_at DESC
          LIMIT ?
        SQL
        rows.reverse.map { |role, content| { role: role, content: content } }
      end

      def store(user_id, role, content)
        @db.execute(<<~SQL, [user_id.to_s, role, content])
          INSERT INTO messages (user_id, role, content, created_at)
          VALUES (?, ?, ?, datetime('now'))
        SQL
      end

      private

      def setup_schema
        @db.execute(<<~SQL)
          CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at DATETIME NOT NULL
          )
        SQL
        @db.execute(<<~SQL)
          CREATE INDEX IF NOT EXISTS idx_messages_user_id
          ON messages (user_id, created_at)
        SQL
      end
    end
  end
end
