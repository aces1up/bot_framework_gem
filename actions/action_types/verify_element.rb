

class VerifyElement < Action

    def init()
        init_element_vars()
    end

    def run()

        @what = solve_tag( @what )
        found = find( @method, @how, @what, @match_type, @start_element, @wait_mode, @timeout, @use_xpath, @find_invisible, @ele_index )

        if found
          
            info("Found Element Using : #{dump_element}")
            #debug("Found Element Text : #{found.text}")

        else
            if @raise_error
                raise ActionError, "Cannot verify Element: #{dump_element} on Page!"
            else
                info("Cannot Verify Element : #{dump_element} -- Not Raising Error...")
                nil
            end
        end


        found

    end

end
