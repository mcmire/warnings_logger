require "optparse"

require_relative "configuration"
require_relative "spy"

module WarningsLogger
  class CLI
    def self.call(argv)
      new(argv).call
    end

    def initialize(argv)
      @argv = argv
      @options = options

      @option_parser = OptionParser.new do |p|
        p.banner = "USAGE: #{$0} OPTIONS"

        p.on("--project-name") do |project_name|
          configuration.project_name = project_name
        end

        p.on("--project-directory") do |project_directory|
          configuration.project_directory = project_directory
        end

        p.on("--help", "-h", "You're looking at it!") do
          puts p
          exit
        end
      end
    end

    def call
      parse_argv!
      run_spy
    end

    private

    attr_reader :argv, :options, :option_parser, :configuration

    def parse_argv!
      option_parser.parse!(argv)
      @configuration = Configuration.new(options)
    end

    def run_spy
      Spy.call(
        project_name: project_name,
        project_directory: project_directory,
      )
    end
  end
end
