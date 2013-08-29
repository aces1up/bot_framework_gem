

class SetElement < Action

    def init()
        init_element_vars
    end

    def run()

        found = VerifyElement.new( @data ).run

        if !found
            info "Element not Found, not Setting..."
            return
        end

        solved = solve_tag( @data[:set_value] )
        info "Setting Element with Value : #{solved.inspect}"

        found.set( solved )
    end

end
