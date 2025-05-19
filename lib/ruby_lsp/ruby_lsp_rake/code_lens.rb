# typed: true
# frozen_string_literal: true

module RubyLsp
  module Rake
    class CodeLens
      extend T::Sig
      include Requests::Support::Common

      #: (ResponseBuilders::CollectionResponseBuilder response_builder, URI::Generic uri, Prism::Dispatcher dispatcher) -> void
      def initialize(response_builder, uri, dispatcher)
        @response_builder = response_builder
        @path = T.let(T.unsafe(uri).to_standardized_path, T.nilable(String))
        @namespace_stack = []

        dispatcher.register(self, :on_call_node_enter, :on_call_node_leave)
      end

      #: (Prism::CallNode node) -> void
      def on_call_node_enter(node) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        return unless node.receiver.nil?
        return unless %i[task namespace].include? node.name

        arguments = node.arguments&.arguments
        return unless arguments

        arg = arguments.first
        name = case arg
               when Prism::StringNode
                 arg.content
               when Prism::SymbolNode
                 arg.value
               when Prism::KeywordHashNode
                 kh = arg.child_nodes.first
                 case kh
                 when Prism::AssocNode
                   k = kh.key
                   case k
                   when Prism::StringNode
                     k.content
                   when Prism::SymbolNode
                     k.value
                   end
                 end
               end

        return if name.nil?

        if node.name == :namespace
          @namespace_stack << name
          return
        end

        task_name = [*@namespace_stack, name].join(":")

        @response_builder << create_code_lens(
          node,
          title: "▶ Run In Terminal",
          command_name: "rubyLsp.runTestInTerminal",
          arguments: [
            @path,
            task_name,
            "rake #{task_name}",
            {
              start_line: node.location.start_line - 1,
              start_column: node.location.start_column,
              end_line: node.location.end_line - 1,
              end_column: node.location.end_column
            }
          ],
          data: { type: "rake" }
        )
      end

      #: (Prism::CallNode node) -> void
      def on_call_node_leave(node)
        return unless node.name == :namespace

        @namespace_stack.pop
      end
    end
  end
end
