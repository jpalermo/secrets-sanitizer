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

require 'logger'
require 'sanitizer'

module Desanitizer
  class DesanitizeExecutor
    def self.execute(manifest_path, secrets_path, logger = Logger.new(STDERR), force_enabled = false)

      @manifest = YAML.load_file(manifest_path)

      # if given a secrets directory, choose appropriate secrets file
      if File.directory?(secrets_path)
        secrets_path = File.join(
          File.expand_path(secrets_path),
          "/secrets-#{File.basename(manifest_path, '.yml')}.json"
        )
      end

      if File.exist?(secrets_path)
        secrets = JSON.parse(File.read(secrets_path))
      else
        unless unresolved_secrets?
          logger.warn "Secrets file not present for YAML file #{manifest_path} skipping it"
          return
        else
          logger.error "\e[31m This manifest #{manifest_path} has secrets but no corresponding secrets file \e[0m "
          return if     force_enabled
          exit 1 unless force_enabled
        end
      end

      interpolator = Desanitizer::MustacheInterpolator.new(@manifest, secrets, logger)
      Sanitizer::YamlTraverser.traverse(@manifest) do |k, v, hierarchy|
        interpolator.interpolate(k, v, hierarchy)
      end

      File.open(manifest_path, 'w') do |file|
        file.write interpolator.manifest_yaml
      end
    end

    def self.unresolved_secrets?
      @manifest.to_s.match(/"{{.*}}"/)
    end

  end
end
