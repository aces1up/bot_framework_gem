
class SaveElementAttribute < Action

    attr_accessor :save_attr

    def init()
        @save_attr = nil
        init_save_vars()
    end

    def run()
        raise ActionError, 'Cannot Save Element Attribute, no Save Variable Specified!' if !@save_var

        found = VerifyElement.new( @data ).run

        @save_val = case @save_attr
            when :text ; found.text
            when :html ; found.html
        else
            found.attribute_value( @save_attr )
        end

        if @save_val             
             do_save()
             info("Saved Attribute / Value: [ #{@save_attr} / #{@save_val.inspect} ] ")
             info("Saved To Variable: #{@save_var}")
        else
             raise ActionError, "Cannot Save Attribute: #{@save_attr}, It is Empty!"
        end

    end
end
