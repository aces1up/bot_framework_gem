
class ClickElement < Action

    def init()
        init_element_vars
    end

    def do_retry?()
        @retry_count <= 5
    end

    def run()
        found = VerifyElement.new( @data ).run
        info "Clicking Found Element: #{found.obj_info}"

        @retry_count    = 0
        @retry_interval = 0.3

        begin

            found.click

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
