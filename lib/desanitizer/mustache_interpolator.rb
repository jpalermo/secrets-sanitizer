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
