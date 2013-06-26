

module ArgsHelper

    def load_object_args(args=nil, do_delete=true, load_element_args=[])

        if args and !args.is_a?(Hash) then return end

        args = @args if !args

        args.each do |key, value|

            if respond_to?("#{key}=", true)

              #puts "[ Load Args: Setting -- #{key.inspect} = #{value.inspect} ]"

              #check to see if this key variable should
              #also load variables to the object this module is included in

              if load_element_args.include?(key) 
                  #puts("Loading Args for Sub Key -- [Key: #{key.inspect}] -- [Key Value: #{value.inspect}]")
                  load_object_args(value)
              end

              send("#{key}=", value)

              args.delete(key) if do_delete
            end

        end
    end

    def load_object_with_yaml( filename=nil )
        filename ||= @filename
        #will load yaml from a file and then attempt to
        #load the args into object instance variables.
        data = load_yaml_from_file( filename )
        load_object_args( data ) if load_object
        data
    end

end
