
#fetches content based on the fetch type we need

class ContentFetcher

    def initialize()
        @fetcher_obj = nil  #<--- the content fetcher we use for getting the content
    end

    def raise_exception( msg )
        raise ContentError, msg
    end

    def fetch()
        #this function should return the content body
        #fetched using this function
        raise FunctionNotImplemented
    end

end
