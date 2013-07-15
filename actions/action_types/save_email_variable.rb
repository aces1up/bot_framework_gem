

class SaveEmailVariable < Action

    attr_accessor :search_string

    def init()
        @search_string = nil
        init_save_vars()
    end

    def run()
        raise ActionError, 'Cannot Save Email Variable, no Search String Specified!' if !@search_string
        raise ActionError, 'Cannot Save Email Variable, no Save Variable Specified!' if !@save_var

        raise ActionError, "Cannot Save Email Variable, no Confirmation Email Currently Stored!" if !self[:email_text]

        self[:email_text] =~ Regexp.new( @search_string )
        @save_val = $1

        if @save_val
            do_save()
        else
            raise ActionError, "Cannot Find Regex: #{@search_string} in Current Confirmation Email!"
        end

    end
end

