

class Pooler
    def initialize( max )
        @max = max

        @worker_threads   = []
        @timeout_watcher  = nil

        @jobs           = Queue.new

        @lock = Mutex.new

        start()
    end

    def start_timer( timeout=nil )
        Thread.current[:start_ts] = Time.now.to_i
        Thread.current[:timeout]  = timeout
    end

    def clear_timer()
        Thread.current[:start_ts] = nil
        Thread.current[:timeout]  = nil
    end

    def spawn_worker()
        @worker_threads << Thread.new{
            loop do
                begin

                job, timeout = @jobs.pop()

                start_timer( timeout )
                job.call()
                clear_timer()

                rescue => err
                    puts "Pooler Thread Error: #{err.message}\n#{err.backtrace.join("\n")}"
                end
            end
        }
    end

    def timedout?( thread )
        return false if thread[:timeout].nil?
        return false if thread[:start_ts].nil?

        diff = ( Time.now.to_i - thread[:start_ts] )
        diff >= thread[:timeout]
    end

    def report_gui_timeout( thread )
        return if thread.nil?
        return if !Display_GUI

        excep = BotThreadTimeout.new( "Pool Thread Timed Out!" )
        excep.set_backtrace( caller )
        excep.report( thread )
    end

    def do_timeout( thread )
        report_gui_timeout( thread )
        thread.exit
        @lock.synchronize{ @worker_threads.delete( thread ) }
        spawn_worker()
    end

    def check_threads()
        thr_timeouts = @worker_threads.find_all{ |thr| timedout?( thr ) }
        thr_timeouts.each do |thr| do_timeout( thr ) end
    end

    def spinup_watcher()
        @timeout_watcher ||= Thread.new {
            loop do
                begin
                    sleep(60)
                    check_threads()
                rescue => err
                    puts "Pooler Thread Watcher Error: #{err.message}\n#{err.backtrace.join("\n")}"
                end
            end
        }
    end

    def spinup_all_workers()
        @max.times { spawn_worker }
    end

    def start()
        spinup_all_workers()
        spinup_watcher()
    end

    def add_job( lam_block, timeout=nil )
        @jobs.push [ lam_block, timeout ]
    end


end