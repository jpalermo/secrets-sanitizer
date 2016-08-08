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

require 'json'

module Desanitizer
  class MustacheInterpolator

    def initialize( yaml, secrets={}, logger = Logger.new(STDERR))
      @yaml = yaml
      @secrets = secrets
      @logger = logger
    end

    def interpolate(name, value, hierarchy)
      path = hierarchy.join('_')

      match = value.to_s.match(/\{\{\s*([^\s\}]+)\s*\}\}/)
      return if match.nil?
      key = match[1]

      focus = @yaml
      (0 .. hierarchy.size - 2).each do |depth|
        focus = focus.fetch(hierarchy[depth])
      end

      unless @secrets.has_key?(key)
        @logger.error "\e[31m Missing value  #{path}: #{value} \e[0m "
        exit 1
      end

      focus[hierarchy[-1]] = @secrets.fetch(key)
    end

    def manifest_yaml
      YAML.dump(@yaml, options = {:line_width => -1})
    end
  end
end
