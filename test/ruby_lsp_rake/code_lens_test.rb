# frozen_string_literal: true

require "test_helper"

module RubyLsp
  module Rake
    class TestDefinition < Minitest::Test
      include RubyLsp::TestHelper

      def test_recognizes_rake_tasks # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        response = generate_code_lens_for_source(<<~RUBY)
          # typed: false

          task aaa: :bbb

          namespace :bbb do
            task :ccc do
              puts :ccc
            end
          end
        RUBY

        assert_equal(2, response.size)
        assert_equal("▶ Run In Terminal", response[0].command.title)
        assert_equal("rake aaa", response[0].command.arguments[2])
        assert_equal("▶ Run In Terminal", response[1].command.title)
        assert_equal("rake bbb:ccc", response[1].command.arguments[2])
      end

      def generate_code_lens_for_source(source, file: "/fake.rb") # rubocop:disable Metrics/MethodLength
        @id ||= 1
        @id += 1
        with_server(source, URI(file)) do |server, uri|
          server.process_message(
            id: @id,
            method: "textDocument/codeLens",
            params: { textDocument: { uri: uri }, position: { line: 0, character: 0 } }
          )

          result = pop_result(server)
          result.response
        end
      end
    end
  end
end
