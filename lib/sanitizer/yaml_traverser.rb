module Sanitizer
  class YamlTraverser
    def self.traverse(hash, hierarchy=[], &blk)
      case hash
      when Hash
        hash.each do |k,v|
          h = hierarchy.clone
          h << k
          if v.is_a?(Hash)
            #noop
          elsif v.is_a?(Array)
            #noop
          else
            blk.call(k,v, h)
          end
          traverse(v, h, &blk)
        end
      when Array
        hash.each {|v| traverse(v, hierarchy, &blk) }
      else
        #noop
      end
    end
  end
end
