

class Element

    include BotFrameWorkModules
    include ElementWrapper

    attr_reader :element

    def initialize( element )
        @element = element      #<--- the handle to the underlying element
    end

    #info Methods

    def attributes()
        raise NotImplementedError
    end

    def tag_name()
        raise NotImplementedError
    end

    def attribute_value( attr )
        raise NotImplementedError
    end

    def children_for_element()
        raise NotImplementedError
    end

    #Manipulation Methods

    def set( val )
        raise NotImplementedError
    end

    def click()
        raise NotImplementedError
    end

    def hover()
        raise NotImplementedError
    end

    def hover_js()
        raise NotImplementedError
    end

    def flash()
        raise NotImplementedError
    end

    def method_missing( method, *args)
        warn("Running No Implmented Method on Element : #{self.obj_info} -- #{method.inspect}")
        #@element.respond_to?( method ) ? @element.send( method, *args ) : super
        super( method, args )
    end

end
