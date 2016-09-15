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

require 'spec_helper'

describe SecretsSanitizerOptions do
  describe "#display_help" do
    before do
      @original_argv = ARGV
      @original_stdout = $stdout

      ARGV = [] # Uuugh I'm not sure how else to just ignore ARGV to prevent
                # rspec command line options from coming in to our parser.
      $stdout = File.open(File::NULL, "w")
    end

    after do
      ARGV << @original_argv
      ARGV.uniq!
      $stdout = @original_stdout
    end

    it "exits with the given exit value" do
      options = SecretsSanitizerOptions.new
      # exit isn't normally defined on instances of SecretsSanitizerOptions,
      # but we can fake it for a little bit!
      allow(options).to receive(:exit).with(1)
      expect(options).to receive(:exit).with(1)
      options.display_help(1)
    end

  end
end
