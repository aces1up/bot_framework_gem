
#need to ensure we set our working directory before
#requiring our botter framework.

$working_directory = 'c:/lwb-trainer/'
$display_gui       = false


#ACTIVE RECORD REQUIRES
  $LOAD_PATH << 'c:\jruby-gem-repository\gems\activerecord-3.2.13\lib'
  $LOAD_PATH << 'c:\jruby-gem-repository\gems\activesupport-3.2.13\lib'
  #$LOAD_PATH << 'c:\jruby-gem-repository\gems\activerecord-jdbc-adapter-0.9.7-java\lib'
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\activerecord-jdbc-adapter-1.2.9\lib'
  $LOAD_PATH << 'c:\jruby-gem-repository\gems\i18n-0.6.1\lib'
  $LOAD_PATH << 'c:\jruby-gem-repository\gems\activemodel-3.2.13\lib'
  $LOAD_PATH << 'c:\jruby-gem-repository\gems\arel-3.0.2\lib'
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\jdbc-mysql-5.1.25\lib'

  $LOAD_PATH << 'C:\jruby-gem-repository\gems\multi_json-1.3.6\lib'


  #MECHANIZE REQUIRES
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\nokogiri-1.5.0-java\lib'
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\net-http-persistent-2.8\lib'
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\domain_name\lib'
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\mechanize-2.5.1\lib'
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\multipart_body\lib'
  $LOAD_PATH << 'c:\jruby-gem-repository\gems\net-http-digest_auth-1.1.1\lib'
  $LOAD_PATH << 'c:\jruby-gem-repository\gems\addressable-2.2.6\lib'
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\mime-types-1.18\lib'
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\unf-0.0.5-java\lib'
  $LOAD_PATH << 'c:\jruby-gem-repository\gems\ntlm-http-0.1.1\lib'
  $LOAD_PATH << 'c:\jruby-gem-repository\gems\webrobots\lib'

  #THREAD SAFE REQUIRES
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\thread_safe-0.0.3\lib'

  #Botter Gem
  $LOAD_PATH << 'C:\jruby-gem-repository\gems\botter-0.0.1\lib'


  #PROLLY SHOULDN'T HAVE THIS IN THIS GEM AFTER DONE TESTING
  $LOAD_PATH << 'C:\Ruby Code\easy_rider\lib'

require 'botter'

PhantomJSEXE = 'c:/temp/phantomjs.exe'




class LoginTest

    include BotFrameWorkModules
    include HardwareHelper

     def initialize()
        @connection_class = EasyriderConnection
        #@connection_options = {
        #      :browser_type => :firefox
        #}
     end

     def test()

        #kill_process(  'phantomjs.exe', true )
        
        #result = `ping www.google.com`
        #puts result.inspect
        #puts "os : #{os.inspect}"

        init_vars
        #get('http://linkwheelbandit.com/files/iframe.htm')
        #hard_kill

        #puts ProfileData.new.get_profile.inspect
        #var = global_var( :content_location )
        #puts "location : #{var.inspect}"

        #puts self[:article_title].inspect
        #puts self[:article_text].inspect
        title  = solve_tag( '~~article_title~~' )
        title2 = solve_tag( '~~article_title~~' )
        puts "title #{title}"
        #make sure title2 == title should not try and
        #get a new title
        puts "title2: #{title2}"
        puts "text : #{solve_tag('~~article_text~~')}"



     end
end

LoginTest.new.test
puts "done"



