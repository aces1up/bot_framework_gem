
class SaveRawPostVariable < Action

    attr_accessor :search_string

    def init()
        @search_string = nil
        init_save_vars()
    end

    def run()
        raise ActionError, 'Cannot Save Raw Post Variable, no Search String Specified!' if !@search_string
        raise ActionError, 'Cannot Save Raw Post Variable, no Save Variable Specified!' if !@save_var

        raise ActionError, "Cannot Save Raw Post Variable, no Raw Post Response HTML Currently Saved!" if !self[:post_html]

        self[:post_html] =~ Regexp.new( @search_string )
        @save_val = $1

        if @save_val
            do_save()
        else
            raise ActionError, "Cannot Find Regex: #{@search_string} in Current Raw Post Response HTML!"
        end

    end
end
