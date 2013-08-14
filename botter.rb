
#set our default working directory from a global Var
raise "Botter Startup Error... No $working_directory Specified!" if $working_directory.nil?

RunningOnServer   =  Config::CONFIG['target_os'] =~ /linux/ ? true : false
WorkingDirectory  =  RunningOnServer ? "#{Dir.pwd}/" : $working_directory
if !defined?( PhantomJSEXE )
   PhantomJSEXE = "#{$working_directory}dependencies/lb_worker.exe"
end

puts "Running in Working Directory: #{$working_directory}"



#require 'rubygems'
require 'mechanize'
require 'singleton'
require 'thread_safe'
require 'yaml'
require 'logger'
require 'multipart_body'
require 'cgi'
require 'addressable/uri'
require 'securerandom'
require 'mail'

#our Enivornment
require 'enviornment/enviornment_helper'
require 'enviornment/enviornment_module'

#our logger
require 'logger/log_handler'

#our Thread Extensions
require 'thread/thread_extensions'
require 'threadpool/thread_pool_each'

#args helper
require 'args/args_helper'

#global Settings
require 'settings/settings_class'
require 'settings/global/global_wrapper'
require 'settings/global/global_class'

#our tag Handlers
require 'tags/tag_solver/tag_groups/file_handling_tags'
require 'tags/tag_solver/tag_groups/article_tags/article_tag_handler'
require 'tags/tag_solver/tag_groups/bio_tags'
require 'tags/tag_solver/tag_groups/default_tags_handler'
require 'tags/tag_solver/tag_solver_helper'
require 'tags/tag_solver/tags'
require 'tags/tag_solver/tag_solver_class'

#our Parsers
require 'parsers/raw_post_parser/packet_loader'
require 'parsers/raw_post_parser/multipart_parser/part_element_class'
require 'parsers/raw_post_parser/multipart_parser/mulit_part_parser_class'
require 'parsers/raw_post_parser/urlencoded_parser/urlencoded_parser_class'

require 'exceptions/exceptions_helper'


#our hardware helper
require 'hardware/os/os_resolver'
require 'hardware/os/arch_resolver'
require 'hardware/code/code_module'
require 'hardware/enviornment/enviornment_variables'
require 'hardware/browser/browser_helper'
require 'hardware/process/kill_phantom_js_module'
require 'hardware/process/process_helper'
require 'hardware/hardware_module'
require 'hardware/splash_update_module'
require 'hardware/extractor/extractor_class'
require 'hardware/dependancies/checksum_class'
require 'hardware/dependancies/directory_html_helper'
require 'hardware/dependancies/directory_link'
require 'hardware/dependancies/http_uri_stats'
require 'hardware/dependancies/downloader_class'

#Our Connections and Wrappers
require 'connection/elements/element_wrapper'
require 'connection/connection_wrapper'
require 'connection/connection'

#our utilities
require 'util/utility'
require 'util/file_utilities'

#content Parsers
require 'content_parsers/spinner/spinner_class'
require 'content_parsers/article_sanitizer_module'
require 'content_parsers/fetchers/default_fetcher'
require 'content_parsers/fetchers/dbase_fetcher'
require 'content_parsers/fetchers/ondisk_fetcher'

#our Connection Elements
require 'connection/elements/default_element'
require 'connection/elements/default_form'


require 'connection/conn_mediator/connection_error_handler'
require 'connection/conn_mediator/execute_fetch_call_module'
require 'connection/conn_mediator/execute_connector_call_module'
require 'connection/conn_mediator/connection_mediator'

#mech connections
require 'connection/connection_types/mechanize_connection/mechanize_connection_class'
#mech Elements
require 'connection/connection_types/mechanize_connection/elements/mechanize_default_element'
require 'connection/connection_types/mechanize_connection/elements/mechanize_form'

#easy Rider Connection
require 'connection/connection_types/easyrider_connection/easyrider_connection_class'
#easy rider elements
require 'connection/connection_types/easyrider_connection/elements/easyrider_default_element'
require 'connection/connection_types/easyrider_connection/elements/easyrider_form'
require 'connection/connection_types/easyrider_connection/elements/easyrider_input'



#exceptions
require 'exceptions/exceptions_custom'

#our Var Mediator
require 'variable_mediator/default_variable_container'
require 'variable_mediator/var_mediator_class'

#startup our enviornment here
require 'startup_enviornment'   #<--- this handles loading of our global settings

#require easy rider as it needs watir webdriver
#and that is setup via our dependancy downloader in our
#startup_enviorment above.
require 'easy_rider'


#Thread Pool
require 'threadpool/pool'
require 'threadpool/new_pool'


#captcha Handling
require 'captcha_services/image_fetchers/recaptcha_image_fetcher'
require 'captcha_services/image_fetchers/normal_image_fetcher'
require 'captcha_services/image_fetchers/snapshot_fetcher'
require 'captcha_services/image_fetchers/captcha_image_handler'

require 'captcha_services/captcha_service'
require 'captcha_services/decaptcher/decaptcher_solver'
require 'captcha_services/death_by_captcha/death_by_captcha_validator'
require 'captcha_services/death_by_captcha/death_by_captcha_solver'
require 'captcha_services/captcha_mediator'

#profile Generation
require 'profiles/profile_creation_class'

#Caches
require 'cache/proxy/proxy_tester'
require 'cache/proxy/proxy_sync_modules'
require 'cache/proxy/proxy_cache'



#our Actions
require 'actions/action_helpers/save_vars_helper'
require 'actions/action_helpers/element_vars_helper'
require 'actions/default_action'
require 'actions/action_types/goto_page'
require 'actions/action_types/click_action'
require 'actions/action_types/set_element'
require 'actions/action_types/iframe_action'
require 'actions/action_types/verify_string'
require 'actions/action_types/save_email_variable'
require 'actions/action_types/save_variable'
require 'actions/action_types/save_element_attribute'
require 'actions/action_types/save_regex'
require 'actions/action_types/hover_action'
require 'actions/action_types/verify_email'
require 'actions/action_types/verify_element'
require 'actions/raw_post/header_parser_module'
require 'actions/raw_post/post_body_parser'
require 'actions/raw_post/raw_post_action'



