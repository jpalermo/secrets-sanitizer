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
require 'open3'
require 'tmpdir'

describe "Desanitizer executable" do
  let(:work_dir) { File.dirname(__FILE__) }
  let(:tmp_dir) { Dir.mktmpdir }
  let(:desanitizer_executable) { "#{work_dir}/../bin/desanitize" }

  before do
    `cp -rf #{work_dir}/fixture/* #{tmp_dir}/`
  end

  after do
    `rm -rf #{tmp_dir}`
  end

  it 'Throws an error if there is a file with secrets and NO cooresponding secrets file' do
    stdout, stderr, status = Open3.capture3("#{desanitizer_executable} -s #{tmp_dir} -i #{tmp_dir}")
    expect(stderr).to match(/has secrets but no corresponding secrets file/)
    expect(status.exitstatus).to eq(1)
  end

  it 'Processes shows errors, but exits 0 when given --force' do
    stdout, stderr, status = Open3.capture3("#{desanitizer_executable} -s #{tmp_dir} -i #{tmp_dir} --force")
    expect(stdout).to eq("")
    expect(stderr).to match(/has secrets but no corresponding secrets file/)
    expect(status.exitstatus).to eq(0)
  end

  it 'handles the --force option by desanitizing files that it can' do
    stdout, stderr, status = Open3.capture3("#{desanitizer_executable} -s #{tmp_dir} -i #{tmp_dir} --force")
    keys=['bla','foo', 'bar_secret_key']
    expect(compare_yml("#{tmp_dir}/sanitized_manifest_1.yml",
      "#{tmp_dir}/manifest_1.yml")).to be_truthy
  end

  it 'skips symlink files when passed a directory as input' do
    Dir.mkdir("#{tmp_dir}/symlinktest")
    FileUtils.cp "#{tmp_dir}/sanitized_manifest_1.yml", "#{tmp_dir}/symlinktest"
    FileUtils.cp "#{tmp_dir}/secrets-sanitized_manifest_1.json", "#{tmp_dir}/symlinktest"
    FileUtils.ln_s "#{tmp_dir}/symlinktest/manifest_1.yml", "#{tmp_dir}/symlinktest/symlink.yml"

    stdout, stderr, status = Open3.capture3("#{desanitizer_executable} -s #{tmp_dir}/symlinktest -i #{tmp_dir}/symlinktest --verbose")

    expect(stdout).to eq("")
    expect(stderr).to match(/because symlinks are skipped in directory mode/)
    expect(status.exitstatus).to eq(0)
  end

  it 'process the symlinked file when passed as a single argument' do
    Dir.mkdir("#{tmp_dir}/symlinktest")
    FileUtils.mv "#{tmp_dir}/sanitized_manifest_1.yml", "#{tmp_dir}/symlinktest"
    FileUtils.mv "#{tmp_dir}/secrets-sanitized_manifest_1.json", "#{tmp_dir}/symlinktest"
    FileUtils.ln_s "#{tmp_dir}/symlinktest/sanitized_manifest_1.yml", "#{tmp_dir}/symlinktest/symlink.yml"

    stdout, stderr, status = Open3.capture3("#{desanitizer_executable} -s #{tmp_dir}/symlinktest -i #{tmp_dir}/symlinktest/symlink.yml --verbose")

    FileUtils.cp "#{tmp_dir}/symlinktest/sanitized_manifest_1.yml",          "#{tmp_dir}"
    FileUtils.cp "#{tmp_dir}/symlinktest/secrets-sanitized_manifest_1.json", "#{tmp_dir}"
    expect(stdout).to eq("")
    expect(stderr).to match(/Resolving symlink/)
    expect(status.exitstatus).to eq(0)
  end

  context "when a .secrets_sanitizer config file exists" do
    it 'maps to the secrets directory listed in .sanitizer_config' do
       Open3.capture3("#{desanitizer_executable}")
    end
  end

end
