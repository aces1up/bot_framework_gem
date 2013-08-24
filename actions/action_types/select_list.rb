

class SelectList < Action

    def init()
        init_element_vars
    end

    def remove_ignore_options( options )
        return options if !@data[:ignore_elements]
        ignore_list = @data[:ignore_elements].split(',')

        valid_options = options.find_all{ |option|         
            !ignore_list.include?( option.text.downcase ) and !ignore_list.include?( option.value.downcase )         
        }

        valid_options
    end

    def select_random( options )
        info("Selecting Random Option")
        sel_option = options.sample
        debug("Selecting Option Element : #{sel_option.obj_info}")
        info("Selecting Option: #{sel_option.option_info} ")
        sel_option.select
    end

    def select_specific( options )

        raise ActionError, "Cannot Select Specific Option, no Specific Option Specified!" if !@data[:select_value]

        val = solve_tag( @data[:select_value] ).downcase
        
        options.each do |option|
            if ( option.text.downcase == val or option.value.downcase == val )

                info("Selecting Specific Option  : #{option.option_info}")
                option.select
                return

            end
        end

        #if we get here we were unable to find option with value
        #so raise an error
        raise ActionError, "Cannot Select Specific Option.  Option with Value: #{val.inspect} not Found."

    end

    def run()

        debug( "Running Select List -- #{dump_element}" )

        found = VerifyElement.new( @data ).run

        info  "Found SelectList Element -- Currently Selected: #{found.value}"
        debug "Selected Found Element -- #{found.obj_info}"

        options       = found.options
        valid_options = remove_ignore_options( options )

        raise ActionError, "Cannot Select no Options Available!" if options.empty?


        if @data[:select_value]
            select_specific( valid_options )
        else
            select_random( valid_options )
        end

    end

end

