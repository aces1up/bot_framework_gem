
#this file handles setting up of local enviornment directort structure on host
#machine.


#setup our Display Gui Variable
$display_gui ||= false
Display_GUI = $display_gui

require 'rbconfig'
#setup our working directory here

#set our default working directory from a global Var
raise StartupError, "Botter Startup Error... No $working_directory Specified!" if $working_directory.nil?

RunningOnServer = case Config::CONFIG['target_os']
      when 'linux'  ;  true
else
      false
end

WorkingDirectory = RunningOnServer ? "#{Dir.pwd}/" : $working_directory
puts "Running in Working Directory: #{$working_directory}"

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
GlobalSettings.instance.settings.each do |setting_var, val|
    begin
        Object.const_set( setting_var.to_s, val )
    rescue ; end
end


