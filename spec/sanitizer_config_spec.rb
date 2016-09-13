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

describe SanitizerConfig do
  let(:work_dir) { File.dirname(__FILE__) }
  let(:fixture_dir) { "#{work_dir}/fixture" }
  let(:tmp_dir) { Dir.mktmpdir }
  let(:secrets_dir) { "#{tmp_dir}/secrets" }
  let(:config) { SanitizerConfig.new("#{tmp_dir}", nil) }

  before do
    FileUtils.cp_r Dir.glob("#{fixture_dir}/*"), "#{tmp_dir}/"
  end

  after do
    FileUtils.rm_r tmp_dir
  end

  def create_valid_config_file
    file = File.open("#{tmp_dir}/.secrets_sanitizer", "w+")
    file.puts secrets_dir
    file.flush
    file
  end

  describe "#create!" do
    let(:config) { SanitizerConfig.new("#{tmp_dir}", "#{tmp_dir}") }

    it "writes the given secrets path to a file" do
      config.create!
      config_file = File.open("#{tmp_dir}/#{config.file_name}").read
      expect(config_file).to include("This file stores the location of your secrets directory")
      expect(config_file).to include(tmp_dir)
    end

    context "when a file is given instead of a directory" do
      let(:config) { SanitizerConfig.new("#{tmp_dir}/manifest_1.yml", "#{tmp_dir}") }

      it "raises an appropriate error" do
        expect{ config.create! }.to raise_error(Errno::ENOTDIR)
      end
    end
  end

  describe "#secrets_path" do
    context "when a secrets path is given during config initialization" do
      let(:config) { SanitizerConfig.new("#{tmp_dir}", "#{tmp_dir}/some_dir") }

      it "returns the secrets path given" do
        expect(config.secrets_path).to eq("#{tmp_dir}/some_dir")
      end
    end

    context "when a secrets path isn't given during config initialization" do
      before { create_valid_config_file }

      it "returns the secrets path from the config file" do
        expect(config.secrets_path).to eq(secrets_dir)
      end
    end
  end

  describe "#config_file" do
    context "when a config file exists" do
      before { create_valid_config_file }

      it "returns a file object" do
        expect(config.config_file).to be_instance_of(File)
      end

      it "returns a file with the appropriate path" do
        expect(config.config_file.path).to eq("#{tmp_dir}/.secrets_sanitizer")
      end
    end

    context "when a config file doesn't exist" do
      it "returns nil" do
        expect(config.config_file).to be_nil
      end
    end
  end

  describe "#config_file_path" do
    context "when a config file exists" do
      before { create_valid_config_file }
      it "returns a file with the appropriate path" do
        expect(config.config_file_path).to eq("#{tmp_dir}/.secrets_sanitizer")
      end
    end

    context "when a config file doesn't exist" do
      it "returns nil" do
        expect(config.config_file_path).to be_nil
      end
    end
  end

  describe "#valid?" do

    context "when a config file exists" do
      before do
        allow(config).to receive(:config_file) { double }
      end

      context "when a secrets_path is given" do
        it "returns a truthy value" do
          allow(config).to receive(:secrets_path) { double }
          expect(config.valid?).to be_truthy
        end
      end

      context "when a secrets_path isn't given" do
        it "returns a falsy value" do
          allow(config).to receive(:secrets_path) { nil }
          expect(config.valid?).to be_falsy
        end
      end
    end

    context "when a config file doesn't exist" do
      it "returns a falsy value" do
        expect(config.valid?).to be_falsy
      end
    end
  end

  describe "#invalid?" do
    context "when the config is valid" do
      it "returns false" do
        allow(config).to receive(:valid?) { true }
        expect(config.invalid?).to be_falsy
      end
    end

    context "when the config is invalid" do
      it "returns true" do
        allow(config).to receive(:valid?) { false }
        expect(config.invalid?).to be_truthy
      end
    end
  end

  describe "#config_contents" do
    context "when a config file doesn't exist" do
      it "returns nil" do
        expect(config.config_contents).to be_nil
      end
    end

    context "when a config file exists" do
      context "when the given config file is empty" do
        before do
          file = File.open("#{tmp_dir}/.secrets_sanitizer", "w+")
          file.close
        end

        it "raises an exception" do
          expect {
            config.config_contents
          }.to raise_error("Invalid config file format")
        end
      end

      context "when the given config file has multiple lines" do
        before do
          file = create_valid_config_file
          file.puts secrets_dir
          file.close
        end

        it "raises an exception" do
          expect {
            config.config_contents
          }.to raise_error("Invalid config file format")
        end
      end

      context "when the given config file is valid" do
        context "when given a file with comments" do
          before do
            file = create_valid_config_file
            file.puts "# This file stores the location of the hellmouth"
            file.close
          end

          it "ignores comments" do
            expect(config.config_contents).to include(secrets_dir)
            expect(config.config_contents).to_not include(/This file stores/)
          end
        end

        context "when given a file with empty lines" do
          before do
            file = create_valid_config_file
            file.puts ""
            file.close
          end

          it "ignores empty lines" do
            expect(config.config_contents).to include(secrets_dir)
            expect(config.config_contents).to_not include(/^\n$/)
          end
        end


        it "returns the contents of the config file" do
          create_valid_config_file
          expect(config.config_contents).to eq([secrets_dir])
        end
      end
    end
  end

  describe "#input_path" do
    context "when an input path isn't given" do
      let(:config) { SanitizerConfig.new(nil, nil) }

      it "returns the current working directory" do
        pwd = File.expand_path(Dir.getwd)
        expect(config.input_path).to eq(pwd)
      end
    end

    context "when an input path is given" do
      it "returns the given input path" do
        expect(config.input_path).to eq(tmp_dir)
      end
    end
  end
end
