# frozen_string_literal: true

require "ruby_lsp/addon"
require_relative "indexing_enhancement"
require_relative "hover"

module RubyLsp
  module Rake
    class Addon < ::RubyLsp::Addon # rubocop:disable Style/Documentation
      def activate(global_state, _message_queue)
        @index = global_state.index
      end

      def deactivate; end

      def name
        "Ruby LSP Rake go to task def"
      end

      def version
        "0.1.0"
      end

      def create_hover_listener(response_builder, node_context, dispatcher)
        Hover.new(response_builder, node_context, dispatcher, @index)
      end
    end
  end
end
