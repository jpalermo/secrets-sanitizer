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
describe Sanitizer::MustacheReplacer do
  let (:patterns) {
    'key'
  }

  let (:sanitize_hash) {
    {
      "some_key" => 'some_value'
    }
  }

  let (:spiff_yaml_hash) {
    {
      "spiff_key" => '(( spiff_value ))'
    }
  }

  let (:mustache_yaml_hash) {
    {
      "mustache_key" => "{{ mustache_value }}"
    }
  }

  it 'replace the value need to be sanitized' do
    replacer = Sanitizer::MustacheReplacer.new(patterns, sanitize_hash, {}, Logger.new(nil))
    replacer.replace('some_key', 'some_value', ['some_key'])
    expect(replacer.manifest_yaml).to eql("---\nsome_key: \"{{some_key}}\"\n")
  end

  it 'ignores values already in mustache syntax' do
    replacer = Sanitizer::MustacheReplacer.new(patterns, mustache_yaml_hash, {}, Logger.new(nil))
    replacer.replace('mustache_key', '(( mustache_value ))', ['mustache_key'])
    expect(replacer.manifest_yaml).to eql("---\nmustache_key: \"{{ mustache_value }}\"\n")
  end

  it 'ignores values already in spiff syntax' do
    replacer = Sanitizer::MustacheReplacer.new(patterns, spiff_yaml_hash, {}, Logger.new(nil))
    replacer.replace('spiff_key', '(( spiff_value ))', ['spiff_key'])
    expect(replacer.manifest_yaml).to eql("---\nspiff_key: \"(( spiff_value ))\"\n")

  end
end
