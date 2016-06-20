require 'json'

module Sanitizer
  class MustacheReplacer

    def initialize(patterns, yaml)

      @yaml = yaml
      @config_patterns = []
      @secrets = {}

      patterns.each_line do |p|
        @config_patterns << Regexp.new(p.strip)
      end

    end

    def replace(key, value, hierarchy)
      @config_patterns.each do |p|
        unless p.match(key).nil?
          k = hierarchy.join('_')
          @secrets[k] = value
          m = @yaml
          (0..hierarchy.size-2).each do |h|
            m = m.fetch(hierarchy[h])
          end
          m[hierarchy[-1]] = "'{{#{k}}}'" #replace with mustache syntax like '{{ properties_aws_key }}'
        end
      end
    end

    def manifest_yaml
      YAML.dump(@yaml)
    end

    def secrets_json
      @secrets.to_json
    end
  end
end

