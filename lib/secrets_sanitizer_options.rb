# Copyright (C) 2016-Present Pivotal Software, Inc. All rights reserved.
#
# This program and the accompanying materials are made available under
# the terms of the under the Apache License, Version 2.0 (the "License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.Copyright (C) 2016-Present Pivotal Software, Inc. # All rights reserved.
#
# This program and the accompanying materials are made available under
# the terms of the under the Apache License, Version 2.0 (the "License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class SecretsSanitizerOptions
  def initialize
    @options = {}
    @custom_option_messages = []
    @header = ""
    @errors = []

    @parser = OptionParser.new do |opts|
      @options[:input] = []
      opts.banner = "Usage: #{$0} [options]"

      opts.on("-c", "--create-config", "Create the .secrets_sanitizer file in the given input path that contains the given secrets path") do |option|
        @options[:create_config] = true
      end

      opts.on("-iINPUT", "--input=INPUT", "Input file or directory") do |option|
        @options[:input] << option
      end

      opts.on("-sSECRETDIR", "--secret-dir=SECRETDIR", "Secret file directory") do |option|
        @options[:sec_dir] = option
      end

      opts.on("-v", "--verbose") do
        @options[:verbose] = true
      end

      opts.on("-h", "--help", "Help") do
        display_help
      end

      yield(opts, @options, @custom_option_messages, @header) if block_given?
    end

    @parser.parse!
  end

  def []=(key, value)
    @options[key] = value
  end

  def [](key)
    @options[key]
  end

  def display_help(exitcode=0)
    puts @parser.help
    exit exitcode
  end

  def check_for_errors!
    if @options[:sec_dir].nil?
      @errors << "Secrets directory is required."
    end

    if @options[:input].empty?
      @errors << "Manifest or input directory is required."
    end

    unless @errors.empty?
      @errors.each do |error|
        $stderr.puts "ERROR: #{error}"
      end
      exit 1
    end
  end
end
