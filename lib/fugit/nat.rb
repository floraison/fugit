
module Fugit

  # A natural language set of parsers for fugit.
  # Focuses on cron expressions. The rest is better left to Chronic and friends.
  #
  module Nat

    class << self

      def parse(s)

        return s if s.is_a?(Fugit::Cron) || s.is_a?(Fugit::Duration)
        return nil unless s.is_a?(String)

        s = s + ' '

#p s; Raabro.pp(Parser.parse(s, debug: 3), colours: true)
        h = Parser.parse(s)
unless h
p s; Raabro.pp(Parser.parse(s, debug: 3), colours: true)
end
p h

        if h && h[:every]
          parse_cron(h)
        else
          nil
        end
      end

      def do_parse(s)

        parse(s) ||
        fail(ArgumentError.new("could not parse a nat #{s.inspect}"))
      end

      def push(c, h)

        h.each { |k, v|
          a = c[k]
          if a == nil
            a = c[k] = []
          elsif a == [ nil ] || v.is_a?(Array)
            a.clear
          end
          if v.is_a?(Array)
            a.concat(v)
          else
            a << v
          end }
      end; protected :push

      def parse_cron(h)

        c = {
          min: [ nil ], hou: [ nil ], dom: [ nil ], mon: [ nil ], dow: [ nil ] }

        h.each do |key, val|
p [ key, val ]
          case key
          when :day then push(c, dow: "*/#{val}")
          when :dow then push(c, dow: val)
          when :hou then push(c, min: 0, hou: val)
          when :at then push(c, min: val[1], hou: val[0])
          when :tz then push(c, tz: val)
          end
        end

        c = c.inject({}) { |hh, (k, v)|
          hh[k] =
            if v.all? { |e| e.is_a?(Integer) }
              v.sort
            else
              v.collect { |e| e == '*/1' ? '*' : e }
            end
          hh }
pp c

        Fugit::Cron.allocate.send(:init, nil, c)
      end
    end

    module Parser include Raabro

      WEEKDAYS =
        Fugit::Cron::Parser::WEEKDS +
        Fugit::Cron::Parser::WEEKDAYS

      #
      # subparser side of the parser

      def every(i); rex(nil, i, /every\s+/); end
      def and_or_or(i); rex(nil, i, /(and|or)\s+/); end
      def in_or_on(i); rex(nil, i, /(in|on)\s+/); end
      def ats(i); rex(nil, i, /at\s+/); end

      def _tz_name(i)
        rex(nil, i, /[A-Z][a-zA-Z0-9]+(\/[A-Z][a-zA-Z0-9\_]+){0,2}\s+/)
      end
      def _tz_delta(i)
        rex(nil, i, /[-+]([01][0-9]|2[0-4]):?(00|15|30|45)\s+/)
      end
      def _tz(i); alt(:tz, i, :_tz_delta, :_tz_name); end
        #
      def timezone(i); seq(nil, i, :in_or_on, :_tz); end

      NHOURS =
        { 'noon' => [ 12, 0 ], 'midnight' => [ 0, 0 ] }
      NUMS = %w[
        zero
        one two three four five six seven eight nine
        ten eleven twelve ]

      def named_hour(i)
        rex(:named_hour, i, /(#{NHOURS.keys.join('|')})\s+/i)
      end
      def am_pm(i); rex(:am_pm, i, /\s*(am|pm)\s+/i); end
      def simple_hour(i)
        rex(:simple_hour, i, /\d\s*/)
      end
      def digital_hour(i)
        rex(:digital_hour, i, /(2[0-4]|[01][0-9])[h:]?[0-5]\d\s*/)
      end
      def numeral_hour(i)
        rex(:numeral_hour, i, /(#{NUMS.join('|')})\s+/i)
      end
      def hour_variants(i)
        alt(nil, i, :numeral_hour, :digital_hour, :simple_hour)
      end
      def hour(i)
        seq(:hour, i, :hour_variants, :am_pm, '?')
      end
      def at_point(i)
        alt(nil, i, :hour, :named_hour)
      end
      def at(i)
        seq(:at, i, :ats, :at_point)
      end

      def duration(i)
        rex(
          :duration, i,
          /
            \d+
            \s?
            (mon(ths?)?|d(ays?)?|h(ours?)?|m(in(ute)?s?)?|s(ec(ond)?s?)?)
            \s+
          /ix)
      end

      def plain_day(i); rex(:plain_day, i, /day\s+/i); end

      def biz_day(i)
        rex(:biz_day, i, /(biz|business|week) *day\s+/i)
      end
      def name_day(i)
        rex(:name_day, i, /(#{WEEKDAYS.reverse.join('|')})\s+/i)
      end
      def day(i)
        alt(nil, i, :plain_day, :biz_day, :name_day)
      end
      def days(i)
        jseq(nil, i, :day, :and_or_or)
      end

      def frequency(i)
        alt(:frequency, i, :days, :duration)
      end
      def every_nat(i)
        seq(:every, i, :every, :frequency, :at, '?', :timezone, '?')
      end
      def nat(i); alt(:nat, i, :every_nat); end

      #
      # rewrite side of the parser

      def rewrite_tz(t)

#Raabro.pp(t, colours: true)
        tzn = t.string.strip

        { tz: [ tzn, EtOrbi.get_tzone(tzn) ] }
      end

      def rewrite_duration(t)

Raabro.pp(t, colours: true)
        { dur: t.string.strip }
      end

      def rewrite_named_hour(t)

#Raabro.pp(t, colours: true)
        NHOURS[t.string.strip.downcase]
      end

      def rewrite_simple_hour(t)

        [ t.string.to_i, 0 ]
      end

      def rewrite_numeral_hour(t)

        [ NUMS.index(t.string.strip), 0 ]
      end

      def rewrite_digital_hour(t)

#Raabro.pp(t, colours: true)
        s = t.string.gsub(/[ h:]/, '')

        [ s[0, 2].to_i, s[2, 2].to_i ]
      end

      def rewrite_hour(t)

#Raabro.pp(t, colours: true)
        h, m = rewrite(t.sublookup(nil))

        apt = t.sublookup(:am_pm)
        ap = apt ? apt.string.strip : 'am'

        h = h + 12 if ap == 'pm' && h < 13

        [ h, m ]
      end

      def rewrite_at(t)

#Raabro.pp(t, colours: true)
        { at: rewrite(t.sublookup(nil)) }
      end

      def rewrite_name_day(t)

#Raabro.pp(t, colours: true)
        { dow: WEEKDAYS.index(t.string[0, 3]) }
      end

      def rewrite_biz_day(t)

#Raabro.pp(t, colours: true)
        case t.string.strip
        when 'weekday' then { dow: [ 1, 2, 3, 4, 5 ] }
        end
      end

      def rewrite_plain_day(t)

#Raabro.pp(t, colours: true)
        { day: 1 }
      end

      def rewrite_frequency(t)

#Raabro.pp(t, colours: true)
        t.subgather(nil).collect { |ct| rewrite(ct) }
      end

      def merge(h, r)

        (r.is_a?(Array) ? r : [ r ])
          .each { |rr|
            rr.each { |k, v|
              case (current = h[k])
              when Array then current << v
              when nil then h[k] = v
              else h[k] = [ current, v ]
              end } }

        h
      end

      def rewrite_every(t)

        t.subgather(nil)
          .inject({}) { |h, ct| merge(h, rewrite(ct)) }
          .merge!(every: true)
      end

      def rewrite_nat(t)

        rewrite(t.sublookup(nil))
      end
    end
  end
end

