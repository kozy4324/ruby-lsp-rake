# typed: true
# frozen_string_literal: true

module RubyLsp
  module Rake
    class Hover # rubocop:disable Style/Documentation
      extend T::Sig
      include Requests::Support::Common

      sig do
        override.params(
          response_builder: ResponseBuilders::Hover,
          node_context: NodeContext,
          dispatcher: Prism::Dispatcher,
          index: RubyIndexer::Index
        ).void
      end
      def initialize(response_builder, node_context, dispatcher, index)
        @response_builder = response_builder
        @node_context = node_context
        dispatcher.register(self, :on_string_node_enter, :on_symbol_node_enter)
        @index = index
      end

      sig { params(node: Prism::StringNode).void }
      def on_string_node_enter(node)
        handle_prerequisite(node)
      end

      sig { params(node: Prism::SymbolNode).void }
      def on_symbol_node_enter(node)
        handle_prerequisite(node)
      end

      sig { params(node: T.any(Prism::StringNode, Prism::SymbolNode)).void }
      def handle_prerequisite(node) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        call_node_name = @node_context.call_node&.name
        return unless call_node_name == :task

        name = case node
               when Prism::StringNode
                 node.content
               when Prism::SymbolNode
                 node.value
               end

        arg = @node_context.call_node&.arguments&.arguments&.first
        case arg
        when Prism::KeywordHashNode
          kh = arg.child_nodes.first
          case kh
          when Prism::AssocNode
            v = kh.value
            case v
            when Prism::StringNode
              return unless name == v.content
            when Prism::SymbolNode
              return unless name == v.value
            when Prism::ArrayNode
              return unless v.elements.find do |node|
                name == case node # rubocop:disable Metrics/BlockNesting
                        when Prism::StringNode
                          node.content
                        when Prism::SymbolNode
                          node.value
                        end
              end
            end
          end
        else
          return
        end

        task_name = "task:#{name}"
        return unless @index.indexed? task_name

        # refer to: https://github.com/Shopify/ruby-lsp/blob/896617a0c5f7a22ebe12912a481bf1b59db14c12/lib/ruby_lsp/requests/support/common.rb#L83
        content = +""
        entries = @index[task_name]
        links = entries&.map do |entry|
          loc = entry.location
          uri = T.unsafe(URI::Generic).from_path(
            path: entry.file_path,
            fragment: "L#{loc.start_line},#{loc.start_column + 1}-#{loc.end_line},#{loc.end_column + 1}"
          )
          content << "\n\n#{entry.comments}" unless entry.comments.empty?
          "[#{entry.file_name}](#{uri})"
        end
        @response_builder.push("```\nrake #{name}\n```", category: :title)
        @response_builder.push("Definitions: #{links&.join(" | ")}", category: :links)
        @response_builder.push(content, category: :documentation)
      end
    end
  end
end
