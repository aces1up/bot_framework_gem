
#this file handles setting up of local enviornment directory structure on host
#machine.


#setup our Display Gui Variable
$display_gui ||= false
Display_GUI = $display_gui

require 'rbconfig'
#setup our working directory here

#

#create our directory structure here

TagsDir               =   "#{WorkingDirectory}tag_lists/"
ContentDir            =   "#{WorkingDirectory}content/"
BioSummaryDir         =   "#{ContentDir}bio/summary/"
BioDirectory          =   "#{WorkingDirectory}bio/"
LogsDir               =   "#{WorkingDirectory}logs/"
PacketDirectory       =   "#{WorkingDirectory}packets/"
CaptchaDirectory      =   "#{WorkingDirectory}captchas/"
HTMLDirectory         =   "#{WorkingDirectory}html/"
ScreenShotDirectory   =   "#{WorkingDirectory}screenshots/"



create_dir( WorkingDirectory )
create_dir( TagsDir )
create_dir( BioDirectory )
create_dir( PacketDirectory )
create_dir( CaptchaDirectory )
create_dir( LogsDir )
create_dir( ContentDir )
create_dir( HTMLDirectory )
create_dir( ScreenShotDirectory )


#our Constants
require 'botter_constants'

#the global settings file used for storing settings
SettingsFile       =   "#{WorkingDirectory}settings.txt"

#setup our settings file if it doesn't exist
GlobalSettings.instance.merge_settings( DefaultBOTSettings )

#Setup our Constants here from GlobalSettings
GlobalSettings.instance.set_constants

=begin
class DoDownloadBotter

    include BotFrameWorkModules

    def initialize()
        @download_thread = nil

        if DoDepenancyDownloads
           @download_thread = Thread.new { start }
           join()
        end
    end

    def start()
      begin

        init_vars
        set_log_handler( DownloaderLogHandler ) if defined?( DownloaderLogHandler )
        
        url = 'http://50.116.27.156:8080/bot_deps/startup/'
        info "Downloading Dependancies from : #{url}"
        DependancyDownloader.new( url, WorkingDirectory ).download

      rescue => err
          puts("Download Dependancy Error : #{err.message}\n#{err.backtrace.join("\n")}")
      end
    end

    def join()
        @download_thread.join
    end

end

DoDownloadBotter.new
=end

include DownloaderBotWrapper
url = 'http://50.116.27.156:8080/bot_deps/startup/'
log_handler = defined?( DownloaderLogHandler ) ? DownloaderLogHandler : nil
bot_download( log_handler, url )