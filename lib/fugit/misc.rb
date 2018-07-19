
module Fugit

  class << self

    def isostamp(show_date, show_time, show_usec, time)

      t = time || Time.now
      s = StringIO.new

      s << t.strftime('%Y-%m-%d') if show_date
      s << t.strftime('T%H:%M:%S') if show_time
      s << sprintf('.%06d', t.usec) if show_time && show_usec
      s << 'Z' if show_time && time.utc?

      s.string
    end

    def time_to_s(t)

      isostamp(true, true, false, t)
    end

    def time_to_plain_s(t=Time.now, z=true)

      t.strftime('%Y-%m-%d %H:%M:%S') + (z && t.utc? ? ' Z' : '')
    end

    def time_to_zone_s(t=Time.now)

      t.strftime('%Y-%m-%d %H:%M:%S %Z %z')
    end
  end
end

