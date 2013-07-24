
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
end

class String

  def truncate_words( num_words )
      self.include?(' ') ? self.split(' ')[0..num_words].join(' ') : self
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
