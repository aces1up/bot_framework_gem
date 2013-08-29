
class ClickElement < Action

    def init()
        init_element_vars
    end

    def do_retry?()
        @retry_count <= 5
    end

    def run()
        found = VerifyElement.new( @data ).run

        if !found
            info "Element not Found, not Clicking"
            return
        end

        @retry_count    = 0
        @retry_interval = 0.3

        begin

            @data[:click_method] ||= :native

            info "Clicking Found Element: #{found.obj_info} -- Click Method: #{@data[:click_method]}"

            case @data[:click_method]
                when   :native      ;  found.click
                when   :js_click    ;  found.fire_event('click')
            end

            if @data[:sleep_timer]
                info("Sleeping for #{@data[:sleep_timer]} Seconds After Click...")
                sleep( @data[:sleep_timer] )
            end

        rescue Selenium::WebDriver::Error::UnknownError => err

            if err.message.include?('Click succeeded but Load Failed')
                #if do_retry?
                #    warn("Got Click Fail -- Retrying in #{@retry_interval} Seconds.. [ #{@retry_count} / 5 ]")
                warn 'Got Click Fail from Browser.. But Page Probably Still has loaded...'
                #    sleep( @retry_interval )
                #    retry
            else
                raise
            end

        end
    end

end
