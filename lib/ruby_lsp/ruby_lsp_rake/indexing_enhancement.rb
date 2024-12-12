# typed: true
# frozen_string_literal: true

module RubyLsp
  module Rake
    class IndexingEnhancement < RubyIndexer::Enhancement # rubocop:disable Style/Documentation
      @last_desc = nil

      def on_call_node_enter(node) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        @last_desc = nil unless node.name == :task

        return unless @listener.current_owner.nil?
        return unless node.name == :task || node.name == :desc

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

        if node.name == :desc
          @last_desc = name
          return
        end

        location = node.location
        @listener.add_method(
          "task_#{name}",
          location,
          [],
          comments: @last_desc
        )

        @last_desc = nil
      end

      def on_call_node_leave(node); end
    end
  end
end
