

class VariableMediator

    #mediator vars sent to this function
		#will be hash with the following structure
		#  :var_container =>  ex  :acct, :job_data
		#  EX:
		#  :job_data => {
		#			:data  => @job_data,
		#			:klass => JobDataVars
		# 	   }
		#  following containers will always be created on default
		#  even if they are not explicitly defined/passed into this init
		#  method....  :acct, :job_data, :temp

    attr_reader :var_objs

    def initialize( init_vars={} )

        @var_objs = {}

        load_default_var_containers(init_vars)
        load_initial_data( init_vars )

    end

    def load_default_var_containers(init_vars)
        #add in our default var containers that were not passed in
        DefaultVarConatainers.each do |default_var|

            next if init_vars.has_key?( default_var )
            init_vars[default_var] = {
                :data  =>   {},
                :klass =>   VariableContainer
            }

        end
    end

    def load_initial_data(init_vars)

        init_vars.each do |var_container, var_data|
            #set our default var container klass to VariableContainer
            var_data[:klass] ||= VariableContainer
            var_data[:data]  ||= {}
            @var_objs[var_container] = var_data[:klass].new( var_data[:data], var_container )
        end

    end

    def container_data( container )
        if @var_objs[container]
            @var_objs[container].data
        else
            raise EnviornmentError, "Cannot Retrieve Container Data! -- Var Container #{container.inspect} Does not Exist!"
        end
    end

    def clear_container( container )
        if @var_objs[container]
            @var_objs[container].clear()
        else
            raise EnviornmentError, "Cannot Save Container! -- Var Container #{container.inspect} Does not Exist!"
        end
    end

    def save_container( container, *args )

        if @var_objs[container]
            @var_objs[container].save( *args )
        else
            raise EnviornmentError, "Cannot Save Container! -- Var Container #{container.inspect} Does not Exist!"
        end

    end

    def save_all()
        #run our save code on all the Variable Containers
        @var_objs.each do |var_name, var_obj|
            var_obj.save
        end
    end

    

    def get_var_obj(attr)
        #get the var object handling this attribute
        found = @var_objs.find{ |var, var_obj| var_obj.can_handle?(attr) }
        found ? found.last : nil
    end

    def var_keys()
        @var_objs.keys.map{ |var_container| { var_container => @var_objs[var_container].var_keys }  }
    end

    def container_empty?(container)
      if @var_objs[container]
          @var_objs[container].empty?
      else
          raise EnviornmentError, "Unable to Determine if Conatiner is Empty! -- Var Container #{var_container.inspect} Does not Exist!"
      end
    end

    def add( var_hash, var_container, overwrite=true, reset_container=false )

        # if overwrite == true we run a merge!
        # on the @data in var container, else
        # we do a per key comparison on only add keys
        # that do not exists in @data currently

        #if reset_container == true
        #we replace the @data with the var_hash totally

        #raise error here if var_container doesn't exist!
        if @var_objs[var_container]
            @var_objs[var_container].add( var_hash, overwrite, reset_container )
        else
            raise EnviornmentError, "Unable to Add Variable: #{var_hash.inspect} -- Var Container #{var_container.inspect} Does not Exist!"
        end

    end

    #accessing methods
    def []( attr )
        #attempts to get the variable for the attribute send to this function,
        #returns the value on default
        var_obj = get_var_obj(attr)
        var_obj.nil? ? nil : var_obj[attr]
    end

    def []=( attr, val )
        #attempts to get the variable for the attribute send to this function,
        #returns the value on default

        var_obj = get_var_obj(attr)
        
        #set default var_obj to the :temp
        #var Container if not container was found with 
        #attr to set 
        var_obj ||= @var_objs[:temp]

        #do the actual set here
        var_obj[attr] = val
    end

end