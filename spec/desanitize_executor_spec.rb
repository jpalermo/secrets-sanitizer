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

describe Desanitizer::DesanitizeExecutor do
  let(:work_dir) { File.dirname(__FILE__) }
  let(:fixture_dir) { "#{work_dir}/fixture" }
  let(:tmp_dir) { Dir.mktmpdir }

  before do
    FileUtils.cp_r Dir.glob("#{fixture_dir}/*"), "#{tmp_dir}/"
  end

  after do
    FileUtils.rm_r tmp_dir
  end

  context "when given a simple file" do
    let(:original_file) { "#{tmp_dir}/sanitized_manifest_1.yml" }

    it 'replaces mustache keys with the values from secrets file' do
      Desanitizer::DesanitizeExecutor.execute(original_file, tmp_dir)
      ymls_are_the_same = compare_yml(original_file, "#{tmp_dir}/manifest_1.yml")
      expect(ymls_are_the_same).to be_truthy
    end
  end

  context "when given a file with a sanitized array" do
    let(:original_file) { "#{tmp_dir}/sanitized_manifest_with_array.yml" }

    it 'replaces mustache keys inside arrays with the values from secrets file' do
      Desanitizer::DesanitizeExecutor.execute(original_file, tmp_dir)
      desanitized_yml = File.read(File.expand_path("#{tmp_dir}/manifest_with_array.yml"))
      expected_yml  = File.read(File.expand_path(original_file))
      expect(expected_yml).to eq(desanitized_yml)
    end
  end

  context "when given a multiline file" do
    let(:original_file) { "#{tmp_dir}/sanitized_manifest_multiline.yml" }

    it 'replaces mustache keys with the multiline values from secrets file' do
      Desanitizer::DesanitizeExecutor.execute(original_file, tmp_dir)
      ymls_are_the_same = compare_yml("#{tmp_dir}/manifest_multiline.yml", "#{fixture_dir}/manifest_multiline.yml")
      expect(ymls_are_the_same).to be_truthy
    end
  end
end
