# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ruby_lsp_rake/version"

require "minitest/autorun"
require "ruby_lsp/internal"
require "ruby_lsp/test_helper"
require "ruby_lsp/ruby_lsp_rake/addon"

module ActiveSupport
  class TestCase
    include RubyLsp::TestHelper
  end
end
