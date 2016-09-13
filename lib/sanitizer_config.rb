class SanitizerConfig
  attr_reader :file_name

  def initialize(user_input_path, user_secrets_path)
    @pwd          = Dir.getwd
    @input_path   = user_input_path
    @secrets_path = user_secrets_path
    @file_name    = ".secrets_sanitizer"
    @full_config_file_path = "#{input_path}/#{@file_name}"
  end

  def valid?
    config_file && secrets_path
  end

  def invalid?
    !valid?
  end

  def config_file_path
    config_file.path if config_file
  end

  def config_file
    return unless File.exists?(@full_config_file_path)
    @config_file ||= File.open(@full_config_file_path, "r")
  end

  def config_contents
    return @config_contents if @config_contents
    return unless config_file

    lines = []
    config_file.each_line do |line|
      line = line.gsub(/#.*/, '').chomp
      lines << line unless line.empty?
    end

    lines.compact!
    raise "Invalid config file format" if lines.empty? || lines.length > 1
    @config_contents = lines
  end

  def secrets_path
    if(@secrets_path)
      return @secrets_path
    elsif config_contents
      @secrets_path = config_contents.first.strip
    end
  end

  def input_path
    return @input_path if @input_path
    @input_path = File.expand_path(@pwd)
  end

  def create!
    file = File.open("#{@input_path}/#{@file_name}", "w+") { |f|
      f.puts "# This file stores the location of your secrets directory"
      f.puts "# This file's location is the implied location of the input argument"
      f.puts "# Using #{@file_name} only works with whole directory input"
      f.puts secrets_path
    }
  end
end
