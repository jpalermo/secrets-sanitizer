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

require 'simplecov'
require 'yaml'
require 'json'
SimpleCov.start do
  add_filter "spec/"
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sanitizer'
require 'desanitizer'

def compare_manifests(desanitized_yml_path, expected_output_of_desan_path)
  desanitized_yml = YAML::load(File.open(File.expand_path(desanitized_yml_path)))
  expected_desanitized_yml = YAML::load(File.open(File.expand_path(expected_output_of_desan_path)))
  desanitized_yml == expected_desanitized_yml
end
