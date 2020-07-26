module Matchers
  def have_printed_anything_to_stderr
    HavePrintedAnythingToStderr.new
  end

  class HavePrintedAnythingToStderr
    def does_not_match?(command)
      @command = command
      command.stderr.empty?
    end

    def failure_message_when_negated
      "Expected command not to have printed anything to stderr, but it did. " +
        "Output was:\n\n" +
        Snowglobe::OutputHelpers.bookended(command.stderr)
    end

    private

    attr_reader :command
  end
end
