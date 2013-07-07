

class SetElement < Action

    def init()
        init_element_vars
    end

    def run()

        found = VerifyElement.new( @data ).run

        solved = solve_tag( @data[:set_value] )
        info "Setting Element with Value : #{solved.inspect}"

        found.set( solved )
    end

end
