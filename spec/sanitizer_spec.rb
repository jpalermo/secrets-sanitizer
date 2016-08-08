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
  before :each do
    @work_dir = File.dirname(__FILE__)
    @tmp_dir=`mktemp -d`.strip
    `cp -rf #{@work_dir}/fixture/* #{@tmp_dir}/`
  end

  after :each do
   `rm -rf #{@tmp_dir}`
  end

  def check_sanitize_success(file_basename, keys, expect_value, nested_dir = '')
    manifest_post_sanitize = YAML.load_file("#{@tmp_dir}/#{nested_dir}/#{file_basename}.yml")
    secret_node = manifest_post_sanitize
    keys.each do |key|
      secret_node = secret_node.fetch(key)
    end
    sanitize_key = keys.join('_')
    expect(secret_node).to eq("{{#{sanitize_key}}}")

    expect(File).to exist("#{@tmp_dir}/secrets-#{file_basename}.json")
    secretsFile = File.read("#{@tmp_dir}/secrets-#{file_basename}.json")
    secrets = JSON.parse(secretsFile)
    expect(secrets[sanitize_key]).to eq(expect_value)
    return manifest_post_sanitize
  end

  it 'has a version number' do
    expect(Sanitizer::VERSION).not_to be nil
  end


  it 'extracts secrets to another file and replaces with mustache style syntax' do
    `#{@work_dir}/../bin/sanitize -m #{@tmp_dir}/manifest_1.yml -s #{@tmp_dir} -p #{@tmp_dir}/config_1 2>&1`
    keys=['bla','foo', 'bar_secret_key']

    manifest_post_sanitize = check_sanitize_success('manifest_1',keys, 'bar_secret_value')

    not_secret_node = manifest_post_sanitize['bla']['foo']['bar_not_secret_key']
    expect(not_secret_node).to eq("bar_not_secret_value")
    special_char_value_node = manifest_post_sanitize['bla']['foo']['special_char_value_key']
    expect(special_char_value_node).to eq("*")
  end

  it 'works with multiple files in the directory' do
    `#{@work_dir}/../bin/sanitize -d #{@tmp_dir} -s #{@tmp_dir} -p #{@tmp_dir}/config_1 2>&1`
    keys=['bla','foo', 'bar_secret_key']
    manifest_post_sanitize = check_sanitize_success('manifest_1',keys, 'bar_secret_value')

    not_secret_node = manifest_post_sanitize['bla']['foo']['bar_not_secret_key']
    expect(not_secret_node).to eq("bar_not_secret_value")
    special_char_value_node = manifest_post_sanitize['bla']['foo']['special_char_value_key']
    expect(special_char_value_node).to eq("*")

    keys=['bla','foo', 'bar_secret_key_2']
    check_sanitize_success('manifest_2',keys, 'bar_secret_value_2')

    keys=['bla','foo', 'bar_secret_key_3']
    check_sanitize_success('manifest_nested_1',keys, 'bar_secret_value_3', 'nested')
  end

  it 'exit with error when manifest and input_dir are not specified' do
    output = `#{@work_dir}/../bin/sanitize -s #{@tmp_dir} -p #{@tmp_dir}/config_1 2>&1`
    expect(output).to match(/Manifest or input directory is required/)
  end
end
