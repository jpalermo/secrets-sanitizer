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

describe Sanitizer::SanitizeExecutor do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:work_dir) { File.dirname(__FILE__) }
  let(:fixture_dir) { "#{work_dir}/fixture" }
  let(:default_config_path) { File.join(spec_folder_root, "../config/catchall") }
  let(:spec_folder_root) { File.expand_path(File.dirname(__FILE__)) }

  before :each do
    FileUtils.cp_r Dir.glob("#{work_dir}/fixture/*"), tmp_dir
  end

  after :each do
    FileUtils.rm_r tmp_dir
  end

  it 'extracts secrets to another file' do
    FileUtils.rm("#{tmp_dir}/secrets-manifest_1.json")
    Sanitizer::SanitizeExecutor.execute(manifest_path: "#{tmp_dir}/manifest_1.yml",
                                        pattern_file: default_config_path,
                                        secrets_path: tmp_dir)
    expect { File.open("#{tmp_dir}/secrets-manifest_1.json") }.to_not raise_error
  end

  it 'adds \'"{{\' to the sanitized file' do
    Sanitizer::SanitizeExecutor.execute(manifest_path: "#{tmp_dir}/manifest_1.yml",
                                        pattern_file: default_config_path,
                                        secrets_path: tmp_dir)
    expect(File.open("#{tmp_dir}/manifest_1.yml").grep(/\"\{\{/)).to_not be_empty
  end

  it 'works with multiple line value keys' do
    Sanitizer::SanitizeExecutor.execute(manifest_path: "#{tmp_dir}/manifest_multiline.yml",
                                        pattern_file: default_config_path,
                                        secrets_path: tmp_dir)
    expect(compare_yml("#{tmp_dir}/manifest_multiline.yml", "#{fixture_dir}/sanitized_manifest_multiline.yml")).to be_truthy
  end

  it 'works with multiple line value keys' do
    Sanitizer::SanitizeExecutor.execute(manifest_path: "#{tmp_dir}/manifest_4.yml",
                                        pattern_file: default_config_path,
                                        secrets_path: tmp_dir)
    expect(compare_yml("#{tmp_dir}/manifest_4.yml", "#{fixture_dir}/sanitized_manifest_4.yml")).to be_truthy
  end

  it 'does not create secret file if no secrets matched the pattern' do
    Sanitizer::SanitizeExecutor.execute(manifest_path: "#{tmp_dir}/non_matching_secret_manifest.yml",
                                        pattern_file: default_config_path,
                                        secrets_path: tmp_dir)
    expect(File).to_not exist("#{tmp_dir}/secrets-non_matching_secret_manifest.json")
  end

  it 'ignores values already in mustache syntax' do
    Sanitizer::SanitizeExecutor.execute(manifest_path: "#{tmp_dir}/manifest_5.yml",
                                        pattern_file: default_config_path,
                                        secrets_path: tmp_dir,
                                        logger: Logger.new(nil))
    manifest_post_sanitize = YAML.load_file("#{tmp_dir}/manifest_5.yml")
    mustache_value_key = manifest_post_sanitize['bla']['foo']['bar_secret_key']
    expect(mustache_value_key).to eq("{{bar_secret_value}}")
  end

  it 'ignores null or empty values for matching keys' do
    Sanitizer::SanitizeExecutor.execute(manifest_path: "#{tmp_dir}/manifest_6.yml",
                                        pattern_file: default_config_path,
                                        secrets_path: tmp_dir,
                                        logger: Logger.new(nil))
    manifest_post_sanitize = YAML.load_file("#{tmp_dir}/manifest_6.yml")
    mustache_value_key = manifest_post_sanitize['bla']['foo']['bar_secret_key']
    expect(mustache_value_key).to eq("{{bla_foo_bar_secret_key}}")
  end

  it 'ignores values already in spiff syntax' do
    Sanitizer::SanitizeExecutor.execute(manifest_path: "#{tmp_dir}/manifest_7.yml",
                                        pattern_file: default_config_path,
                                        secrets_path: tmp_dir,
                                        logger: Logger.new(nil))
    manifest_post_sanitize = YAML.load_file("#{tmp_dir}/manifest_7.yml")
    mustache_value_key = manifest_post_sanitize['bla']['foo']['bar_secret_key']
    expect(mustache_value_key).to eq("((bar_secret_value))")
  end

  it 'appends to the secrets file if one already exists' do
    existing_secrets = JSON.parse('{"hello" : "world"}')
    secret_file_path = File.join(File.expand_path(tmp_dir), "/secrets-manifest_1.json")
    File.open(secret_file_path, 'w') do |file|
      file.write existing_secrets.to_json
    end

    Sanitizer::SanitizeExecutor.execute(manifest_path: "#{tmp_dir}/manifest_1.yml",
                                        pattern_file: default_config_path,
                                        secrets_path: tmp_dir,
                                        logger: Logger.new(nil))

    expect(compare_yml("#{tmp_dir}/secrets-manifest_1.json", "#{fixture_dir}/secrets-manifest_1_with_existing_secrets.json")).to be_truthy
  end

  context "when given a file with an array" do
    let(:original_file) { "#{tmp_dir}/manifest_with_array.yml" }

    it 'replaces secret array values and leaves non-secret array values as found' do
      Sanitizer::SanitizeExecutor.execute(manifest_path: original_file,
                                          pattern_file: default_config_path,
                                          secrets_path: tmp_dir,
                                          logger: Logger.new(nil))
      sanitized_yml = File.read(File.expand_path("#{tmp_dir}/sanitized_manifest_with_array.yml"))
      expected_yml  = File.read(File.expand_path(original_file))
      expect(expected_yml).to eq(sanitized_yml)
    end


  end
end
