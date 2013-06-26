

module ProxySync

    def line_to_proxy(proxy_line)
        proxy_keys = [:ip, :port, :user, :pass]
        proxy = proxy_line.split(':').to_h( proxy_keys )
        proxy[:port] = proxy[:port].to_i
        proxy
    end

    def load_cache_from_file()
        cache = IO.read( ProxyFile ).split("\n").map{ |proxy_line|

              proxy_hash = line_to_proxy( proxy_line )

              #add our proxy_fail and success count here
              proxy_hash[:validated] = :not_validated

              [ proxy_hash[:ip], proxy_hash ]
        }.flatten
        Hash[ *cache ]
    end 

end
