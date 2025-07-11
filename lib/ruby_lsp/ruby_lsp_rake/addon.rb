# typed: true
# frozen_string_literal: true

require "ruby_lsp/addon"
require_relative "../../ruby_lsp_rake/version"
require_relative "indexing_enhancement"
require_relative "hover"
require_relative "definition"
require_relative "code_lens"

module RubyLsp
  module Rake
    class Addon < ::RubyLsp::Addon
      # @override
      #: (GlobalState global_state, Thread::Queue outgoing_queue) -> void
      def activate(global_state, outgoing_queue)
        @index = global_state.index
        @index.configuration.apply_config({ "included_patterns" => ["**/Rakefile", "lib/../Rakefile"] })

        outgoing_queue << Notification.window_log_message("Activated Ruby LSP Rake")
      end

      # @override
      #: -> void
      def deactivate; end

      # @override
      #: -> String
      def name
        "A Ruby LSP addon that adds extra editor functionality for Rake"
      end

      # @override
      #: -> String
      def version
        ::RubyLsp::Rake::VERSION
      end

      # @override
      #: (ResponseBuilders::Hover response_builder, NodeContext node_context, Prism::Dispatcher dispatcher) -> void
      def create_hover_listener(response_builder, node_context, dispatcher)
        Hover.new(response_builder, node_context, dispatcher, @index)
      end

      # @override
      #: (ResponseBuilders::CollectionResponseBuilder response_builder, URI::Generic _uri, NodeContext node_context, Prism::Dispatcher dispatcher) -> void
      def create_definition_listener(response_builder, _uri, node_context, dispatcher)
        Definition.new(response_builder, node_context, @index, dispatcher)
      end

      # @override
      #: (ResponseBuilders::CollectionResponseBuilder response_builder, URI::Generic uri, Prism::Dispatcher dispatcher) -> void
      def create_code_lens_listener(response_builder, uri, dispatcher)
        CodeLens.new(response_builder, uri, dispatcher)
      end
    end
  end
end
