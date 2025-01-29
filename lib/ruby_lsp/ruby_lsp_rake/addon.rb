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
    class Addon < ::RubyLsp::Addon # rubocop:disable Style/Documentation
      extend T::Sig

      sig { override.params(global_state: GlobalState, outgoing_queue: Thread::Queue).void }
      def activate(global_state, outgoing_queue) # rubocop:disable Lint/UnusedMethodArgument
        @index = global_state.index
        @index.configuration.apply_config({ "included_patterns" => ["**/Rakefile", "lib/../Rakefile"] })
      end

      sig { override.void }
      def deactivate; end

      sig { override.returns(String) }
      def name
        "A Ruby LSP addon that adds extra editor functionality for Rake"
      end

      sig { override.returns(String) }
      def version
        ::RubyLsp::Rake::VERSION
      end

      sig do
        override.params(
          response_builder: ResponseBuilders::Hover,
          node_context: NodeContext,
          dispatcher: Prism::Dispatcher
        ).void
      end
      def create_hover_listener(response_builder, node_context, dispatcher)
        Hover.new(response_builder, node_context, dispatcher, @index)
      end

      sig do
        override.params(
          response_builder: ResponseBuilders::CollectionResponseBuilder[T.any(
            Interface::Location, Interface::LocationLink
          )],
          _uri: URI::Generic,
          node_context: NodeContext,
          dispatcher: Prism::Dispatcher
        ).void
      end
      def create_definition_listener(response_builder, _uri, node_context, dispatcher)
        Definition.new(response_builder, node_context, @index, dispatcher)
      end

      sig do
        override.params(
          response_builder: ResponseBuilders::CollectionResponseBuilder[Interface::CodeLens],
          uri: URI::Generic,
          dispatcher: Prism::Dispatcher
        ).void
      end
      def create_code_lens_listener(response_builder, uri, dispatcher)
        CodeLens.new(response_builder, uri, dispatcher)
      end
    end
  end
end
