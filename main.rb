
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
    include ProcessHelper

     def initialize()
        @connection_class = EasyriderConnection
        #@connection_options = {
        #      :browser_type => :firefox
        #}
     end

     def test()

        task_kill_process_now( 'phantomjs.exe' )
        
        #result = `ping www.google.com`
        #puts result.inspect


        init_vars
        get('http://linkwheelbandit.com/files/iframe.htm')
        #puts image_urls.inspect
        #puts "#{image_exists?( 'down-artgrtrrow.png' ).inspect}"
        #puts cookies.inspect
        #frames = current_connection_handle.elements_for_tag_name( :frame )
        #sub_elements = frames.first.children_for_element
        #puts sub_elements.length
        #second = sub_elements.first.children_for_element
        #puts second.length
        #puts second.inspect

        sym = :frame
        method = "#{sym.to_s}s".to_sym
        frames = current_connection_handle.conn.send( method )

        input_no_frame = current_connection_handle.conn.input(:id => 'weebly-name')
        puts "no frame: #{input_no_frame.inspect} -- #{input_no_frame.exists?.inspect}"
        #' id weebly-name'
        frame = frames.to_a.first
        input = frame.input(:id => 'weebly-name')
        puts "with frame: #{input.inspect} -- #{input.exists?.inspect}"

     end
end

LoginTest.new.test
puts "done"



