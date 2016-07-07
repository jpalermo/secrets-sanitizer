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

      # this test is of questionable value
      if (value.nil?)
        @logger.warn "\e[31m Found nil value for key #{name}, skipping... \e[0m "
        return
      end

      return unless (value.to_s =~ /{{.*}}/) # {{mustache}}
      # there's a mustache value, let's render it

      @logger.warn "\e[31m Going to replace a mustache syntax value \e[0m "
      focus = @yaml
      (0 .. hierarchy.size - 2).each do |depth|
        focus = focus.fetch(hierarchy[depth])
      end
      focus[hierarchy[-1]] = Mustache.render(value, @secrets) #replace with  value of mustache placeholder

    end

    def manifest_yaml
      YAML.dump(@yaml, options = {:line_width => -1})
    end
  end
end
