

class EasyriderSelectlist < EasyriderDefault

    def options
        wrap( @element.options.to_a, :options, 'Easyrider' )
    end

end
