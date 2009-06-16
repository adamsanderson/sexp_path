module SexpPath
  module Traverse
    def search(pattern, data={})
      collection = SexpCollection.new
      search_each(pattern,data){|match| collection << match}
      collection
    end
    alias_method :/, :search

    def search_each(pattern, data={}, &block)
      return false unless pattern.is_a? Sexp
  
      if pattern.satisfy?(self, data)
        block.call(SexpResult.new(self, data))
      end
  
      self.each do |subset|
        case subset
          when Sexp then subset.search_each(pattern, data, &block)
        end
      end
    end
  
    def satisfy?(o, data={})
      return false unless o.is_a? Sexp
      return false unless length == o.length
      each_with_index{|c,i| return false unless c.is_a?(Sexp) ? c.satisfy?( o[i], data ) : c == o[i] }

      capture_match(o, data)
    end

    def capture_as(name)
      @capture_name = name
      self
    end
    alias_method :%, :capture_as

    private  
    def capture_match(matching_object, data)
      if @capture_name
        data[@capture_name] = matching_object
      end

      data
    end
  end
end