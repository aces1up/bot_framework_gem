

class EasyriderOption < EasyriderDefault

    def value
        @element.value
    end

    def text()
        @element.text
    end
    
    def select
        @element.select
    end

    def option_info()
        "[ Text: #{text} ] -- [ Value: #{value} ]"
    end
    
end
