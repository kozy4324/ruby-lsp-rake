# frozen_string_literal: true

require "test_helper"

class Ruby::Lsp::TestRake < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Ruby::Lsp::Rake::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
