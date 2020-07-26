module Matchers
  def have_run_with(**options)
    HaveRunWithMatcher.new(**options)
  end

  class HaveRunWithMatcher
    include RSpec::Matchers::Composable

    def initialize(**options)
      @expected_exit_status = options[:exit_status]
      @expected_output = options[:output]
      @expected_stderr = options[:stderr]
    end

    def matches?(command)
      @command = command

      exit_status_matches? &&
        output_matches? &&
        stderr_matches?
    end

    def failure_message
      message =
        "#{@failure_message}\n\n" +
        "Status: #{command.exit_status}\n\n"

      if expected_stderr
        message << "Stderr:\n"
        message << Snowglobe::OutputHelpers.bookended(command.stderr)
        message << "\n"
      end

      message << "Output:\n"
      message << Snowglobe::OutputHelpers.bookended(command.output)

      message
    end

    private

    attr_reader(
      :expected_exit_status,
      :expected_output,
      :expected_stderr,
      :command
    )

    def exit_status_matches?
      if expected_exit_status
        if command.exit_status == expected_exit_status
          true
        else
          @failure_message =
            "Expected command to have exit status #{expected_exit_status}, " +
            "but it did not."
          false
        end
      else
        true
      end
    end

    def output_matches?
      if expected_output
        if values_match?(expected_output, command.output)
          true
        else
          @failure_message = "Expected and actual output did not match."
          false
        end
      else
        true
      end
    end

    def stderr_matches?
      if expected_stderr
        if values_match?(expected_stderr, command.stderr)
          true
        else
          @failure_message = "Expected and actual stderr did not match."
          false
        end
      else
        true
      end
    end
  end
end
