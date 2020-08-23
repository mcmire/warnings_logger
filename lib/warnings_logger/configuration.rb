require "pathname"

module WarningsLogger
  class Configuration
    attr_writer :project_name

    def initialize
      @project_name = nil
      @project_directory = nil
    end

    def update!
      yield self
    end

    def project_name
      if @project_name
        @project_name
      else
        raise NotConfiguredError.new(<<~EXAMPLE)
          WarningsLogger.configure do |config|
            config.project_name = "your_project_name"
          end
        EXAMPLE
      end
    end

    def project_directory
      if @project_directory
        @project_directory
      else
        raise NotConfiguredError.new(<<~EXAMPLE)
          WarningsLogger.configure do |config|
            config.project_directory = "/path/to/your/project/directory"
          end
        EXAMPLE
      end
    end

    def project_directory=(path)
      @project_directory = Pathname.new(path)
    end

    class NotConfiguredError < StandardError
      def initialize(example)
        super(<<~MESSAGE)
          You need to configure WarningsLogger before you can use it! For example:

          #{example}
        MESSAGE
      end
    end
  end
end
