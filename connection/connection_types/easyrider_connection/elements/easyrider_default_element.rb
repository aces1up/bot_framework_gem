

class EasyriderDefault < Element

    #info methods

    def attributes()
        @attribs ||= (
            attr_list = {}
            attr_list[:value] = @element.value
            attr_list[:text]  = @element.text
            attr_list[:html]  = @element.html
            attr_list.merge! @element.list_attributes
            attr_list
        )
       @attribs
    end

    def children_for_element( show_invisible )
        elements = @element.children_for_element( show_invisible )
        wrap( elements, :children_for_element, 'Easyrider' )
    end

    def tag_name()
        @element.tag_name
    end

    def attribute_value( attr )
        @element.attribute_value( attr )
    end
    
    #manipulation Methods

    def set( val )
        @element.element.clear if @element.element.respond_to?(:clear)
        @element.send_keys( *val )
    end

    def click()
        @element.click
    end

    def hover()
        @element.hover
    end

    def hover_js()
        @element.hover_js
    end

    def flash( num_times, interval )
        @element.flash( num_times, interval )
    end

end
