# typed: true
# frozen_string_literal: true

require "ruby_lsp/addon"
require_relative "indexing_enhancement"
require_relative "hover"

module RubyLsp
  module Rake
    class Addon < ::RubyLsp::Addon # rubocop:disable Style/Documentation
      def activate(global_state, _message_queue)
        @index = global_state.index
        @index.configuration.apply_config({ "included_patterns" => ["**/Rakefile", "lib/../Rakefile"] })
      end

      def deactivate; end

      def name
        "A Ruby LSP addon that adds extra editor functionality for Rake"
      end

      def version
        ::Ruby::Lsp::Rake::VERSION
      end

      def create_hover_listener(response_builder, node_context, dispatcher)
        Hover.new(response_builder, node_context, dispatcher, @index)
      end
    end
  end
end
