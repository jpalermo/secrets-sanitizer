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
            v.each_with_index do | this_array_value, this_array_index |
              array_hierarchy = h.clone
              array_hierarchy << this_array_index
              blk.call(k, this_array_value, array_hierarchy)
            end
          else
            blk.call(k,v, h)
          end
          traverse(v, h, &blk)
        end
      when Array
        hash.each_index do |i|
          h = hierarchy.clone
          h << i
          traverse(hash[i], h, &blk)
        end
      else
        #noop
      end
    end
  end
end
