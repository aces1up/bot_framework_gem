
#fetches content based on the fetch type we need

class ContentFetcher

    include BotFrameWorkModules
    include ArticleSanitizerModule
    
    def initialize()
        @fetcher_obj = nil  #<--- the content fetcher we use for getting the content
        @content     = nil
    end

    def raise_exception( msg )
        raise ContentError, msg
    end

    def spin_content()
        @content = Spinner.new.spin( @content )
    end

    def fetch()
        #this function should return the content body
        #fetched using this function
        raise FunctionNotImplemented
    end

end
