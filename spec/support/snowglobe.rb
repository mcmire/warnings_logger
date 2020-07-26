Snowglobe.configure do |config|
  config.project_name = "warnings_logger"
  config.temporary_directory = Pathname.new("../../tmp").expand_path(__dir__)
end
