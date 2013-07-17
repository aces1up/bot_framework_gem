


class Extractor

    include Enviornment
    include LogHandler
    include SplashUpdateModule

    #file sent to this method is a file
    #with fullpath, it will extract the files
    #to the directory with the path the file
    #included.

    def decompress( file )
    
      update_new( "Extracting Support Files from Archive: #{file} ..." )

      Zip::ZipFile.open(file) { |zip_file|

        zip_file.each { |f|

          f_path = "#{File.dirname(file)}/"
          zip_filename = "#{f_path}#{f}"

          del_file( zip_filename )

          #update the splash here with extracting
          #info if update_splash = true
          update_new( "Extracting Support File: [ #{zip_filename} ]" )

          zip_file.extract(f, zip_filename)

        }
      }
    end
end
