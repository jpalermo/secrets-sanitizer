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

describe Sanitizer::SanitizeExecutor do
  let(:work_dir) { File.dirname(__FILE__) }
  let(:default_config_path) { File.join(spec_folder_root, "../config/catchall") }
  let(:spec_folder_root) { File.expand_path(File.dirname(__FILE__)) }

  before :each do
    @tmp_dir=`mktemp -d`.strip
    `cp -rf #{work_dir}/fixture/* #{@tmp_dir}/`
  end

  after :each do
   `rm -rf #{@tmp_dir}`
  end

  def check_sanitize_success(file_basename, keys, expect_value)
    manifest_post_sanitize = YAML.load_file("#{@tmp_dir}/#{file_basename}.yml")
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


  it 'extracts secrets to another file' do
    FileUtils.rm("#{@tmp_dir}/secrets-manifest_1.json")
    Sanitizer::SanitizeExecutor.execute("#{@tmp_dir}/manifest_1.yml", default_config_path, "#{@tmp_dir}")
    expect { File.open("#{@tmp_dir}/secrets-manifest_1.json") }.to_not raise_error
  end

  it 'adds \'"{{\' to the sanitized file' do
    Sanitizer::SanitizeExecutor.execute("#{@tmp_dir}/manifest_1.yml", default_config_path, "#{@tmp_dir}")
    expect(File.open("#{@tmp_dir}/manifest_1.yml").grep(/\"\{\{/)).to_not be_empty
  end

  it 'works with multiple line value keys' do
    Sanitizer::SanitizeExecutor.execute("#{@tmp_dir}/manifest_3.yml",  default_config_path, "#{@tmp_dir}")
    expect(compare_yml("#{@tmp_dir}/manifest_3.yml", "#{work_dir}/fixture/sanitized_manifest_3.yml")).to be_truthy
  end

  it 'works with multiple line value keys' do
    Sanitizer::SanitizeExecutor.execute("#{@tmp_dir}/manifest_4.yml",  default_config_path, "#{@tmp_dir}")
    keys=['instance_groups', 0 , 'templates', 0, 'properties', 'tsa', 'private_key']
    check_sanitize_success('manifest_4', keys, 'redacted')
  end

  it 'does not create secret file if no secrets matched the pattern' do
    Sanitizer::SanitizeExecutor.execute("#{@tmp_dir}/non_matching_secret_manifest.yml",  default_config_path, "#{@tmp_dir}")
    expect(File).to_not exist("#{@tmp_dir}/secrets-non_matching_secret_manifest.json")
  end

  it 'ignores values already in mustache syntax' do
    Sanitizer::SanitizeExecutor.execute("#{@tmp_dir}/manifest_5.yml",  default_config_path, "#{@tmp_dir}", Logger.new(nil))
    manifest_post_sanitize = YAML.load_file("#{@tmp_dir}/manifest_5.yml")
    mustache_value_key = manifest_post_sanitize['bla']['foo']['bar_secret_key']
    expect(mustache_value_key).to eq("{{bar_secret_value}}")
  end

  it 'ignores null or empty values for matching keys' do
    Sanitizer::SanitizeExecutor.execute("#{@tmp_dir}/manifest_6.yml",  default_config_path, "#{@tmp_dir}", Logger.new(nil))
    manifest_post_sanitize = YAML.load_file("#{@tmp_dir}/manifest_6.yml")
    mustache_value_key = manifest_post_sanitize['bla']['foo']['bar_secret_key']
    expect(mustache_value_key).to eq("{{bla_foo_bar_secret_key}}")
  end

  it 'ignores values already in spiff syntax' do
    Sanitizer::SanitizeExecutor.execute("#{@tmp_dir}/manifest_7.yml",  default_config_path, "#{@tmp_dir}", Logger.new(nil))
    manifest_post_sanitize = YAML.load_file("#{@tmp_dir}/manifest_7.yml")
    mustache_value_key = manifest_post_sanitize['bla']['foo']['bar_secret_key']
    expect(mustache_value_key).to eq("((bar_secret_value))")
  end

  it 'appends to the secrets file if one already exists' do
    existing_secrets = JSON.parse('{"hello" : "world"}')
    json_secret_file_path = File.join(
      File.expand_path(@tmp_dir),
      "/secrets-manifest_1.json"
    )
    File.open(json_secret_file_path, 'w') do |file|
      file.write existing_secrets.to_json
    end

    Sanitizer::SanitizeExecutor.execute("#{@tmp_dir}/manifest_1.yml",  default_config_path, "#{@tmp_dir}")
    keys=['bla','foo', 'bar_secret_key']

    manifest_post_sanitize = check_sanitize_success('manifest_1',keys, 'bar_secret_value')

    secretsFile = File.read(json_secret_file_path)
    secrets = JSON.parse(secretsFile)
    expect(secrets["hello"]).to eq("world")

  end
end
