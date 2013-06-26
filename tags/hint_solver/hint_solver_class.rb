

#parses an array of hints or perhaps a
#string containing key_value pairs in
#url encoded protocol form into hint objects.

#we can then send a element object into this
#hint solver object to get the tag solver object
#already loaded with the tag args needed to solve the tag.

#protocol is as follows
#    hint=username&match=exact&tag=username
#
#    Example with Tag Args
#        hint=captcha&tag=captcha?search_for=captchaimage1|captchaimage2
#    Extracted is Equal TO:
#        hint       = 'captcha'
#        tag        = '%captcha%'
#        tag_args   = { :search_for => [ 'captchaimage1', 'captchaimage2' ] }
#

class HintSolver

    def initialize(hints=[])
        @hint_objs = []    #<---- array of Hint Objects

        init_hints(hints)
    end

    def init_hints(hints)
        hints.each do |hint_str| add_hint(hint_str) end
    end

    def extract(param)
        #extracts the hint variable and options from the param sent
        #ex : hint=username ==> [ 'hint', 'username' ]
        param.split('=', 2)
    end

    def add_hint(hint_str)
        #adds a single hint object using the above protocol
        hint_obj_args = Hash[ hint_str.split('&').map{ |param|
            #extract our params here
            #so that each = value/pair is parsed into a hash key/pair
            extract(param)
          }
        ]

        @hint_objs << Hint.new( hint_obj_args )
    end
    
    def form_hints_with(tag)
        #returns all hint objects that has a tag with the one specified
        @hint_objs.find_all{ |hint| tag == hint.tag.gsub('%','') }
    end

    def find_form( conn )
        #this will attempt to find a form on page from the hints provided
        #only will use the hints with tag_name %select_form%

        #protocol for this line might be something like this
        #hint=na&tag=select_form?match_type=action?args=submit
        #hint=na&tag=select_form?match_type=max_fields

        select_form_hints = form_hints_with('select_form')

        found = select_form_hints.find{ |hint_obj| hint_obj.find_form( conn ) }

        found ? found.field : false
    end

    def solve( field )
        #this will attempt to find the correct tag to to fill out using
        #the field sent and the hint_objects loaded.

        found = @hint_objs.find{ |hint_obj| hint_obj.solve( field ) }

        found ? found.tag_solver : false
    end
end

