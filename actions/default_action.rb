

class Action

    include BotFrameWorkModules
    include SaveVarsHelper
    include ElementVarsHelper

    def initialize( data={} )

        @data = data
        init()
        load_object_args( @data, false )

    end

    def init()
        #this function should be implemented on sub ACtions.
    end

    def to_disk()
        #returns a hash that represents this action for easy loading later
        { :klass => self.class.to_s, :data => @data }
    end

    def run()
        #this function should be implemented on sub ACtions.
        raise FunctionNotImplemented
    end
end
