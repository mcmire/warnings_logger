# Warnings Logger

Easily log warnings in your gems.

## Installation

Add this line to your gem's gemspec:

```ruby
spec.add_development_dependency('warnings_logger')
```

If you have a Gemfile, run:

``` bash
bundle install
```

Or, install the gem yourself:

``` bash
gem install warnings_logger
```

## Usage

To use this gem, place the following in `spec/spec_helper.rb` or
`test/test_helper.rb`, replacing your project name as needed:

``` ruby
WarningsLogger.configure do |config|
  config.project_name = "my_project_name_goes_here"
  config.project_directory = Pathname.new("..").expand_path(__dir__)
end
WarningsLogger.enable
```

We also recommend you run your tests by enabling warnings in general. For RSpec
this means updating the RSpec::Core::RakeTask by setting `config.warnings =
true` and setting `$VERBOSE = true` in your spec helper. For Minitest, this
means updating your Rake::Task::TestTask by setting `t.verbose = true` and
setting `$VERBOSE = true` in your test helper.

With the above code in place, now when you run your tests, if your gem emits any
warnings, they will be written to a file, and the exit code of the test run will
be 1, so that your CI will fail the build. This helps you ensure that your gem
is warning-free before you release a new version.

## Developing

* `bin/setup` to get started
* `bundle exec rake release` to release a new version

## Author/License

Snowglobe is © 2019-2020 Elliot Winkler (<elliot.winkler@gmail.com>) and is
released under the [MIT license](LICENSE).
