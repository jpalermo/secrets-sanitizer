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

describe "Desanitizer executable" do
  let(:work_dir) { File.dirname(__FILE__) }
  let(:tmp_dir) { Dir.mktmpdir }
  let(:desanitizer_executable) { "#{work_dir}/../bin/desanitize" }

  before do
    FileUtils.cp_r Dir.glob("#{work_dir}/fixture/*sanitized*"), tmp_dir
  end

  after do
    FileUtils.rm_r tmp_dir
  end

  context "when given a file with secrets and no corresponding secrets file" do
    before do
      FileUtils.cp_r Dir.glob("#{work_dir}/fixture/*"), tmp_dir
    end

    context "when the --force option is given" do
      it 'Throws an error' do
        stdout, stderr, status = Open3.capture3("#{desanitizer_executable} -s #{tmp_dir} -i #{tmp_dir}")
        expect(stderr).to match(/has secrets but no corresponding secrets file/)
        expect(status.exitstatus).to eq(1)
      end
    end

    context "when the --force option isn't given" do
      it 'shows errors, but exits with a 0 status' do
        stdout, stderr, status = Open3.capture3("#{desanitizer_executable} -s #{tmp_dir} -i #{tmp_dir} --force")
        expect(stdout).to eq("")
        expect(stderr).to match(/has secrets but no corresponding secrets file/)
        expect(status.exitstatus).to eq(0)
      end
    end

    it 'handles the --force option by desanitizing files that it can' do
      FileUtils.cp "#{work_dir}/fixture/manifest_with_simple_values.yml", "#{tmp_dir}/"
      stdout, stderr, status = Open3.capture3("#{desanitizer_executable} -s #{tmp_dir} -i #{tmp_dir} --force")

      expect(compare_yml("#{tmp_dir}/sanitized_manifest_with_simple_values.yml",
        "#{tmp_dir}/manifest_with_simple_values.yml")).to be_truthy
    end
  end

  it 'skips symlink files when passed a directory as input' do
    Dir.mkdir("#{tmp_dir}/symlinktest")
    FileUtils.cp "#{tmp_dir}/sanitized_manifest_with_simple_values.yml", "#{tmp_dir}/symlinktest"
    FileUtils.cp "#{tmp_dir}/secrets-sanitized_manifest_with_simple_values.json", "#{tmp_dir}/symlinktest"
    FileUtils.ln_s "#{tmp_dir}/symlinktest/manifest_with_simple_values.yml", "#{tmp_dir}/symlinktest/symlink.yml"

    stdout, stderr, status = Open3.capture3("#{desanitizer_executable} -s #{tmp_dir}/symlinktest -i #{tmp_dir}/symlinktest --verbose")
    expect(stdout).to eq("")
    expect(stderr).to match(/because symlinks are skipped in directory mode/)
    expect(status.exitstatus).to eq(0)
  end

  it 'process the symlinked file when passed as a single argument' do
    Dir.mkdir("#{tmp_dir}/symlinktest")
    FileUtils.mv "#{tmp_dir}/sanitized_manifest_with_simple_values.yml", "#{tmp_dir}/symlinktest"
    FileUtils.mv "#{tmp_dir}/secrets-sanitized_manifest_with_simple_values.json", "#{tmp_dir}/symlinktest"
    FileUtils.ln_s "#{tmp_dir}/symlinktest/sanitized_manifest_with_simple_values.yml", "#{tmp_dir}/symlinktest/symlink.yml"

    stdout, stderr, status = Open3.capture3("#{desanitizer_executable} -s #{tmp_dir}/symlinktest -i #{tmp_dir}/symlinktest/symlink.yml --verbose")

    FileUtils.cp "#{tmp_dir}/symlinktest/sanitized_manifest_with_simple_values.yml",          tmp_dir
    FileUtils.cp "#{tmp_dir}/symlinktest/secrets-sanitized_manifest_with_simple_values.json", tmp_dir
    expect(stdout).to eq("")
    expect(stderr).to match(/Resolving symlink/)
    expect(status.exitstatus).to eq(0)
  end

  context "when a .secrets_sanitizer config file exists" do
    let(:secrets_dir) { tmp_dir }

    it 'desanitizes a file listed in the config' do
      file = File.open("#{tmp_dir}/.secrets_sanitizer", "w+") { |f|
        f.puts secrets_dir
      }
      current = Dir.getwd
      Dir.chdir(tmp_dir) # Move pwd to tmp dir
      stdout, stderr, _ = Open3.capture3(desanitizer_executable)
      Dir.chdir(current) # Move pwd back to rspec doesn't freak out
      expect(compare_yml("#{tmp_dir}/sanitized_manifest_with_simple_values.yml",
        "#{work_dir}/fixture/manifest_with_simple_values.yml")).to be_truthy
    end

    it 'ignores comments in the config file' do
      file = File.open("#{tmp_dir}/.secrets_sanitizer", "w+") { |f|
        f.puts "# yml comment!!!!!"
        f.puts secrets_dir
      }

      current = Dir.getwd
      Dir.chdir(tmp_dir) # Move pwd to tmp dir
      stdout, stderr, _ = Open3.capture3("#{desanitizer_executable} --verbose")
      Dir.chdir(current) # Move pwd back to rspec doesn't freak out

      ymls_are_the_same = compare_yml("#{tmp_dir}/sanitized_manifest_with_simple_values.yml", "#{work_dir}/fixture/manifest_with_simple_values.yml")
      expect(ymls_are_the_same).to be_truthy
    end

    it 'throws an error (╯°□°）╯ if the config file has no input' do
      file = File.open("#{tmp_dir}/.secrets_sanitizer", "w+") { |f|
        f.puts "# yml comment!!!!!"
      }

      current = Dir.getwd
      Dir.chdir(tmp_dir) # Move pwd to tmp dir
      stdout, stderr, status = Open3.capture3("#{desanitizer_executable} --verbose")
      Dir.chdir(current) # Move pwd back to rspec doesn't freak out
      expect(stderr).to match(/Invalid config file format/)
      expect(status.exitstatus).to eq(1)
    end

    it 'exits with a error if the config file has multiple lines that aren\'t comments' do
      file = File.open("#{tmp_dir}/.secrets_sanitizer", "w+") { |f|
        f.puts "/path/to/thingy"
        f.puts "/path/to/thingy2"
      }

      current = Dir.getwd
      Dir.chdir(tmp_dir) # Move pwd to tmp dir
      stdout, stderr, status = Open3.capture3("#{desanitizer_executable} --verbose")
      Dir.chdir(current) # Move pwd back to rspec doesn't freak out

      expect(stderr).to match(/Invalid config file format/)
      expect(status.exitstatus).to eq(1)
    end
  end

  context "when a .secrets_sanitizer config file doesn't exist" do
    context "if no arguments are given" do
      it 'shows help' do
        stdout, _, _ = Open3.capture3(desanitizer_executable)
        expect(stdout).to match(/-h, --help/)
      end
    end

    context "if --create-config argument is given with other correct input" do
      it "creates a .secrets_sanitizer file" do
        current = Dir.getwd
        Dir.chdir(tmp_dir) # Move pwd to tmp dir
        stdout, stderr, status = Open3.capture3("#{desanitizer_executable} --verbose --create-config -i #{tmp_dir} -s /path/to/blah")
        Dir.chdir(current) # Move pwd back to rspec doesn't freak out

        expect(File).to exist("#{tmp_dir}/.secrets_sanitizer")
      end

      it 'adds the secrets path given to the config file' do
        current = Dir.getwd
        Dir.chdir(tmp_dir) # Move pwd to tmp dir
        stdout, stderr, status = Open3.capture3("#{desanitizer_executable} --verbose --create-config -i #{tmp_dir} -s #{tmp_dir}")
        Dir.chdir(current) # Move pwd back to rspec doesn't freak out
        contents = File.open("#{tmp_dir}/.secrets_sanitizer", "r").read

        expect(contents).to match(tmp_dir)
      end
    end

    context "when --create-config argument is given with a single file as input" do
      it "displays an message that a config file won't be created" do
        _, stderr, _ = Open3.capture3("#{desanitizer_executable} --verbose --create-config -i #{tmp_dir}/manifest_with_simple_values.yml -s #{tmp_dir}")
        expect(stderr).to match(/A config file will only be created if a directory is given as input./)
      end

      it "exits with status 1" do
        _, _, status = Open3.capture3("#{desanitizer_executable} --verbose --create-config -i #{tmp_dir}/manifest_with_simple_values.yml -s #{tmp_dir}")
        expect(status.exitstatus).to eq(1)
      end
    end
  end

end
