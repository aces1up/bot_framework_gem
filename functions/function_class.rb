

class Function

    include BotFrameWorkModules
    include FunctionHelperModule

    attr_accessor :assigned_to, :run_mode, :run_mode_args, :actions

    def initialize( data={} )    #<--- data send here should only be a yaml hash

        @assigned_to     = nil                         #What this is assigned to :create / :submit etc..etc..
        @run_mode        = :normal                     #Different modes for running this function

        @run_mode_args   = { :stop_on_fail => false }         #Various Run mode args to associate with function
                                                              #  :stop_on_fail = true  If set to true we kill other
                                                              #                        functions after this one.
        @actions         = []
        @exclude_save_vars = [:actions]

        init()

        load_object_args( data )
        #initialize_actions()                            #<--- converts the data from the action hash into an actual action object
    end

    def init()
        #subclasses on lower functions
    end

    def save()
        #saves this function to a hash for easy loading later.
        #{:assigned_to => @assigned_to, :run_mode => @run_mode, :run_mode_args => @run_mode_args, :actions => @actions}
        save_hash = object_to_hash()
        save_hash[:actions] = @actions.map{ |action| action.save}
        save_hash
    end

    def initialize_actions()
        @actions.map! do |action_hash| create_action( action_hash ) end
    end

    def create_action( load_hash )
        Kernel.const_get( load_hash[:klass] ).new( load_hash[:data] )
    end

    def run()

        info "Running...."

        @actions.each do |action|
            #need to enclose this in a rescue and determine
            #how we handle erros based on @run_mode
            action.run
        end
    end

end

