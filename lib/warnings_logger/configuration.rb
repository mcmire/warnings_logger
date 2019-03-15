module WarningsLogger
  class Configuration
    attr_reader :project_name, :project_directory

    def initialize(project_name:, project_directory:)
      @project_name = project_name
      @project_directory = project_directory
    end
  end
end
