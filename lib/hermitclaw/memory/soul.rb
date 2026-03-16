# frozen_string_literal: true

module HermitClaw
  module Memory
    class Soul
      def initialize(path)
        @content = File.read(path)
      end

      def to_s = @content
    end
  end
end
