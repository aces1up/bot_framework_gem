

class VariableContainer

    include LogHandler

    attr_accessor :data

    def initialize( load_data={}, name=:unknown )
        @data = load_data
        @name = name
    end

    def clear()
        @data = {}
    end

    def empty?()
        @data.empty?
    end

    def can_handle?(attr)
        #returns true if this variable container is handling the attribute / variable passed in
        @data.has_key?(attr)
    end

    def var_keys()
        @data.keys
    end

    def [](attr)
        @data[attr]
    end

    def []=(attr, val)
        @data[attr] = val
    end

    def add( var_hash, overwrite=true, reset_container=false )

        if reset_container
            @data = var_hash
        else
            @data.merge!( var_hash ){ |key, v1, v2|
               overwrite ? v2 : v1
            }
        end

    end

    def load()
        #this should be subclassed on lower classes
    end

    def save( filename=nil )
        #this should be subclassed on lower classes
        return if !filename

        info("Saving Container -- [#{@name.inspect}] to --> #{filename}")
        write_data_to_yaml_file( filename, @data )

    end

end
