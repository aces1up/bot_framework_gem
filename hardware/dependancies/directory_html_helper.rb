

class HTMLDirectoryHelper
    attr_reader :current_dir

    def initialize()
        @html = nil
        @agent = Mechanize.new
        @root_dir = nil
        @current_dir = nil
    end

    def open(url)
      begin
        @agent.get(url)
      rescue => err
        @html = nil
        return
      end
        @root_dir = url
        @current_dir = url
        @html = @agent.page.body.to_s
    end

    def valid_directory?()
        !@html.nil?
    end

    def links()
        @agent.page.links
    end

    def directory?(file)
        file[-1,1] == '/'
    end

    def cdup()
        return if @current_dir == @root_dir
        @current_dir[/([^\/]+\/)$/] = ''
        #puts "CDUP --> #{@current_dir}"
        @agent.get @current_dir
    end

    def cd(dir)
        @current_dir = "#{@current_dir}#{dir}"
        #puts "CD --> #{@current_dir}"
        @agent.get @current_dir
    end

    def entries()
        links.find_all{|link| link.href != '../' }.map{|link| link.href}
    end

    def directories()
        entries.find_all{|entry| directory?(entry) }
    end

    def files()
        entries.find_all{|entry| !directory?(entry) }
    end

    def cur_dir_sanitized()
        #removed the remote_url portion from the
        #@current directory
        last_dir = @root_dir.split('/').last
        reg_str  = ".*#{last_dir}\/"
        @current_dir.gsub( Regexp.new( reg_str ), '' )
    end

    def each_dir( &block )

        directories.each do |dir|
            cd( dir )
            yield cur_dir_sanitized, files
            each_dir( &block )
        end

        cdup
    end

    def all_files()
        glob = []
        each_dir do |dir, files|
            glob << files.map { |file| "#{dir}#{file}" }
        end
        glob.flatten
    end

    def all_files_with( root_dir )
        #maps all files to the root directory
        all_files.map{|file| "#{root_dir}#{file}" }
    end

end
