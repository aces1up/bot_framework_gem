
module TimeTags

    def date()
        t = Time.now
        t.strftime("%F")
    end

    def cur_ts()
        Time.now.to_i
    end

    def cur_ts_milli()
        (Time.now.to_f * 1000).to_i
    end

    def time
        t = Time.now
        t.strftime("%H:%M %p")
    end

    def time_non_mil
        t = Time.now
        t.strftime("%I:%M %p")
    end

    def cur_month()
        t = Time.now
        t.month.to_s
    end

    def cur_day()
        t = Time.now
        t.day.to_s
    end

    def cur_year()
        t = Time.now
        t.year.to_s
    end

    def cur_hour()
        t = Time.now
        t.hour.to_s
    end

    def cur_hour_non_mil()
        t = Time.now
        t.strftime("%I")
    end

    def cur_min()
        t = Time.now
        t.min.to_s
    end

    def cur_sec()
        t = Time.now
        t.sec.to_s
    end

    def cur_ampm
        t = Time.now
        t.strftime("%p")
    end

    def cur_ampm_lower
        t = Time.now
        t.strftime("%p").downcase
    end

end
