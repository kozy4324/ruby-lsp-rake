require "test_helper"

module RubyLsp
  module Rake
    class TestHover < Minitest::Test
      include RubyLsp::TestHelper

      def test_hook_returns_link_to_task_defined
        response = hover_on_source(<<~RUBY, { line: 0, character: 17 })
          task default: %w[test]

          task :test do
            ruby "test/unittest.rb"
          end
        RUBY
        assert_equal(<<~CONTENT.chomp, response.contents.value)
          Definitions: [task :test](file:///fake.rb#L3,1-5,4)
        CONTENT
      end

      private

      def hover_on_source(source, position)
        with_server(source, stub_no_typechecker: true) do |server, uri|
          server.process_message(
            id: 1,
            method: "textDocument/hover",
            params: { textDocument: { uri: uri }, position: position }
          )

          result = pop_result(server)
          result.response
        end
      end

      def pop_result(server)
        result = server.pop_response
        result = server.pop_response until result.is_a?(RubyLsp::Result) || result.is_a?(RubyLsp::Error)

        refute_instance_of(
          RubyLsp::Error,
          result,
          -> { "Failed to execute request #{result.message}" }
        )
        result
      end
    end
  end
end
