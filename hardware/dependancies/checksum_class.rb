        #checksum Detection ALGO
        #1.  Check to see if file has checksum
        #2.  If checksum exists / run checksum algo
        #3.  If not exists just download file and
             #save if file doesn't exist on disk


        #Checksum algo
        #1.  Check to see if File Exists with checksum Attached
        #2   If Exists.. DownloadFile, and sanitize file and save to disk
        #3.  If Not Exist
        #4.      Check to see if file without checksum exists
        #5.      Download and save to disk if it doesn't exist
                 #-- delete checksum file on save finish
        #6.  If file does exist, compare checksum to file on disk checksum
        #        If they don't match, download and save new file.
                 #-- Delete checksum file on save finish

class Checksum
  
   include SplashUpdateModule

   CheckSumExcludeDirectories = ['dbase']

   def initialize(filename)
        @filename = filename
   end

   def has_checksum?()
       @filename.split('--').length > 1
   end

   def sha(filename)
       Digest::SHA256.file( filename ).hexdigest
   end

   def extract_checksum(filename)
      base_file = File.basename(filename)
      ext = File.extname(base_file)
      base_name = base_file.gsub(ext, '')
      checksum = base_name.split('--')[1]
      checksum
   end

   def valid_checksum?(filename)
      #see if we have a valid checksum
      extract_checksum(filename) == sha(filename)
   end

   def extract_filename()
       @filename.gsub( "--#{extract_checksum(@filename)}", '' )
   end

   def is_ignore_checksum_directory?()
       dir = @filename.gsub( File.basename(@filename), '' )
       CheckSumExcludeDirectories.each do |ex_dir|
          return true if dir.include?(ex_dir)
       end
       false
   end

   def download?()

       if has_checksum?
          #return true if the @filename exists with the checksum attached
          #this typically would mean a download was cancelled mid stream
          #as the file WITH checksum should be renamed at the save portion
          #of this class.

          return true if File.exists?(@filename)
          
          #next check to see if the file exists after we have removed
          #the checksum.  If it does not, then also download
          #it.
          return true if !File.exists?( extract_filename() )

          #if we get here we DO have a file without the Checksum Attached
          #already saved on disk. SO.. Lets validate the checksum now!
          server_file_checksum = extract_checksum(@filename)
          on_disk_checksum = sha( extract_filename )

          if is_ignore_checksum_directory?()
              false  #<--- this is an ignore checksum directory, so don't check the checksum on it.
          else

              if server_file_checksum != on_disk_checksum
                  update_new( "[ Checksum Mismatch ] -- #{extract_filename} -- Re-Downloading..." )
              end

              #delete the local file as it doesn't have valid checksum
              del_file( extract_filename ) if server_file_checksum != on_disk_checksum

              server_file_checksum != on_disk_checksum  #<---- this statement returns
                                                        #<---- true if checksums don't match
                                                        #<---- meaning we should download this file
          end

       else
          #if the @filename doesn't have a checksum just
          #determine if the file Exists or not
          #and download if it doesn't exist currently.
          !File.exists?(@filename)
       end
   end

   def save()
     begin
       new_file = extract_filename()
       File.rename( @filename, new_file )
       new_file
     rescue => err
       #puts "Error Saving File: #{@filename} -- #{err.message}"
       false
     end
   end

end
