

module ElementWrapper

    def do_wrap?( method )
        WrapElementMethods.include?( method )
    end

    def element_type( element )

        klass = element.class.to_s.downcase

        puts "got element type: #{klass.inspect}"

        case
            when klass =~ /form/   ; :form
            when klass =~ /input/  ; :input
        else
            nil
        end
    end

    def get_wrap_klass( ele_type )
        #1.  Determine if our current_connection_type has
        #    a subclass element to handle this element type
        #2.  if not use our default element handler for this type
        #3.  If that doesn't exist use just Element to for the klass

        conn_klass = current_connection_type( false ).capitalize

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

    def wrap_element( element )

        ele_type = element_type( element )
        ele_klass = ele_type.nil? ? Element : get_wrap_klass( ele_type )

        debug "Wrapping Element [ #{element.obj_info} ] With Wrap Klass : #{ele_klass}"
        ele_klass.new( element )

    end

    def wrap( element, method )

        return nil if element.nil?
        return element if !do_wrap?( method )

        case
            when element.is_a?( Array ) ; element.map{ |ele| wrap_element( ele ) }
        else
            wrap_element( element )
        end

    end
end
