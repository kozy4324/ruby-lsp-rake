# typed: true
# frozen_string_literal: true

module RubyLsp
  module Rake
    class Definition
      extend T::Sig
      include Requests::Support::Common

      #: (RubyLsp::ResponseBuilders::CollectionResponseBuilder response_builder, NodeContext node_context, RubyIndexer::Index index, Prism::Dispatcher dispatcher) -> void
      def initialize(response_builder, node_context, index, dispatcher)
        @response_builder = response_builder
        @node_context = node_context
        @nesting = T.let(node_context.nesting, T::Array[String])
        @index = index

        dispatcher.register(self, :on_symbol_node_enter, :on_string_node_enter)
      end

      #: (Prism::SymbolNode node) -> void
      def on_symbol_node_enter(node)
        handle_prerequisite(node)
      end

      #: (Prism::StringNode node) -> void
      def on_string_node_enter(node)
        handle_prerequisite(node)
      end

      #: ((Prism::SymbolNode | Prism::StringNode) node) -> void
      def handle_prerequisite(node) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
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
              return unless v.elements.find do |n|
                name == case n # rubocop:disable Metrics/BlockNesting
                        when Prism::StringNode
                          n.content
                        when Prism::SymbolNode
                          n.value
                        end
              end
            end
          end
        else
          return
        end

        task_name = "task:#{name}"
        return unless @index.indexed? task_name

        entries = T.must(@index[task_name])

        # refer to: https://github.com/Shopify/ruby-lsp-rails/blob/b7791290fb59b06dc99e28a991ee0607e3931a1e/lib/ruby_lsp/ruby_lsp_rails/definition.rb#L141-L152
        entries.each do |entry|
          loc = entry.location
          uri = T.unsafe(URI::Generic).from_path(
            path: entry.file_path,
            fragment: "L#{loc.start_line},#{loc.start_column + 1}-#{loc.end_line},#{loc.end_column + 1}"
          )
          @response_builder << Interface::Location.new(
            uri: uri,
            range: range_from_location(entry.location)
          )
        end
      end
    end
  end
end
