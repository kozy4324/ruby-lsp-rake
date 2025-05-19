# typed: true
# frozen_string_literal: true

module RubyLsp
  module Rake
    class IndexingEnhancement < RubyIndexer::Enhancement
      extend T::Sig

      #: (RubyIndexer::DeclarationListener listener) -> void
      def initialize(listener)
        super(listener)
        @namespace_stack = T.let([], T::Array[String])
        @last_desc = T.let(nil, T.nilable(String))
      end

      # @override
      #: (Prism::CallNode node) -> void
      def on_call_node_enter(node) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        @last_desc = nil unless node.name == :task

        return unless T.cast(@listener, RubyIndexer::DeclarationListener).current_owner.nil?
        return unless %i[task desc namespace].include? node.name

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

        if node.name == :desc
          @last_desc = name
          return
        end

        ary = [*@namespace_stack, name]
        (1..(ary.size)).each do |i|
          T.cast(@listener, RubyIndexer::DeclarationListener).add_method(
            "task:#{ary[-i..]&.join(":")}",
            node.location,
            [],
            comments: @last_desc
          )
        end

        @last_desc = nil
      end

      # @override
      #: (Prism::CallNode node) -> void
      def on_call_node_leave(node)
        return unless T.cast(@listener, RubyIndexer::DeclarationListener).current_owner.nil?
        return unless node.name == :namespace

        @namespace_stack.pop
      end
    end
  end
end
