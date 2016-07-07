require 'json'
require 'mustache'
module Desanitizer
  class MustacheInterpolator < Mustache

    def initialize( yaml, secrets={}, logger = Logger.new(STDERR))
      @yaml = yaml
      @secrets = secrets
      @logger = logger
    end

    def interpolate(name, value, hierarchy)
      path = hierarchy.join('_')

      return unless (value.to_s =~ /{{.*}}/) # {{mustache}}
      # there's a mustache value, let's render it

      focus = @yaml
      (0 .. hierarchy.size - 2).each do |depth|
        focus = focus.fetch(hierarchy[depth])
      end
      rendered_value = Mustache.render(value, @secrets)
      unless rendered_value.empty?
        focus[hierarchy[-1]] = rendered_value
      else
        @logger.warn "\e[31m Missing value: #{path} \e[0m "
        exit 1
      end
    end

    def manifest_yaml
      YAML.dump(@yaml, options = {:line_width => -1})
    end
  end
end
