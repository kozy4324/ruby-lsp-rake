# frozen_string_literal: true

require_relative "lib/ruby_lsp_rake/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-lsp-rake"
  spec.version = RubyLsp::Rake::VERSION
  spec.authors = ["Koji NAKAMURA"]
  spec.email = ["kozy4324@gmail.com"]

  spec.summary = "A Ruby LSP addon for Rake"
  spec.description = "A Ruby LSP addon that adds extra editor functionality for Rake"
  spec.homepage = "https://github.com/kozy4324/ruby-lsp-rake"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("ruby-lsp", "~> 0.26.0")
end
