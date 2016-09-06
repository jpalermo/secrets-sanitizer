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

require 'json'

module Desanitizer
  class MustacheInterpolator

    def initialize( yaml, secrets={}, logger = Logger.new(STDERR))
      @yaml = yaml
      @secrets = secrets
      @logger = logger
    end

    def interpolate(name, value, hierarchy)
      secret_key = secret_key_from(value)

      return unless secret_key
      secret_key_exists?(secret_key)

      focused_hash = reduce_search_field(hierarchy)

      key_to_set = hierarchy.last
      focused_hash[key_to_set] = @secrets.fetch(secret_key)
    end

    def manifest_yaml
      YAML.dump(@yaml, options = {:line_width => -1})
    end

    private

    def secret_key_from(value)
      match = value.to_s.match(/\{\{\s*([^\s\}]+)\s*\}\}/)
      return if match.nil?
      secret_key = match[1]
    end

    def secret_key_exists?(secret_key)
      unless @secrets.has_key?(secret_key)
        @logger.error "\e[31m Missing value #{hierarchy.join('_')}: #{value} \e[0m "
        exit 1
      end

      true
    end

    def reduce_search_field(hierarchy)
      focus = @yaml
      (0 .. hierarchy.size - 2).each do |depth|
        focus = focus.fetch(hierarchy[depth])
      end

      focus
    end
  end
end
