

def file_contents(filename)
    IO.read( filename )
end

def is_full_path?( filename )
    #detects if the filename sent has a directory specified with
    #it or if its just single file
    File.dirname( filename ) != '.'
end

def write_data_to_file(filename, data)
    File.open( filename, 'w' ) { |f| f.write( data ) }
end

def write_data_to_yaml_file(filename, data)
    write_data_to_file( filename, data.to_yaml )
end

def load_yaml_from_file( filename )
    YAML.load( file_contents(filename) )
end

def create_dir( directory )
    FileUtils.mkdir( directory ) if !File.directory?( directory )
end

def file_count( dir )
    dir = dir[-1,1] == '/' ? dir : "#{dir}/"
    Dir["#{dir}*"].length
end

def dir_empty?(directory)
    Dir["#{directory}*"].empty?
end

def dir_files_to_sym(directory)
    #gets all the file names in specified directory and returns them
    #as symbols without the extension.
    Dir.glob( "#{directory}*" ).map{ |filename| File.basename( filename, ".data" ).to_sym }
end

def dir_files( dir, recursive=false )
    dir = dir[-1,1] == '/' ? dir : "#{dir}/"
    search_pattern = recursive ? "#{dir}**/*" : "#{dir}*"
    Dir[search_pattern]
end

def random_dir( dir )

    #attempts to get a random file from directory
    #if ext is specified -- EX. jpg it will only get
    #the files that have that extension.

    return nil if !File.directory?( dir )

    dir = dir[-1,1] == '/' ? dir : "#{dir}/"
    files = Dir.glob("#{dir}*")

    #remove files that do not match extension if
    #ext is specified.
    files.delete_if{ |file| File.file?( file ) or File.extname( file ) == '.files' }
    return nil if files.empty?

    files.sample

end

def random_file_dir( dir, ext=nil )

    #attempts to get a random file from directory
    #if ext is specified -- EX. jpg it will only get
    #the files that have that extension.

    return nil if !File.directory?( dir )

    dir = dir[-1,1] == '/' ? dir : "#{dir}/"
    files = Dir.glob("#{dir}*")

    #remove files that do not match extension if
    #ext is specified.
    files.delete_if{ |file| File.extname( file ) != ".#{ext}" } if ext
    return nil if files.empty?

    files.sample

end


def rand_file_line( filename, file_handle=nil )

    #make sure we close this file if we are opening the file
    #here in this method
    close_on_finish = file_handle.nil? ? true : false
    #open our file if no file handle was sent to this method
    file_handle ||= File.open( filename, "r" )

    file_size = File.stat(filename).size
    amount = ( file_handle.tell + rand( file_size - 1 ) ) % file_size
    file_handle.seek( amount, IO::SEEK_SET )
    file_handle.readline
    file_handle.seek(0) if file_handle.eof?
    line = file_handle.readline
    line[0..-1].strip

ensure
    file_handle.close if ( close_on_finish and file_handle )
end

def del_file(filename)
    begin

      if File.exists?(filename)
         File.unlink filename
      end

    rescue => err
       puts "File Delete Error : #{err.message} -- File: #{filename}"
    end
end
