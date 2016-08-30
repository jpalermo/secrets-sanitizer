class SanitizerConfig
  attr_reader :secrets_dir, :input, :file_name

  def initialize(input_path)
    @input_path = input_path
    @file_name = ".secrets_sanitizer"
    @config_file = find_config_file
  end

  def valid?
    @config_file && @secrets_dir
  end

  def invalid?
    !valid?
  end

  def find_config_file
    return unless File.exists?(@file_name)

    config_file = File.open(@file_name, "r")
    lines = []
    config_file.each_line do |line|
      line = line.gsub(/#.*/, '').chomp
      lines << line unless line.empty?
    end

    lines.compact!
    raise "Invalid config file format" if lines.empty? || lines.length > 1

    dir_path = lines.first.strip

    @secrets_dir = dir_path
    @input = File.expand_path(File.dirname(config_file))
  end

  def create!
    file = File.open("#{@input_path}/.secrets_sanitizer", "w+") { |f|
      f.puts "# This file is awesome and does stuff for you"
      f.puts @secrets_dir
    }
  end
end