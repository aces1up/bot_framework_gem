
class MultiPartElement

    include Enviornment

    attr_reader :part_obj

    def initialize( part )

        @part_arr    = part
        @split_index = nil

        @header      = nil
        @content     = nil
        @fields_hash = nil   #<---- a key/value pair of our header fields
        @name        = nil   #<---- the form name of this element

        @part_obj    = nil   #<---- the multi_part gem object of this data

        split_text()
        store_data()
        create_part()
    end

    def to_s()
        content_str = @content.empty? ? "" : @content.join("\n")
        "Header:\n#{@header.join("\n")}\nContent:\n#{content_str}"
    end

    def split_text()
        @split_index = @part_arr.index{ |line| line.empty? }
    end

    def set_header()
        @header = @part_arr[0..@split_index-1]
    end

    def set_content()
        @content = @part_arr[@split_index+1..-1]
    end

    def store_data()
        set_header()
        set_content()
    end

    def set_name()
        fields = @header[0].split(';').find_all{ |field| field.include?('=') }
        raw = fields.map{ |field| field.split('=') }.flatten
        raw.map!{ |field| field.strip }
        @fields_hash = Hash[*raw]
        @name = @fields_hash['name'].gsub('"', '')
    end

    def create_part()
        set_name()

        content_part = @content.empty? ? "" : "#{@content.join("\n")}\n"

        @part_obj =  Part.new(
                               :name           => @name,
                               :body           => content_part
                             )
    end

end

class FilePartElement < MultiPartElement

    def set_filename()

        if self[:part_filename]
            @full_filename = self[:part_filename]
            self[:part_filename] = nil
        else
            @full_filename = @fields_hash['filename'].gsub('"', '')
        end

        @filename      = File.basename( @full_filename )
    end

    def set_content_type()
        field = @header.find{ |header_field| header_field.downcase.include?('content-type') }
        @content_type = field.split(':')[1].strip
    end

    def create_part()

        set_name()
        set_filename()
        set_content_type()

        @part_obj =  Part.new(
                               :name           => @name,
                               :body           => File.binread( @full_filename ),
                               :filename       => @filename,
                               :content_type   => @content_type
                             )
    end

end


