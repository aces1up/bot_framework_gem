

module ProxyTester

    def validated_proxy?(proxy)
        !proxy[:validated].nil? and proxy[:validated] == :success
    end

    def has_verified?()
        @cache.any?{ |ip, proxy_hash| validated_proxy?( proxy_hash )  }
    end

    def all_validated()
        found = @cache.find_all{ |ip, proxy_hash| validated_proxy?(proxy_hash) }.flatten
        return nil if found.empty?
        Hash[ *found ]
    end

    def next_unverified_proxy()
      @lock.synchronize {
        @cache.find{ |ip, proxy_hash| proxy_hash[:validated].nil? or proxy_hash[:validated] == :not_validated }
      }
    end

    def proxy_untested_count()
        @cache.count{ |ip, proxy_hash| !proxy_hash[:validated].nil? and proxy_hash[:validated] == :not_validated }
    end

    def test_proxy( proxy )

        timeout = 0.3
        sock = Socket.new( Socket::PF_INET, Socket::SOCK_STREAM, 0 )

        if timeout
            secs = Integer(timeout)
            usecs = Integer((timeout - secs) * 1_000_000)
            optval = [secs, usecs].pack("l_2")
            sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval
            sock.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval
        end

      begin
          sock.connect( Socket.sockaddr_in( proxy[:port], proxy[:ip] ) )
          sock.close
      rescue Errno::EADDRINUSE => err
          return false
      end

      true

    end

    def wakeup_test_threads()
        @test_threads.each do |thr|
          thr.wakeup
        end
    end

    def add_test_thread()
        @test_threads.push Thread.new {
            loop do
                begin

                     proxy = next_unverified_proxy

                     if proxy

                        proxy = proxy.last
                        proxy[:validated] = :testing

                        is_valid = test_proxy( proxy )

                        #puts "[#{proxy_untested_count}] -- [#{@cache.length}] -- Tested Proxy: #{proxy[:ip]}:#{proxy[:port]} -- Passed: #{is_valid.inspect}"

                        if is_valid
                            proxy[:validated] = :success
                        else
                            proxy[:validated] = :failed
                            delete_proxy( proxy[:ip] )
                        end

                        update_gui()

                     else
                        #no more proxies to load so stop thread
                        #until next reload
                        Thread.stop
                     end


                rescue => err
                     err_msg = "[Proxy Cache Error]:  #{err.message}"
                     excep = CacheError.new( err_msg )
                     excep.set_backtrace( err.backtrace )
                     excep.report
                end
            end
        }
    end

    def init_test_threads()
        return if @test_threads

        @test_threads = []
        MaxProxyTestThreads.times do add_test_thread end
    end

end
