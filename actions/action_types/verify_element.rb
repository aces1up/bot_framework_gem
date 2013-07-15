

class VerifyElement < Action

    def init()
        init_element_vars()
    end
=begin
    #handle waiting for our elements here
        #if we have waits specified
        if wait_method
            debug("Waiting for Elements [ #{found_elements.length} ] --- [ Wait Method: #{wait_method}, Timeout: #{wait_timeout} ] ")
            wait_for_elements( found_elements, wait_method, wait_timeout )
        end
=end
    def run()

        @what = solve_tag( @what )
        found = find( @method, @how, @what, @match_type, @start_element, @wait_mode, @timeout )

        if found
            info("Found Element Using: #{dump_element}")
        else
            raise ActionError, "Cannot verify Element: #{dump_element} on Page!"
        end
        
        found

    end

end
