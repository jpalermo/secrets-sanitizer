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
require 'desanitizer'
require 'open3'

describe Desanitizer::DesanitizeExecutor do
  before :each do
    @work_dir = File.dirname(__FILE__)
    @tmp_dir=`mktemp -d`.strip
    `cp -rf #{@work_dir}/fixture/* #{@tmp_dir}/`
  end

  after :each do
   `rm -rf #{@tmp_dir}`
  end

  def check_desanitize_success(file_basename, keys, expect_value)
    manifest_post_desanitize = YAML.load_file("#{@tmp_dir}/#{file_basename}.yml")
    expect(File).to exist("#{@tmp_dir}/secrets-#{file_basename}.json")
    secrets_file = File.read("#{@tmp_dir}/secrets-#{file_basename}.json")
    secrets = YAML.load(secrets_file)
    secret_node = manifest_post_desanitize
    keys.each do |key|
      secret_node = secret_node.fetch(key)
    end
    desanitized_key = keys.join('_')
    expect(secret_node).to eq(secrets[desanitized_key])

    return manifest_post_desanitize
  end


  it 'replaces mustache keys with the values from secrets file' do
    Desanitizer::DesanitizeExecutor.execute("#{@tmp_dir}/sanitized_manifest_1.yml",  "#{@tmp_dir}")
    keys=['bla','foo', 'bar_secret_key']

    manifest_post_desanitize = check_desanitize_success('sanitized_manifest_1',keys, 'bar_secret_value')

    not_secret_node = manifest_post_desanitize['bla']['foo']['bar_not_secret_key']
    expect(not_secret_node).to eq("bar_not_secret_value")
    special_char_value_node = manifest_post_desanitize['bla']['foo']['special_char_value_key']
    expect(special_char_value_node).to eq("*")
  end

  it 'replaces mustache keys with the multiline values from secrets file' do
    Desanitizer::DesanitizeExecutor.execute("#{@tmp_dir}/sanitized_manifest_multiline.yml",  "#{@tmp_dir}")
    keys=['bla','foo', 'multi_line_value_key']

    manifest_post_desanitize = check_desanitize_success('sanitized_manifest_multiline',keys, 'bar_secret_value')

    not_secret_node = manifest_post_desanitize['bla']['foo']['bar_not_secret_key']
    expect(not_secret_node).to eq("bar_not_secret_value")
    special_char_value_node = manifest_post_desanitize['bla']['foo']['special_char_value_key']
    expect(special_char_value_node).to eq("*")
  end

  it 'Throws an error if there is a file with secrets and NO cooresponding secrets file' do
    stdout, stderr, status = Open3.capture3("#{@work_dir}/../bin/desanitize -s #{@tmp_dir} -i #{@tmp_dir}")
    expect(stderr).to match(/has secrets but no corresponding secrets file/)
    expect(status.exitstatus).to eq(1)
  end

  it 'Processes shows errors, but exits 0 when given --force' do
    stdout, stderr, status = Open3.capture3("#{@work_dir}/../bin/desanitize -s #{@tmp_dir} -i #{@tmp_dir} --force")
    expect(stdout).to eq("")
    expect(stderr).to match(/has secrets but no corresponding secrets file/)
    expect(status.exitstatus).to eq(0)
  end

  it 'handles the --force option by desanitizing files that it can' do
    stdout, stderr, status = Open3.capture3("#{@work_dir}/../bin/desanitize -s #{@tmp_dir} -i #{@tmp_dir} --force")
    keys=['bla','foo', 'bar_secret_key']
    check_desanitize_success("sanitized_manifest_1", keys, 'bar_secret_value')
  end

end
