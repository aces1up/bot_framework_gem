

module ElementWrapper

    def do_wrap?( method )
        WrapElementMethods.include?( method )
    end

    def element_type( element )

        klass = element.class.to_s.downcase

        #puts "got element type: #{klass.inspect}"

        case
            when klass =~ /form/   ; :form
            #when klass =~ /input/  ; :input
        else
            :default
        end
    end

    def get_default_klass( conn_klass )

        klass = get_constant( "#{conn_klass}Default" )
        klass ? klass : Element
    end

    def get_wrap_klass( ele_type, conn_klass )
        #1.  Determine if our current_connection_type has
        #    a subclass element to handle this element type
        #2.  if not use our default element handler for this type
        #3.  If that doesn't exist use just Element to for the klass

        conn_klass ||= current_connection_type()
        conn_klass = conn_klass.to_s

        #use our default elements for the connection
        return get_default_klass( conn_klass.to_s ) if ele_type == :default

        #puts "conn class wrapper : #{conn_klass.inspect}"

        ele_type_str  = ele_type.to_s.capitalize

        #puts "get Wrap Klass : #{conn_klass} -- #{ele_type_str}"

        #create a string array of our class types we want to resolve
        klass_search = [ "#{conn_klass}#{ele_type_str}", "Default#{ele_type_str}", 'Element' ]
        klass_search.each { |klass_str|
           const = get_constant( klass_str )
           return const if const
        }
    end

    def wrap_element( element, conn_klass )

        ele_klass = get_wrap_klass( element_type( element ), conn_klass )

        debug "Wrapping Element [ #{element.obj_info} ] With Wrap Klass : #{ele_klass}"
        ele_klass.new( element )

    end

    def wrap( element, method=nil, conn_klass=nil )

        return nil if element.nil?
        return element if !do_wrap?( method )

        case
            when element.is_a?( Array ) ; element.map{ |ele| wrap_element( ele, conn_klass ) }
        else
            wrap_element( element, conn_klass )
        end

    end
end
