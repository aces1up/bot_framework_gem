

class ModifyVariable < Action

    def reg_obj()

        if @data[:do_escape]
            Regexp.new( Regexp.quote( @data[:search_for] ) )
        else
            Regexp.new( @data[:search_for] )
        end

    end

    def do_replace()

        @data[:replace_with] = '' if @data[:remove_match]

        return if !@data[:replace_with]

        replace_method = case @data[:replace_mode]
            when  :first_match ; :sub!
            when  :all_matches ; :gsub!
        else
            :sub!
        end

        var = @data[:modify_variable]
        replace_val = @data[:replace_with].empty? ? '' : solve_tag( @data[:replace_with] )

        debug(" Replacing With : #{replace_val.inspect}" )

        self[ var ].send( replace_method, reg_obj, replace_val )

    end

    def do_conversion

        @data[:conversion_mode] ||= :none
        return if @data[ :conversion_mode ] == :none

        info("Running Conversion on Variable : #{@data[ :conversion_mode ]}")
        var = @data[:modify_variable]

        self[ var ] = case @data[ :conversion_mode ]
            when :to_url        ; self[ var ].downcase.remove_whitespace.gsub( ' ', '-' )
            when :url_decode    ; CGI::unescape( self[ var ] )
        else
            self[ var ]  #<--- being paranoid here
        end

    end

    def run()

        var = @data[:modify_variable]

        raise ActionError, "Cannot Modify Variable, Variable: #{var.inspect} Does not Exist" if !self[ var ]

        @data[:search_for] ||= '.*'
       
        info(  "Modifying Variable: #{var.inspect} -- Current Value : #{self[var]}" )
        debug( "Using Regex Search : #{reg_obj.inspect}")

        do_replace
        do_conversion

        info("Variable After Modification : [  #{self[ var ]}  ] ")
   
    end
end
