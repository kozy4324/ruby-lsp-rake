# frozen_string_literal: true

require "test_helper"

module RubyLsp
  module Rake
    class TestDefinition < Minitest::Test
      include RubyLsp::TestHelper

      def test_recognizes_task_definition
        response = generate_definitions_for_source(<<~RUBY, { line: 2, character: 11 })
          # typed: false

          task aaa: :bbb

          task :bbb do
            puts :bbb
          end
        RUBY

        assert_equal(1, response.size)

        assert_equal("file:///fake.rb#L5,1-7,4", response[0].uri.to_s)
        assert_equal(4, response[0].range.start.line)
        assert_equal(0, response[0].range.start.character)
        assert_equal(6, response[0].range.end.line)
        assert_equal(3, response[0].range.end.character)
      end

      def generate_definitions_for_source(source, position) # rubocop:disable Metrics/MethodLength
        @id ||= 1
        @id += 1
        with_server(source) do |server, uri|
          server.process_message(
            id: @id,
            method: "textDocument/definition",
            params: { textDocument: { uri: uri }, position: position }
          )

          result = pop_result(server)
          result.response
        end
      end
    end
  end
end
