require "forwardable"

module WarningsLogger
  # Adapted from <http://myronmars.to/n/dev-blog/2011/08/making-your-gem-warning-free>
  class Spy
    def self.call(**args)
      configuration = Configuration.new(**args)
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

      @original_stderr = nil
    end

    def call
      filesystem.prepare
      capture_warnings
      report_warnings_after_tests_run
    end

    private

    attr_reader :filesystem, :reader, :partitioner, :reporter

    def_delegators :filesystem, :warnings_file

    def_delegators :partitioner, :relevant_warning_groups,
      :irrelevant_warning_groups

    def capture_warnings
      @original_stderr = $stderr.dup
      $stderr.reopen(warnings_file.path)
    end

    def release_warnings
      $stderr.reopen(@original_stderr)
    end

    def report_warnings_after_tests_run
      _self = self

      if defined?(RSpec)
        RSpec.configure do |config|
          config.after(:suite) do
            _self.instance_eval do
              release_warnings
              printing_exceptions do
                report_and_possibly_fail
              end
            end
          end
        end
      elsif defined?(Minitest) && Minitest.class_variable_get("@@installed_at_exit")
        Minitest.after_run do
          release_warnings
          printing_exceptions do
            report_and_possibly_fail
          end
        end
      else
        at_exit do
          release_warnings
          printing_exceptions do
            report_and_possibly_fail
          end
        end
      end
    end

    def printing_exceptions
      yield
    rescue StandardError => error
      warn "\n--- ERROR IN AT_EXIT --------------------------------"
      warn "#{error.class}: #{error.message}"
      warn error.backtrace.join("\n")
      warn "-----------------------------------------------------"
      raise error
    end

    def report_and_possibly_fail
      reader.read
      partitioner.partition

      if relevant_warning_groups.any?
        report_warnings_and_fail
      else
        print_warnings
      end
    end

    def report_warnings_and_fail
      reporter.report
      exit(1)
    end

    def print_warnings
      filesystem.warnings_file.rewind
      puts filesystem.warnings_file.read
    end
  end
end
