# frozen_string_literal: true

module RubyLsp
  module RakeGoToTaskDef
    class Hover # rubocop:disable Style/Documentation
      include Requests::Support::Common

      def initialize(response_builder, node_context, dispatcher, index)
        @response_builder = response_builder
        @node_context = node_context
        dispatcher.register(self, :on_string_node_enter)
        @index = index
      end

      def on_string_node_enter(node) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
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

        entries = @index[task_name]
        contents = entries.map do |entry|
          label = "task :#{name}"
          loc = entry.location
          uri = URI::Generic.from_path(
            path: entry.file_path,
            fragment: "L#{loc.start_line},#{loc.start_column + 1}-#{loc.end_line},#{loc.end_column + 1}"
          )
          "[#{label}](#{uri})"
        end
        @response_builder.push("Definitions: #{contents.join(", ")}", category: :documentation)
      end
    end
  end
end
