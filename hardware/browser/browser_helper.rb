

module BrowserWindow

    include SystemEnviornment

    def open_ie(url)

        ie_exe = "#{prog_file_dir}\\internet explorer\\iexplore.exe"

        createprocess = Win32API.new('kernel32','CreateProcess', 'LPLLLLLLPP', 'I')

        startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
        procinfo  = [0,0,0,0].pack('LLLL')

        createprocess.call( 0, "#{ie_exe} #{url}", 0, 0, 0, 0, 0, 0, startinfo, procinfo )
    end

end
