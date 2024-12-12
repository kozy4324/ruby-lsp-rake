# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]

namespace :srb do
  desc "Run sorbet type check"
  task :tc do
    sh "bundle exec srb tc"
  end
end
