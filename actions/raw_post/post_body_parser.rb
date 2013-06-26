

module PostBodyParser

    def solve_post_body_tags()
        body_str = solve_tag( @post_body.split(/\n/).join( RawPost::SplitDelimeter ) )
        @post_body = body_str.split( RawPost::SplitDelimeter )
    end

    def parse_post_body()
        #this will solve any tags in the post body
        #also encode it based on what settings and content_type
        #we have loaded.
        
        case @content_type

            when :multipart

                solve_post_body_tags()

                multi_part_parser = SubmitDatatoMultiPart.new( @post_body )
                @post_body = multi_part_parser.multipart.to_s

                #set the correct boundary here in our headers
                @headers['Content-Type'] = "multipart/form-data; boundary=#{multi_part_parser.boundary_str}"


            when :urlencoded
                @post_body = UrlEncoderParser.new( @post_body ).to_s

        else
            #need to handle direct request here, and use the packet
            #loader to detect of post_body is encoded or not
            #or use the action var @encode_mode
        end


    end

end
