# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

task :quiet_test do
  sh "rake test 2>/dev/null"
end

task default: %i[quiet_test rubocop srb:tc]

namespace :srb do
  desc "Run sorbet type check"
  task :tc do
    sh "bundle exec srb tc"
  end
end

task aaa: %i[bbb ccc:ddd eee:fff]

desc 'this task puts out string "bbb"'
task :bbb do
  puts :bbb
end

namespace :ccc do
  task ddd: :eee do
    puts "ccc:ddd"
  end

  task :eee do
    puts "ccc:eee"
  end
end

namespace :eee do
  task :fff do
    puts "eee:fff"
  end
end
