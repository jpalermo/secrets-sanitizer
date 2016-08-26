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
# limitations under the License.#!/bin/sh

require 'spec_helper'

describe Sanitizer do
  let(:work_dir) { File.dirname(__FILE__) }
  let(:sanitizer_executable) { "#{work_dir}/../bin/sanitize" }
  let(:fixture_dir) { "#{work_dir}/fixture" }
  let(:tmp_dir) { Dir.mktmpdir }

  before do
    FileUtils.cp_r Dir.glob("#{work_dir}/fixture/*"), tmp_dir
  end

  after do
    FileUtils.rm_r tmp_dir
  end

  it 'has a version number' do
    expect(Sanitizer::VERSION).not_to be nil
  end

  context 'when given a single file' do
    let(:manifest_to_modify) { "manifest_1.yml" }

    it 'extracts secrets to another file' do
      secrets_file = "#{tmp_dir}/secrets-sanitized_#{manifest_to_modify.gsub(".yml", ".json")}"

      stdout, _ = Open3.capture2("#{sanitizer_executable} -i #{tmp_dir}/#{manifest_to_modify} -s #{tmp_dir} -p #{tmp_dir}/config_1 2>&1 --verbose")
      expect(File).to exist(secrets_file)
    end

    it 'extracts secrets to another file and replaces with mustache style syntax' do
      stdout, _ = Open3.capture2("#{sanitizer_executable} -i #{manifest_to_modify} -s #{tmp_dir} -p #{tmp_dir}/config_1 2>&1 --verbose")
      expect(compare_yml("#{tmp_dir}/sanitized_#{manifest_to_modify}", "#{fixture_dir}/sanitized_#{manifest_to_modify}")).to be_truthy
    end
  end

  context 'when given a directory with multiple files' do
    let(:manifest_to_modify) { "manifest_8.yml" }

    it 'works with multiple files in the directory' do
      # changing the -s argument to /dev/null passes this test. Wat.
      stdout, stderr, _ = Open3.capture3("#{sanitizer_executable} -i #{tmp_dir} -s #{tmp_dir}")
      expect(compare_yml("#{tmp_dir}/sanitized_#{manifest_to_modify}", "#{fixture_dir}/sanitized_#{manifest_to_modify}")).to be_truthy
    end
  end

  it 'exit with error when manifest and input_dir are not specified' do
    output = `#{sanitizer_executable} -s #{tmp_dir} -p #{tmp_dir}/config_1 2>&1`
    expect(output).to match(/Manifest or input directory is required/)
  end

  it 'skips symlink files when passed a directory as input' do
    Dir.mkdir("#{tmp_dir}/symlinktest")
    FileUtils.cp "#{tmp_dir}/sanitized_manifest_1.yml", "#{tmp_dir}/symlinktest"
    FileUtils.cp "#{tmp_dir}/secrets-sanitized_manifest_1.json", "#{tmp_dir}/symlinktest"
    FileUtils.ln_s "#{tmp_dir}/symlinktest/manifest_1.yml", "#{tmp_dir}/symlinktest/symlink.yml"

    stdout, stderr, status = Open3.capture3("#{sanitizer_executable} -s #{tmp_dir}/symlinktest -i #{tmp_dir}/symlinktest --verbose")
    expect(stdout).to eq("")
    expect(stderr).to match(/because symlinks are skipped in directory mode/)
    expect(status.exitstatus).to eq(0)
  end

  it 'process the symlinked file when passed as a single argument' do
    Dir.mkdir("#{tmp_dir}/symlinktest")
    FileUtils.mv "#{tmp_dir}/sanitized_manifest_1.yml", "#{tmp_dir}/symlinktest"
    FileUtils.mv "#{tmp_dir}/secrets-sanitized_manifest_1.json", "#{tmp_dir}/symlinktest"
    FileUtils.ln_s "#{tmp_dir}/symlinktest/sanitized_manifest_1.yml", "#{tmp_dir}/symlinktest/symlink.yml"

    stdout, stderr, status = Open3.capture3("#{sanitizer_executable} -s #{tmp_dir}/symlinktest -i #{tmp_dir}/symlinktest/symlink.yml --verbose")

    FileUtils.cp "#{tmp_dir}/symlinktest/sanitized_manifest_1.yml",          tmp_dir
    FileUtils.cp "#{tmp_dir}/symlinktest/secrets-sanitized_manifest_1.json", tmp_dir
    expect(stdout).to eq("")
    expect(stderr).to match(/Resolving symlink/)
    expect(status.exitstatus).to eq(0)
  end
end
