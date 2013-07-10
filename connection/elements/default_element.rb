

class Element

    include BotFrameWorkModules
    include ElementWrapper

    attr_reader :element

    def initialize( element )
        @element = element      #<--- the handle to the underlying element
    end

    #info Methods

    def attributes()
        raise FunctionNotImplemented
    end

    def tag_name()
        raise FunctionNotImplemented
    end

    def attribute_value( attr )
        raise FunctionNotImplemented
    end

    def children_for_element()
        #gets just the immediate children for this element, ex.. 1 Level deep.
        raise FunctionNotImplemented
    end

    def elements_for_tag_name( tag, show_invisible=false )
        #gets all subelements for this element that match dom tag
        raise FunctionNotImplemented
    end

    #Manipulation Methods

    def set( val )
        raise FunctionNotImplemented
    end

    def click()
        raise FunctionNotImplemented
    end

    def hover()
        raise FunctionNotImplemented
    end

    def hover_js()
        raise FunctionNotImplemented
    end

    def flash()
        raise FunctionNotImplemented
    end

    def method_missing( method, *args)
        warn("Running No Implmented Method on Element : #{self.obj_info} -- #{method.inspect}")
        #@element.respond_to?( method ) ? @element.send( method, *args ) : super
        super( method, args )
    end

end
