
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
                if do_retry?
                    warn("Got Click Fail -- Retrying in #{@retry_interval} Seconds.. [ #{@retry_count} / 5 ]")
                    sleep( @retry_interval )
                    retry
                else
                    raise
                end
            else
                #re-raise the error here it its not a click error
                #we know how to rescue.
                raise
            end

        end
    end

end
