# typed: true
# frozen_string_literal: true

module RubyLsp
  module Rake
    class Hover # rubocop:disable Style/Documentation
      include Requests::Support::Common

      def initialize(response_builder, node_context, dispatcher, index)
        @response_builder = response_builder
        @node_context = node_context
        dispatcher.register(self, :on_string_node_enter, :on_symbol_node_enter)
        @index = index
      end

      def on_string_node_enter(node)
        handle_prerequisite(node)
      end

      def on_symbol_node_enter(node)
        handle_prerequisite(node)
      end

      def handle_prerequisite(node) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        call_node_name = @node_context.call_node&.name
        return unless call_node_name == :task

        name = case node
               when Prism::StringNode
                 node.content
               when Prism::SymbolNode
                 node.value
               end

        task_name = "task_#{name}"
        return unless @index.indexed? task_name

        # refer to: https://github.com/Shopify/ruby-lsp/blob/896617a0c5f7a22ebe12912a481bf1b59db14c12/lib/ruby_lsp/requests/support/common.rb#L83
        entries = @index[task_name]
        links = entries.map do |entry|
          loc = entry.location
          uri = T.unsafe(URI::Generic).from_path(
            path: entry.file_path,
            fragment: "L#{loc.start_line},#{loc.start_column + 1}-#{loc.end_line},#{loc.end_column + 1}"
          )
          "[#{entry.file_name}](#{uri})"
        end
        @response_builder.push("```\nrake #{name}\n```", category: :title)
        @response_builder.push("Definitions: #{links.join(" | ")}", category: :links)
      end
    end
  end
end
