

module GlobalWrapper

    def global_var( var )
        GlobalSettings.instance.get_var( var )
    end

end
