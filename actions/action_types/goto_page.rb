

class GotoPage < Action

    attr_accessor :url

    def init()
        @url = nil
    end
    
    def init_images()
        @connection_options[:use_images] = @data[:use_images]
    end

    def init_user_agent()
        @connection_options[:user_agent] = @data[:user_agent]
    end

    def init_connection_options()
        @connection_options ||= {}
        init_images()
        init_user_agent()
    end

    def run()

        raise ActionError, 'Cannot Fetch Page, no URL Specified!' if !@url or @url.empty?

        init_connection_options()
        clear_cookies if @data[:clear_cookies]

        url_solved = solve_tag( @url ) 
        info "Action Fetching : #{url_solved}"
        get( url_solved )

    end

end
