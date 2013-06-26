

class GotoPage < Action

    attr_accessor :url

    def init()
        @url = nil
    end

    def run()

        url_solved = solve_tag( @url ) 
        info "Action Fetching : #{url_solved}"
        get( url_solved )

    end

end
