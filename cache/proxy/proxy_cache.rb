

class ProxyCache

    include Singleton
    include ProxySync
    include ProxyTester

    attr_reader :cache

    def initialize()
        @cache = ThreadSafe::Hash.new       #cache of our Proxies
                                            #structure is :
                                            #  {
                                            #      :ip
                                            #      :port
                                            #      :user
                                            #      :pass
                                            #      :last_used => 0
                                            #  }
                                            #

        @last_reload = 0                    #<---- last timestamp we reloaded this cache.

        @lock = Mutex.new

        @test_threads = nil
        @test_jobs    = Queue.new
    end

    def update_gui()
        return if !Display_GUI

        #this is used inside our bot GUI functions
        #as a monkey patch to display GUI
        #info for this proxy table.
    end

    def time_to_reload()
        ( @last_reload + ProxyCacheReloadInterval) - Time.now.to_i
    end

    def do_reload?()
        return true if @last_reload == 0
        ( Time.now.to_i - @last_reload ) >= ProxyCacheReloadInterval
    end

    def clear_cache()
        @cache = ThreadSafe::Hash.new  #<---- clear out our current cache
    end

    def delete_proxy( ip )
        @lock.synchronize {
            @cache.delete( ip )
        }
    end

    def load_proxies()
        clear_cache

        MaxProxytoLoadPerInterval.times do
            proxy = line_to_proxy( rand_file_line( ProxyFile ) )
            proxy[:validated] = :not_validated
            next if @cache[proxy[:ip]]

            @cache[proxy[:ip]] = proxy
        end

        #@cache = load_cache_from_file
    end

    def reload()
        @last_reload = Time.now.to_i
        load_proxies

        init_test_threads()

        wakeup_test_threads
        update_gui()
    end
    
    def random_proxy( cache=nil )
        #retrieves a random proxy from the cache.
        cache ||= @cache
        cache[ cache.keys.sample ]
    end

    def get_proxy( get_success_only=false )


        return :local if !UseProxyCache
        return :local if !ProxyFile

        @lock.synchronize {
            reload if do_reload?()
            raise CacheError, "Attempting to get New Proxy but Cache is Empty!" if @cache.empty?

            has_verified? ? random_proxy( all_validated ) : random_proxy
        }
    end
end


