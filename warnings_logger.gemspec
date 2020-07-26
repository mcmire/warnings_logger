lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "warnings_logger/version"

Gem::Specification.new do |spec|
  spec.name = "warnings_logger"
  spec.version = WarningsLogger::VERSION
  spec.authors = ["Elliot Winkler"]
  spec.email = ["elliot.winkler@gmail.com"]

  spec.summary = "Easily log warnings in your gems"
  spec.homepage = "https://github.com/mcmire/warnings_logger"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this section
  # to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/mcmire/warnings_logger"
  else
    raise(
      "RubyGems 2.0 or newer is required to protect against public gem " +
      "pushes.",
    )
  end

  # Specify which files should be added to the gem when it is released. The `git
  # ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
