

class SaveVariable < Action

    def init()
        init_save_vars()
    end

    def run()
        raise ActionError, 'Cannot Save Variable, no Save Variable Specified!' if !@save_var and !@data[:attach_proxy]

        @data[:is_variable] ||= false

        @save_val = case

            when @data[:attach_proxy]

                  @save_to_temp = false
                  @save_var     = :proxy_data
                  self[:cur_proxy]

            when @data[:is_variable]  ;  self[ @save_val.to_sym ]

        else
            solve_tag( @save_val )
        end

        
        do_save()

        info("Saved Value: #{@save_val}")
        info("Saved to Variable: #{@save_var}")

    end
end

