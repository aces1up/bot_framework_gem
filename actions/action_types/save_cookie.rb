

class SaveCookie < Action

    def init()
        init_save_vars()
    end

    def run()

        raise ActionError, 'Cannot Save Variable, no Save Variable Specified!' if !@save_var


        info "Attempting to Save Cookie..."

        cur_cookies = cookies

        if cur_cookies.nil? or cur_cookies.empty?
            raise ActionError, 'Cannot Save Cookie, no Cookies found for Connection.'
        end

        found_cookie = cur_cookies.find{ |cookie_hash| cookie_hash[:name] == @data[:cookie_name] }
        debug(" Got Cookies : #{cur_cookies.inspect} ")

        if found_cookie

            @save_val = found_cookie[:value]
            do_save

            info("Saved Cookie Value: #{@save_val}")
            info("Saved to Variable : #{@save_var.inspect}")

        else
            raise ActionError, "Cannot Save Cookie, Cannot Find Cookie with name: #{@data[:cookie_name]}"
        end

    end
end
