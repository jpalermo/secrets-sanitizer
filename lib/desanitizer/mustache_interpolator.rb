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
        if (value.nil?)
          @logger.warn "========Found nil value for key #{name}, skipping..."
          return
        end

        if (value.to_s =~ /{{.*}}/) # {{mustache}}
          @logger.warn "Going to replace a mustache syntax value "
          focus = @yaml
          (0 .. hierarchy.size - 2).each do |depth|
            focus = focus.fetch(hierarchy[depth])
          end
          focus[hierarchy[-1]] = Mustache.render(value, @secrets) #replace with  value of mustache placeholder'
        end
     end

    def manifest_yaml
      YAML.dump(@yaml, options = {:line_width => -1})
    end
  end
end
