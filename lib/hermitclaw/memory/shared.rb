# frozen_string_literal: true

module HermitClaw
  module Memory
    class Shared
      def initialize(path)
        @path = path
        @content = File.exist?(path) ? File.read(path) : ''
      end

      def to_s = @content
      def empty? = @content.strip.empty?
    end
  end
end
