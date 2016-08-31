class SecretsSanitizerOptions
  def initialize
    @options = {}
    @custom_option_messages = []
    @header = ""

    OptionParser.new do |opts|
      @options[:input] = []
      opts.banner = "Usage: #{$0} [options]"

      opts.on("-h", "--help", "Help") do
        self.display_help
      end

      opts.on("-c", "--create-config", "Create the .secrets_sanitizer file in the given input path that contains the given secrets path") do |option|
        @options[:create_config] = true
      end

      opts.on("-iINPUT", "--input=INPUT", "Input file or directory") do |option|
        @options[:input] << option
      end

      opts.on("-sSECRETDIR", "--secret-dir=SECRETDIR", "Secret file directory") do |option|
        @options[:sec_dir] = option
      end

      opts.on("-mMANIFEST", "--manifest=MANIFEST", "Manifest yaml") do |option|
        # @options[:manifest] = option
        @options[:input] << option
      end

      opts.on("-dINPUT_DIR", "--input-dir=INPUTDIR", "Input directory of yaml files") do |option|
        # @options[:input_dir] = option
        @options[:input] << option
      end

      opts.on("-v", "--verbose") do
        @options[:verbose] = true
      end

      yield(opts, @options, @custom_option_messages, @header) if block_given?
    end.parse!

  end

  def []=(key, value)
    @options[key] = value
  end

  def [](key)
    @options[key]
  end

  def display_help(exitcode=0)
    puts @header
    puts
    puts "#{$0} [options]"
    puts "-h, --help          Help. See this help message."
    puts "-i, --input         Input manifest file or directory"
    puts "-s, --secret-dir    Folder where all secrets will be read"
    puts "-c, --create-config Create the .secrets_sanitizer file in the given"
    puts "                    input path that contains the given secrets path"
    puts "-v, --verbose"
    puts "-m, --manifest      [deprecated] Input manifest file"
    puts "-d, --input-dir     [deprecated] Input Directory containing yaml with secrets"
    @custom_option_messages.each do |custom_option_message|
      puts custom_option_message
    end
    exit exitcode
  end
end
