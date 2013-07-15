

class SaveVariable < Action

    def init()
        init_save_vars()
    end

    def run()
        raise ActionError, 'Cannot Save Variable, no Save Variable Specified!' if !@save_var

        @save_val = solve_tag( @save_val )
        do_save()

        info("Saved Value: #{@save_val}")
        info("Saved to Variable: #{@save_var}")

    end
end

