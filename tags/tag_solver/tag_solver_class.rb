

class TagSolver

    include Enviornment
    include Tags
    include TagSolverHelper
    include DefaultTagHandler

    def initialize( tag=nil, tag_args={} )

        @tag      = tag
        @tag_args = tag_args

        init_tag_args if tag  #<--- need to fixup tag if this tag solver was not created via the hint solver

    end

    def fixup_tag( tag_raw )
        tag, tag_args_raw = *tag_raw.split('?',2)
        @tag_args.merge!( tag_args_raw.split('?').map{ |raw_param| param_to_hash(raw_param) }.reduce Hash.new, :merge )
        "~~#{tag}~~"
    end

    def init_tag_args()
        #  Will split the Tag and Tag_args if they were specified directly in the tag
        #  tag = 'rand_file?file=random_platform_site?other_arg=test'
        return if !@tag.include?('?')

        @tag.gsub!(/~~(.+?)~~/) { |tag|
            tag_match = $1
            #if this tag_match / subtag in tag string
            #does not have tag_args -- EX no ? then just return
            #the tag_match, else we run fixup_tag to record the tag_args
            tag_match.include?('?') ? fixup_tag( tag_match ) : "~~#{tag_match}~~"
        }
    end

    def tag_in_vars?(tag)
        #this will call on our enviornment module to
        #see if the variable is in our job variables.
        self[tag.to_sym] 
    end

    def get_bio_var(var)
        #goes out to our bio files and gets a random
        #element from the file that our var corresponds to
        #ex.  var == :first_name  --  Filename : bio/first_name.data

        bio_file = "#{BioDirectory}#{var.to_s}.data"
        data = rand_file_line( bio_file )

        case var.to_sym
            when :domain
                domain_keys = [ :domain, :user, :pass, :server, :port ]
                data.split(':').to_h( domain_keys )
        else
            data
        end
        
    end

    def is_bio_var?(tag)
        BioVars.include?( tag.to_sym )
    end

    def parse_default_tag_options( tag_solved )

        return tag_solved if @tag_args.empty?

        @tag_args.each do | tag_var, value |
            next if !respond_to?( tag_var )
            tag_solved = send( tag_var, tag_solved, value )
        end

        tag_solved

    end
    
    def parse_tag()

        @tag.gsub!( /~~(.+?)~~/ ) { |tag|

            tag_match = $1
            found = tag_in_vars?( tag_match )

            if found
                #replace the found value in tag_vars here
                found
            else
                #check to see if we have a tag handler method to solve this tag
                #and run it for the tag answer, else just set this to
                #the tag_match, also if we send it to a method for tag solving
                #we save this variable to the enviornment for later reference.

                tag_solved = case

                    #get bio var here if we have one for tag_match
                    when is_bio_var?( tag_match )   ;  get_bio_var( tag_match )
                    #if this class responds to tag via our TAGS module get it here.
                    when respond_to?( tag_match )   ;  send( tag_match )

                else
                    tag_match
                end

                parse_default_tag_options( tag_solved )
                

            end
        }

        @tag
    end

end
