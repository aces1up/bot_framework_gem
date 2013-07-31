
module BotFrameWorkModules
    include ArgsHelper
    include Enviornment
    include ConnectionWrapper
    include TagSolverHelper
    include LogHandler
    include GlobalWrapper
end

class Class
  def subclasses
    result = []
    ObjectSpace.each_object(Class) { |klass| result << klass if klass < self }
    result
  end
end

class Hash
      def sample()
        self[ self.keys.sample ]
      end

      def set_constants()
          each do |key, val|

              begin  Object.send( :remove_const, key.to_s )   ; rescue ; end
              begin  Object.const_set( key.to_s, val )      ; rescue ; end
          end
      end

      def all_keys_are_integers?()
          keys.all?{ |key| key.is_a?(Fixnum) or ( key.is_a?(String) and key.is_integer? ) }
      end

      def prepend_keys( pre_str )
          Hash[ self.map{ |k, v| [ "#{pre_str}#{k.to_s}".to_sym, v] } ]
      end

      def prepend_keys!( pre_str )
          replace( prepend_keys( pre_str ) )
      end

      #def prepend_keys!( pre_str )
      #    self.each { |k, v| self[k] = v.upcase }
      #end

    def to_rehash
        #collects all keys that have integers on the end of their
        #keys and creates a new subhash from them inside this hash
        self.inject( {} ) { | h, (key, val) |
          if key.to_s[-1].is_integer?
            keyindex = key.to_s[-1].to_i
            keyname  = key.to_s[0..-2].to_sym
            h[ keyname ] ||= {}
            h[ keyname ][ keyindex ] = val
          else
            h[key] = val
          end
          h
        }
    end

    def from_rehash()
        self.inject( {} ) { | h, (key, val) |

          if val.is_a?(Hash) and val.all_keys_are_integers?
            h.merge!( val.prepend_keys( key ) )
          else
            h[key] = val
          end
          h
        }
    end
end

class String

  def truncate_words( num_words )
      self.include?(' ') ? self.split(' ')[0..num_words].join(' ') : self
  end

  def is_integer?
      !!(self =~ /^[-+]?[0-9]+$/)
  end

  def strip_non_letters
      self.gsub(/[^a-zA-Z]/i, ' ')
  end

  def remove_whitespace
      self.gsub(/\s+/, ' ').strip
  end

  def sanitize_title
      strip_non_letters.remove_whitespace
  end

  def remove_non_ascii(replacement="")
      self.gsub!(/[\x80-\xff]/,replacement)
  end

  def to_utf8( )
      self.encode( 'UTF-8', :invalid => :replace, :undef => :replace, :replace => '' )
  end

  def indices( e )
      start, result = -1, []
      result << start while start = ( self.index e, start + 1 )
      result
  end

  def indices_start_end( e )
      match_all( e ).map{ |match| [ match.begin(0), match.end(0)-1 ] }
  end

  def match_all(regex)
      if block_given?
        scan(regex) { yield $~ }
      else
        enum_for(:scan, regex).map { $~ }
      end
  end



  def is_float?
    # The double negation turns this into an actual boolean true - if you're
    # okay with "truthy" values (like 0.0), you can remove it.
    !!Float(self) rescue false
  end

  def cap_words
    self.split(' ').map {|w| w.capitalize }.join(' ')
  end

  def word_count
      self.split(' ').length
  end

end

class Fixnum
  def negative?()
      self < 0
  end
end

class Numeric
  def percent_of(n)
    (self.to_f / n.to_f * 100.0).to_i
  end
end


class Array
   def to_h( keys )
       Hash[ *keys.zip(self).flatten ]
   end
end

module Kernel
    def obj_info
        "#{self.class.to_s} : #{self.__id__}"
    end

    def object_to_hash(exclude_vars = nil)
        #attempts to save all the instance variables of an object and values
        #to a hash, if there is an array sent with exclude vars, it will not save
        #those to the returned hash.
        exclude_vars = @exclude_save_vars
        exclude_vars ||= []
        exclude_vars << :exclude_save_vars

        instance_variables_symbol.reject{ |key, value| exclude_vars.include?(key) }
    end
end

def get_constant( const )
    begin
        Kernel.const_get( const )
    rescue ; nil ; end
end

def convert_val(value)
    case value
        when  'true'   ; true
        when  'false'  ; false
    else
        value
    end
end

def deep_copy(o)   Marshal.load(Marshal.dump(o)) end


def param_to_arr(param)
    #converts something like captchaimage1|captchaimage2 to array
    #or just returns param if there is no | seperator
    param.include?('|') ? param.split('|').map{|val| convert_val(val) } : convert_val(param)
end

def param_to_hash(param)
    #search_for=captchaimage1|captchaimage2  ===> { :search_for => ['captchaimage1', 'captchaimage2'] }
    Hash[ param.split('=')[0].to_sym, param_to_arr( param.split('=')[1] ) ]
end

def time()
    Time.now.strftime("%H:%M %p")
end

def dbase_open_connections
    ActiveRecord::Base.connection_pool.connections.length
end

def checkin_dbase( thread=nil )
    thread ||= Thread.current
    ActiveRecord::Base.connection_pool.release_connection( thread.object_id )
end

def active_connection?()
    ActiveRecord::Base.connection_pool.active_connection?
end

def clear_stale_dbase
    ActiveRecord::Base.connection_pool.clear_stale_cached_connections!
end

def alert_pop( message, title=nil )
    title = "LinkWheel Bandit Alert!" if !title
    javax.swing.JOptionPane.show_message_dialog(nil, message, title, javax.swing.JOptionPane::DEFAULT_OPTION)
end

def alert_pop_err( err, msg=nil )
    msg ||= "Error: "
    alert_pop("#{msg} -- #{err.class.to_s} -- #{err.message}\n#{err.backtrace.join("\n")}")
end

def dump_error_to_console( err, msg=nil )
    msg ||= "Error: "
    puts("#{msg} -- #{err.class.to_s} -- #{err.message}\n#{err.backtrace.join("\n")}")
end

def get_yes_no(title, dialog_text)
      result = JOptionPane.showConfirmDialog(
               nil,
               dialog_text,
               title,
               JOptionPane::YES_NO_OPTION)

      result == 0 ? true : false
end

def display_time( total_seconds )
    total_seconds = total_seconds.to_i

    days = total_seconds / 86400
    hours = (total_seconds / 3600) - (days * 24)
    minutes = (total_seconds / 60) - (hours * 60) - (days * 1440)
    seconds = total_seconds % 60

    display = ''
    display_concat = ''
    if days > 0
      display = display + display_concat + "#{days}d"
      display_concat = ' '
    end
    if hours > 0 || display.length > 0
      display = display + display_concat + "#{hours}h"
      display_concat = ' '
    end
    if minutes > 0 || display.length > 0
      display = display + display_concat + "#{minutes}m"
      display_concat = ' '
    end
    display = display + display_concat + "#{seconds}s"
    display
end
