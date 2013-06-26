

module SaverHelperModule

    def do_save()

        container = @save_to_temp ? :temp : :acct
        add( { @save_var => @save_val }, container, @overwrite )

        info("Saved Variable / Value : [ #{@save_var.inspect} / #{@save_val} ] to Container : #{container.inspect}")

    end

end
