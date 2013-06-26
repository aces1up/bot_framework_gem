

class Hint

    include ArgsHelper

    attr_accessor :hint, :match, :tag, :tag_args, :attribute
    attr_reader   :field

    def initialize( args={} )

        @hint       = nil
        @attribute  = nil     #<--- set to the attribute to only check set to NIL to check all attributes
        @match      = :broad  #<--- our match type
        @tag        = nil     #<--- the tag we return if this is a match
        @tag_args   = {}      #<--- the tag args of this tag if there are any

        load_object_args( args )

        @attribute  = @attribute.to_sym if !@attribute.nil?
        @match      = @match.to_sym 

        init_tag()
    end

    def init_tag()
        #sets up our tag and tag_args if tag has
        #to be sanitized from a load string
        # ex : tag=captcha?search_for=captchaimage1|captchaimage2

        return if @tag.nil?

        if @tag.include?('?')
            @tag_args = param_args_to_hash( @tag.split('?', 2)[1] )
            @tag      = "%#{tag.split('?', 2)[0]}%"
        else
            @tag = "%#{@tag}%"
        end
    end

    def tag_solver()
        #instantiates a Tag Solver object used for
        #Solving the Tag that has been assigned to this HINT
        TagSolver.new( @tag.dup, @tag_args.dup )
    end

    def match?( value=nil )

        return false if @hint.empty?

        value = @field.attributes[@attribute] if @attribute
        return false if value.nil?

        case @match
            when :broad ; value.downcase.include?(@hint)
            when :exact ; value.downcase == @hint
        end
    end

    def find_form( conn )
        #attempt to find form using the tag_args which should
        #be an array we can easily send to the connection fetch_form method
        @field = conn.fetch_form( @tag_args[:match_type], @tag_args[:args] )
        @field
    end

    def solve( field )

        @field = field

        #first check to see if we are doing attribute match first or not
        @attribute ? match? : field.attributes.find{ |attr, value| match?(value) }
        
    end
end
