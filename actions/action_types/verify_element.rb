

class VerifyElement < Action

    def init()
        init_element_vars()
    end

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
