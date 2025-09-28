# frozen_string_literal: true

module Fugit

  module At

    class << self

      def do_parse(s)

        at_parse(s) || et_orbi_parse(s)
      end

      def parse(s)

        do_parse(s) rescue nil
      end

      protected

      def et_orbi_parse(s)

        ::EtOrbi.make_time(s)
      end

      def at_parse(s)

#puts '=' * 80
#p s; Raabro.pp(Fugit::AtParser.parse(s, debug: 3), colours: true)
#puts '-' * 80
#(p s; Raabro.pp(Fugit::AtParser.parse(s, debug: 1), colours: true)) rescue nil
#puts '-' * 80
        ::Fugit::AtParser.parse(s.downcase)
      end
    end
  end

  module AtParser include Raabro

    #
    # piece parsers bottom to top

    #def ws(i); rex(nil, i, /\s+/); end # white space
    def ta(i); rex(nil, i, /\s*at/); end

    def weekday(i)

      rex(:weekday, i, /
        \s*
        (monday|tuesday|wednesday|thursday|friday|saturday|sunday|
         mon|tue|wed|thu|fri|sat|sun)
           /x)
    end

    def date(i)

      alt(:date, i, :weekday)
    end

    def time(i)

      #alt(:time, i, :ampm_time, :mil_time, :colon_time)
      str(nil, i, 'TODO')
    end

    def at_time(i)

      seq(nil, i, :ta, '?', :time)
    end

    def date_time(i)
      seq(nil, i, :date, :at_time, '?');
    end
    def time_date(i)
      seq(nil, i, :at_time, :date, '?');
    end

    def at(i); alt(:at, i, :date_time, :time_date); end

    #
    # rewrite parsed tree

    def qualify(t)

p t
      [ t.name, t.string ]
    end

    def rewrite_date(t)

print '::::date'; Raabro.pp(t, colours: true)
      qualify(t.sublookup(nil))
    end

    def rewrite_time(t)
    end

    #def rewrite_dur(t); Fugit::Duration.common_rewrite_dur(t); end
    def rewrite_at(t)

Raabro.pp(t, colours: true)

      date = t.sublookup(:date)
      time = t.sublookup(:time)
#if date then print 'vvv-- :date --vvv'; Raabro.pp(date, colours: true); end
#if time then print 'vvv-- :time --vvv'; Raabro.pp(time, colours: true); end

      date = date && rewrite(date)
      time = date && rewrite(time)

      nil
    end
  end
end

