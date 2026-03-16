# frozen_string_literal: true

module HermitClaw
  module Sandbox
    class Base
      def execute(command:, timeout: 30)
        raise NotImplementedError
      end

      def available?
        raise NotImplementedError
      end
    end
  end
end
