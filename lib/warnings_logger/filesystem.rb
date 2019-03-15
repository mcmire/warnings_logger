require "fileutils"

module WarningsLogger
  class Filesystem
    ROOT_TEMPORARY_DIRECTORY = Pathname.new("/tmp/warnings_logger")

    def initialize(configuration)
      @temporary_directory = ROOT_TEMPORARY_DIRECTORY.join(
        configuration.project_name,
      )
      @files_by_name = Hash.new do |hash, name|
        hash[name] = file_for(name)
      end
    end

    def prepare
      if temporary_directory.exist?
        temporary_directory.rmtree
      end

      temporary_directory.mkpath
    end

    def warnings_file
      files_by_name["all_warnings"]
    end

    def irrelevant_warnings_file
      files_by_name["irrelevant_warnings"]
    end

    def relevant_warnings_file
      files_by_name["relevant_warnings"]
    end

    private

    attr_reader :temporary_directory, :files_by_name

    def file_for(name)
      path_for(name).open("w+")
    end

    def path_for(name)
      temporary_directory.join("#{name}.txt")
    end
  end
end
