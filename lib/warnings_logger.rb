require "warnings_logger/configuration"
require "warnings_logger/filesystem"
require "warnings_logger/partitioner"
require "warnings_logger/reader"
require "warnings_logger/reporter"
require "warnings_logger/spy"

module WarningsLogger
  class << self
    attr_writer :configuration

    def configure(&block)
      configuration.update!(&block)
    end

    def configuration
      # rubocop:disable Naming/MemoizedInstanceVariableName
      @configuration ||= Configuration.new
      # rubocop:enable Naming/MemoizedInstanceVariableName
    end

    def enable
      WarningsLogger::Spy.enable(configuration)
    end
  end
end
