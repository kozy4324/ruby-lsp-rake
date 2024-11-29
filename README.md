# ruby-lsp-rake

A Ruby LSP addon that adds extra editor functionality for Rake.

## Installation

If you haven't already done so, you'll need to first [set up Ruby LSP](https://shopify.github.io/ruby-lsp/#usage).

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add ruby-lsp-rake --group development
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install ruby-lsp-rake
```

## Features

### Dependency task links on hover

Add a link to the location where the dependency task is defined to the hover content.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kozy4324/ruby-lsp-rake.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
