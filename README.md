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
`test/test_helper.rb`, replacing `<project name>` with the name of the gem
you're developing:

``` ruby
WarningsLogger::Spy.call(
  project_name: '<project name>',
  project_directory: Pathname.new('../..').expand_path(__FILE__),
)
```

## Developing

* `bin/setup` to get started
* `bundle exec rake release` to release a new version

## Author/License

Snowglobe is © 2019 Elliot Winkler (<elliot.winkler@gmail.com>) and is released
under the [MIT license](LICENSE).
