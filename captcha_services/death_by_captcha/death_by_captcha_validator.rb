

module DeathByCaptchaValidator

    def has_balance?(parsed_result)
        return false if !parsed_result.is_a?(Hash)
        parsed_result.has_key?('balance')
    end

    def balance_post_data(username, password)
        post_data = MultipartBody.new(
            {
              :username => "#{username}\r\n",
              :password => "#{password}\r\n"
            },

            '---------------------------9374110204596'
        )
        post_data
    end

    def validated?( username, password )
      #this is a synchronous function and should
      #only be called from our global setting captcha
      #validation routines.
      #should just return true if no error
      #false if there was an error


          val_agent = Mechanize.new
          val_agent.read_timeout = 60  #set the agent time out
          #val_agent.set_proxy('127.0.0.1', 8888)   #<--- used just for testing

          @server_url = 'http://api.dbcapi.me/api/user'
          post_data   = balance_post_data( username, password )
          head        = init_headers( post_data )

          #puts "server url : #{@server_url}"
          #puts "post_data  : #{post_data.to_s}"
          #puts "headers    : #{head.inspect}"

      begin

          val_agent.post( @server_url, post_data.to_s, head )

          result = val_agent.page.body.to_s
          parsed_result = parse_result(result)
          #puts "parsed result : #{parsed_result.inspect}"

          has_balance?(parsed_result)

      rescue Mechanize::ResponseCodeError => err

          case err.message
              when '502 => Net::HTTPBadGateway'
                  #puts "got bad gateway rescue"
                  @retry += 1
                  @retry <= 20 ? retry : false
=begin
              when '403 => Net::HTTPForbidden'
                  puts "403 error"
                  result = val_agent.page.body.to_s
                  parsed_result = parse_result(result)
                  puts "Net Forbidden error -- Parsed result: #{parsed_result.inspect}"
                  has_balance?(parsed_result) ? true : false
=end
          else
              false
          end


      rescue Timeout::Error
          false

      rescue => err
          #puts err.class
          #puts err.message
          #puts err.backtrace
          false
      end

    end
end
