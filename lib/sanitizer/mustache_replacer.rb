require 'json'
require 'logger'

module Sanitizer
  class MustacheReplacer

    def initialize(patterns, yaml, secrets={}, logger = Logger.new(STDERR))

      @yaml = yaml
      @config_patterns = []
      @secrets = secrets
      @logger = logger

      patterns.each_line do |p|
        @config_patterns << Regexp.new(p.strip)
      end

    end

    def replace(name, value, hierarchy)
      path = hierarchy.join('_')

      @config_patterns.each do |pattern|
        if (name =~ pattern)
          # if we don't care about logging, these matches can be moved outside the pattern loop
          return if nil_warning(value, name) ||
                    spiff_warning(value, path) ||
                    mustache_warning(value, path) ||
                    erb_warning(value, path)

          # iterate down the yaml tree, from general to specific
          focus = @yaml
          (0 .. hierarchy.size - 2).each do |depth|
            key = hierarchy[depth]
            focus = focus.fetch(key)
          end

          @secrets[path] = value
          if block_given?
            override_path = yield(value, path)
            focus[hierarchy.last] = override_path
          else
            focus[hierarchy.last] = "{{#{path}}}" # replace with mustache syntax like '{{ properties_aws_key }}'
          end
        end
      end
    end

    def manifest_yaml
      YAML.dump(@yaml, options = {:line_width => -1})
    end

    def secrets_json
      if @secrets.size > 0
        return JSON.pretty_generate(@secrets)
      else
        return nil
      end
    end

    def nil_warning(value, name)
      if value.nil?
        @logger.warn "\e[31m Found nil value for key #{name}, skipping... \e[0m "
        true
      end
    end

    def spiff_warning(value, path)
      if value.to_s =~ /\(\(.*\)\)/ # ((spiff / spruce))
        # This seems like the expected behavior, warning the operator is noisy
        @logger.warn "\e[31m Trying to replace a spiff syntax value for #{path}, skipping... \e[0m "
        true
      end
    end

    def mustache_warning(value, path)
      if value.to_s =~ /{{.*}}/ # {{mustache}}
        @logger.warn "\e[31m Trying to replace a mustache syntax value for #{path}, skipping... \e[0m "
        true
      end
    end

    def erb_warning(value, path)
      if value.to_s =~ /<%.*%>/ # <% erb %>
        @logger.warn "\e[31m Trying to replace an erb syntax value for #{path}, skipping... \e[0m "
        true
      end
    end
  end
end

