

class Action

    include BotFrameWorkModules
    include SaverHelperModule

    def initialize( data={} )
        @data = data
        init()
        load_object_args( @data, false )
    end

    def init()
        #this function should be implemented on sub ACtions.
    end

    def save()
        #returns a hash that represents this action for easy loading later
        { :klass => self.class.to_s, :data  => @data }
    end

    def run()
        #this function should be implemented on sub ACtions.
        raise NotImplementedError
    end
end
