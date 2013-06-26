

class SubmitDatatoMultiPart

    attr_reader :multipart, :boundary_str

    def initialize( submit_data, boundary_str=nil )

        @submit_data      = submit_data  #<--- this should be in array form

        @boundary_str     = boundary_str #<--- the actual boundary str we use
                                         #<--- in our requests

        @multipart        = nil          #our MultiPart Class that handles all the
                                         #construction of our multipart packet

        @parts            = []           #our custom parts generated from splitting
                                         #up our submit data between boundaries

        init_submit_data()
        init_parts()                     #<--- this will split submit data into
                                         #<--- our custom part rendering elements
        create_multipart_obj()
    end

    def init_submit_data()
        return if @submit_data.is_a?( Array )
        @submit_data = @submit_data.split("\n")
    end

    def dump_parts()
        @parts.each_with_index do |part, index|
            puts "[#{index}]:  #{part.to_s}"
        end
    end

    def boundary_indexes()
        @submit_data.map.with_index {|a, i| a =~ /-+\d+/ ? i : nil}.compact # => [0, 2, 6]
    end

    def is_file_part?( part )
        part[0].include?('filename=')
    end

    def create_part( part )
        #creates a part object using the part array sent
        part_klass = case
                          when is_file_part?( part )  ;  FilePartElement
                     else
                          MultiPartElement
                     end

        @parts.push( part_klass.new( part ) )
    end

    def init_parts()

        boundary_indexes.each_with_index do |part_index, arr_index|

          if !boundary_indexes[arr_index+1].nil?
              part_start_index   =   part_index + 1
              part_end_index     =   boundary_indexes[arr_index+1] - 1

              part_arr = @submit_data[part_start_index..part_end_index]

              create_part( part_arr )
          end

        end
    end

    def get_parts_objs()
        file_part = @parts.find{ |part| part.class == FilePartElement }
        @parts.delete(file_part) if file_part
        file_part_obj = file_part ? file_part.part_obj : nil
        [ file_part_obj, @parts.map{ |part| part.part_obj } ].flatten.compact
    end


    def create_multipart_obj()
        #create our multi_part object and set our
        #boundary instance variables
        @multipart      =  MultipartBody.new( get_parts_objs, @boundary_str )
        @boundary_str   =  @multipart.boundary
    end


end

