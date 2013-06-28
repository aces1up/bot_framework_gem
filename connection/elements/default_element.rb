

class Element

    include BotFrameWorkModules

    attr_reader :handle

    def initialize( handle )
        @handle = handle      #<--- the handle to the underlying element
    end

end
