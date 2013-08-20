
class BotDownloader
     include BotFrameWorkModules

     def initialize( log_handler )
          init_vars
          set_log_handler( log_handler )
     end

     def raise_download_err( err )
         error("Dependancy Error : #{err.message}\n#{err.backtrace.join("\n")}")
     end

     def do_bot_download( url )

        begin

            info "Downloading Dependancies from : #{url}"
            DependancyDownloader.new( url, WorkingDirectory ).download

        rescue => err
            raise_download_err( err )
        end

     end

     def do_mirror( local_dir, remote_url, mirror_dir )

        begin

            info "Mirroring Files from : #{remote_url}"
            helper = DirectoryMirror.new( local_dir, remote_url )
            helper.mirror( mirror_dir )

        rescue => err
            raise_download_err( err )
        end

     end
end


module DownloaderBotWrapper

    def bot_download( log_handler, url )
        download_thread = Thread.new { BotDownloader.new( log_handler ).do_bot_download( url )  }
        download_thread.join
    end

    def bot_mirror( log_handler, local_dir, remote_url, mirror_dir )
        download_thread = Thread.new { BotDownloader.new( log_handler ).do_mirror( local_dir, remote_url, mirror_dir  )  }
        download_thread.join
    end

end
