require "spec_helper"

RSpec.describe WarningsLogger::Spy do
  context "within an RSpec project" do
    attr_reader :project

    before :all do
      @project = Snowglobe::RSpecProject.create

      project.write_file("spec/spec_helper.rb", <<~FILE)
        $:.unshift("#{Pathname.new("../../lib").expand_path(__dir__)}")
        require "warnings_logger"
        WarningsLogger.configure do |config|
          config.project_name = "example"
          config.project_directory = "#{project.directory}"
        end
        WarningsLogger.enable

        require "example"

        $VERBOSE = true
      FILE
    end

    context "assuming that no Ruby warnings are emitted from files within the project" do
      it "exits cleanly without printing a message" do
        project.write_file("lib/example.rb", <<~FILE)
          def example; end
        FILE

        project.write_file("spec/example_spec.rb", <<~FILE)
          require "spec_helper"

          describe "example" do
            it "does not emit a warning" do
              example
            end
          end
        FILE

        expect(project.run_rspec_tests).to have_run_with(
          exit_status: 0,
          stderr: ""
        )
      end
    end

    context "if warnings are emitted from files within the project" do
      it "spits out a message after running all tests" do
        project.write_file("lib/example.rb", <<~FILE)
          class A
            def self.call(options)
              B.call(options)
            end
          end

          class B
            def self.call(**options)
              new(**options).call
            end

            def initialize(**options)
            end

            def call
            end
          end
        FILE

        project.write_file("spec/example_spec.rb", <<~FILE)
          require "spec_helper"

          describe "example" do
            it "emits a warning" do
              A.call({ foo: "bar" })
            end
          end
        FILE

        expected_stderr = <<-STDERR
---------- example warnings:--------
#{project.directory}/lib/example.rb:3: warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call
#{project.directory}/lib/example.rb:8: warning: The called method `call' is defined here
---------------------------------------------------------------------------
example warnings written to #{project.directory}/tmp/warnings_logger/relevant_warnings.txt.
All warnings were written to #{project.directory}/tmp/warnings_logger/all_warnings.txt.
        STDERR
        expect(project.run_rspec_tests).to have_run_with(
          exit_status: 1,
          stderr: a_string_including(expected_stderr)
        )
      end
    end
  end

  context "within a Minitest project" do
    attr_reader :project

    before :all do
      @project = Snowglobe::MinitestProject.create

      project.write_file("test/test_helper.rb", <<~FILE)
        require "minitest/autorun"

        $:.unshift("#{Pathname.new("../../lib").expand_path(__dir__)}")
        require "warnings_logger"
        WarningsLogger.configure do |config|
          config.project_name = "example"
          config.project_directory = "#{project.directory}"
        end
        WarningsLogger.enable

        require "example"

        $VERBOSE = true
      FILE
    end

    context "assuming that no Ruby warnings are emitted from files within the project" do
      it "exits cleanly without printing a message" do
        project.write_file("lib/example.rb", <<~FILE)
          def example; end
        FILE

        project.write_file("test/example_test.rb", <<~FILE)
          require "test_helper"

          class ExampleTest < Minitest::Spec
            it "does not emit a warning" do
              example
            end
          end
        FILE

        expect(project.run_n_unit_tests("test/example_test.rb"))
          .to have_run_with(exit_status: 0, stderr: "")
      end
    end

    context "if warnings are emitted from files within the project" do
      it "spits out a message after running all tests" do
        project.write_file("lib/example.rb", <<~FILE)
          class A
            def self.call(options)
              B.call(options)
            end
          end

          class B
            def self.call(**options)
              new(**options).call
            end

            def initialize(**options)
            end

            def call
            end
          end
        FILE

        project.write_file("test/example_test.rb", <<~FILE)
          require "test_helper"

          class ExampleTest < Minitest::Spec
            it "emits a warning" do
              A.call({ foo: "bar" })
            end
          end
        FILE

        expected_stderr = <<-STDERR
---------- example warnings:--------
#{project.directory}/lib/example.rb:3: warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call
#{project.directory}/lib/example.rb:8: warning: The called method `call' is defined here
---------------------------------------------------------------------------
example warnings written to #{project.directory}/tmp/warnings_logger/relevant_warnings.txt.
All warnings were written to #{project.directory}/tmp/warnings_logger/all_warnings.txt.
        STDERR
        expect(project.run_n_unit_tests("test/example_test.rb"))
          .to have_run_with(
            exit_status: 1,
            stderr: a_string_including(expected_stderr)
          )
      end
    end
  end
end
