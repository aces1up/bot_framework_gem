

module SaveVarsHelper

    attr_accessor :save_to_temp, :save_var, :overwrite, :save_val

    def do_save()

        container = @save_to_temp ? :temp : :acct
        add( { @save_var => @save_val }, container, @overwrite )

        info("Saved Variable / Value : [ #{@save_var.inspect} / #{@save_val} ] to Container : #{container.inspect}")

    end

    def init_save_vars()
        @save_to_temp  = true
        @overwrite     = true
        @save_var      = nil
        @save_val      = nil
    end
end