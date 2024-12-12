# frozen_string_literal: true

require "test_helper"

module RubyLsp
  module Rake
    class TestHover < Minitest::Test
      include RubyLsp::TestHelper

      def test_hook_returns_link_to_task_defined_by_symbol
        response = hover_on_source(<<~RUBY, { line: 0, character: 17 })
          task default: %w[test]

          task :test do
            ruby "test/unittest.rb"
          end
        RUBY
        assert_equal(<<~CONTENT.chomp, response.contents.value)
          ```
          rake test
          ```

          Definitions: [fake.rb](file:///fake.rb#L3,1-5,4)
        CONTENT
      end

      def test_hook_returns_link_to_task_defined_by_string
        response = hover_on_source(<<~RUBY, { line: 0, character: 17 })
          task default: %w[test]

          task "test" do
            ruby "test/unittest.rb"
          end
        RUBY
        assert_equal(<<~CONTENT.chomp, response.contents.value)
          ```
          rake test
          ```

          Definitions: [fake.rb](file:///fake.rb#L3,1-5,4)
        CONTENT
      end

      def test_hook_returns_link_to_task_defined_by_hash_with_string_key
        response = hover_on_source(<<~RUBY, { line: 0, character: 17 })
          task default: %w[test]

          task "test" => :prereq do
            ruby "test/unittest.rb"
          end
        RUBY
        assert_equal(<<~CONTENT.chomp, response.contents.value)
          ```
          rake test
          ```

          Definitions: [fake.rb](file:///fake.rb#L3,1-5,4)
        CONTENT
      end

      def test_hook_returns_link_to_task_defined_by_hash_with_symbol_key
        response = hover_on_source(<<~RUBY, { line: 0, character: 17 })
          task default: %w[test]

          task test: :prereq do
            ruby "test/unittest.rb"
          end
        RUBY
        assert_equal(<<~CONTENT.chomp, response.contents.value)
          ```
          rake test
          ```

          Definitions: [fake.rb](file:///fake.rb#L3,1-5,4)
        CONTENT
      end

      def test_prerequisite_accepts_symbols
        response = hover_on_source(<<~RUBY, { line: 0, character: 14 })
          task default: :test

          task :test do
            ruby "test/unittest.rb"
          end
        RUBY
        assert_equal(<<~CONTENT.chomp, response.contents.value)
          ```
          rake test
          ```

          Definitions: [fake.rb](file:///fake.rb#L3,1-5,4)
        CONTENT
      end

      private

      def hover_on_source(source, position) # rubocop:disable Metrics/MethodLength
        @id ||= 1
        @id += 1
        with_server(source, stub_no_typechecker: true) do |server, uri|
          server.process_message(
            id: @id,
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
