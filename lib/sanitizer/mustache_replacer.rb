require 'json'
require 'logger'

module Sanitizer
  class MustacheReplacer

    def initialize(patterns, yaml, secrets={}, logger = Logger.new(STDOUT))

      @yaml = yaml
      @config_patterns = []
      @secrets = secrets
      @logger = logger

      patterns.each_line do |p|
        @config_patterns << Regexp.new(p.strip)
      end

    end

    def replace(key, value, hierarchy)
      k = hierarchy.join('_')
      unless value.nil?
        unless value.to_s.match(/\(\(.*\)\)/).nil? # spiff / spruce
          @logger.warn "Trying to replace a spiff syntax value for #{k}, skipping..."
          return
        end
        unless value.to_s.match(/{{.*}}/).nil? # mustache
          @logger.warn "Trying to replace a mustache syntax value for #{k}, skipping..."
          return
        end
      end

      @config_patterns.each do |p|
        unless p.match(key).nil?
          unless value.nil?
            m = @yaml
            (0..hierarchy.size-2).each do |h|
              m = m.fetch(hierarchy[h])
            end
            @secrets[k] = value
            m[hierarchy[-1]] = "{{#{k}}}" #replace with mustache syntax like '{{ properties_aws_key }}'
          else
            @logger.warn "========Found nil value for key #{key}, skipping..."
          end
        end
      end
    end

    def manifest_yaml
      YAML.dump(@yaml, options = {:line_width => -1})
    end

    def secrets_json
      if @secrets.size > 0
        return @secrets.to_json
      else
        return nil
      end
    end
  end
end

