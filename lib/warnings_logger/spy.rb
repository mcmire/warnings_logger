require "forwardable"

module WarningsLogger
  # Adapted from <http://myronmars.to/n/dev-blog/2011/08/making-your-gem-warning-free>
  class Spy
    def self.call(args)
      configuration = Configuration.new(args)
      new(configuration).call
    end

    extend Forwardable

    def initialize(configuration)
      @filesystem = Filesystem.new(configuration)
      @reader = Reader.new(filesystem)
      @partitioner = Partitioner.new(
        configuration: configuration,
        reader: reader,
      )
      @reporter = Reporter.new(
        configuration: configuration,
        filesystem: filesystem,
        partitioner: partitioner,
      )
    end

    def call
      filesystem.prepare
      capture_warnings
      report_warnings_at_exit
    end

    private

    attr_reader :filesystem, :reader, :partitioner, :reporter

    def_delegators :filesystem, :warnings_file

    def_delegators :partitioner, :relevant_warning_groups,
      :irrelevant_warning_groups

    def capture_warnings
      $stderr.reopen(warnings_file.path)
    end

    def report_warnings_at_exit
      at_exit do
        printing_exceptions do
          report_and_exit
        end
      end
    end

    def printing_exceptions
      yield
    rescue StandardError => error
      puts "\n--- ERROR IN AT_EXIT --------------------------------"
      puts "#{error.class}: #{error.message}"
      puts error.backtrace.join("\n")
      puts "-----------------------------------------------------"
      raise error
    end

    def report_and_exit
      reader.read
      partitioner.partition

      if relevant_warning_groups.any?
        report_warnings_and_fail
      else
        print_warnings_and_fail
      end
    end

    def report_warnings_and_fail
      reporter.report
      exit(1)
    end

    def print_warnings_and_fail
      filesystem.warnings_file.rewind
      puts filesystem.warnings_file.read
    end
  end
end
