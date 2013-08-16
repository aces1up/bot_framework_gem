
class BotDownloader
     include BotFrameWorkModules

     def do_bot_download( log_handler, url )

        begin
            init_vars
            set_log_handler( log_handler )

            info "Downloading Dependancies from : #{url}"
            DependancyDownloader.new( url, WorkingDirectory ).download

        rescue => err
          error("Download Dependancy Error : #{err.message}\n#{err.backtrace.join("\n")}")
        end

     end
end


module DownloaderBotWrapper

    def bot_download( log_handler, url )
        download_thread = Thread.new { BotDownloader.new.do_bot_download( log_handler, url )  }
        download_thread.join
    end

end
