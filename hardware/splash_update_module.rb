
module SplashUpdateModule

    def update_new( msg )
        info( msg )
    end

    def update( msg )
        #tells who ever receives this message to update
        #on the same line as previous message
        info( "~~#{msg}" )
    end

end
