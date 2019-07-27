
module Fugit

  # A natural language set of parsers for fugit.
  # Focuses on cron expressions. The rest is better left to Chronic and friends.
  #
  module Nat

    class << self

      def parse(s, opts={})

        return s if s.is_a?(Fugit::Cron) || s.is_a?(Fugit::Duration)

        return nil unless s.is_a?(String)

#p s; Raabro.pp(Parser.parse(s, debug: 3), colours: true)
        a = Parser.parse(s)

        return nil unless a

        return parse_crons(s, a, opts) \
          if a.include?([ :flag, 'every' ])
        return parse_crons(s, a, opts) \
          if a.include?([ :flag, 'from' ]) && a.find { |e| e[0] == :day_range }

        nil
      end

      def do_parse(s, opts={})

        parse(s, opts) ||
        fail(ArgumentError.new("could not parse a nat #{s.inspect}"))
      end

      protected

      def parse_crons(s, a, opts)

        dhs, aa = a
          .partition { |e| e[0] == :digital_hour }
        ms = dhs
          .inject({}) { |h, dh| (h[dh[1][0]] ||= []) << dh[1][1]; h }
          .values
          .uniq

        crons =
          #if ms.size <= 1 || hs.size <= 1
          if ms.size <= 1
            [ parse_cron(a, opts) ]
          else
            dhs.collect { |dh| parse_cron([ dh ] + aa, opts) }
          end

        fail ArgumentError.new(
          "multiple crons in #{s.inspect} " +
          "(#{crons.collect(&:original).join(' | ')})"
        ) if opts[:multi] == :fail && crons.size > 1

        if opts[:multi] == true || (opts[:multi] && opts[:multi] != :fail)
          crons
        else
          crons.first
        end
      end

      def parse_cron(a, opts)

        h = { min: nil, hou: [], dom: nil, mon: nil, dow: nil }
        hkeys = h.keys

        a.each do |key, val|
          if key == :biz_day
            (h[:dow] ||= []) << '1-5'
          elsif key == :simple_hour || key == :numeral_hour
            h[:hou] << val
          elsif key == :digital_hour
            (h[:hou] ||= []) << val[0].to_i
            (h[:min] ||= []) << val[1].to_i
          elsif key == :name_day
            (h[:dow] ||= []) << val
          elsif key == :day_range
            (h[:dow] ||= []) << val.collect { |v| v.to_s[0, 3] }.join('-')
          elsif key == :tz
            h[:tz] = val
          elsif key == :duration
            process_duration(h, *val[0].to_h.first)
          end
        end

        h[:min] ||= [ 0 ]
        h[:min].uniq!

        h[:hou].uniq!;
        h[:hou].sort!

        h[:dow].sort! if h[:dow]

        a = hkeys
          .collect { |k|
            v = h[k]
            (v && v.any?) ? v.collect(&:to_s).join(',') : '*' }
        a.insert(0, h[:sec]) if h[:sec]
        a << h[:tz].first if h[:tz]

        s = a.join(' ')

        Fugit::Cron.parse(s)
      end

      def process_duration(h, interval, value)

        send("process_duration_#{interval}", h, value)
      end

      def process_duration_mon(h, value)

        h[:hou] = [ 0 ]
        h[:dom] = [ 1 ]
        h[:mon] = [ value == 1 ? '*' : "*/#{value}" ]
      end

      def process_duration_day(h, value)

        h[:hou] = [ 0 ]
        h[:dom] = [ value == 1 ? '*' : "*/#{value}" ]
      end

      def process_duration_hou(h, value)

        h[:hou] = [ value == 1 ? '*' : "*/#{value}" ]
      end

      def process_duration_min(h, value)

        h[:hou] = [ '*' ]
        h[:min] = [ value == 1 ? '*' : "*/#{value}" ]
      end

      def process_duration_sec(h, value)

        h[:hou] = [ '*' ]
        h[:min] = [ '*' ]
        h[:sec] = [ value == 1 ? '*' : "*/#{value}" ]
      end
    end

    module Parser include Raabro

      NUMS = %w[
        zero
        one two three four five six seven eight nine
        ten eleven twelve ]

      WEEKDAYS =
        Fugit::Cron::Parser::WEEKDS + Fugit::Cron::Parser::WEEKDAYS

      NHOURS =
        { 'noon' => [ 12, 0 ], 'midnight' => [ 0, 0 ] }

      # piece parsers bottom to top

      def am_pm(i)
        rex(:am_pm, i, / *(am|pm)/i)
      end

      def digital_hour(i)
        rex(:digital_hour, i, /(2[0-4]|[01][0-9]):?[0-5]\d/)
      end

      def _simple_hour(i)
        rex(:sh, i, /(2[0-4]|[01]?[0-9])/)
      end
      def simple_hour(i)
        seq(:simple_hour, i, :_simple_hour, :am_pm, '?')
      end

      def _numeral_hour(i)
        rex(:nh, i, /(#{NUMS.join('|')})/i)
      end
      def numeral_hour(i)
        seq(:numeral_hour, i, :_numeral_hour, :am_pm, '?')
      end

      def name_hour(i)
        rex(:name_hour, i, /(#{NHOURS.keys.join('|')})/i)
      end

      def plain_day(i); rex(:plain_day, i, /day/i); end
      def biz_day(i); rex(:biz_day, i, /(biz|business|week) *day/i); end
      def name_day(i); rex(:name_day, i, /#{WEEKDAYS.reverse.join('|')}/i); end

      def range_sep(i); rex(nil, i, / *- *| +(to|through) +/); end

      def day_range(i)
        seq(:day_range, i, :name_day, :range_sep, :name_day)
      end

      def _tz_name(i)
        rex(nil, i, /[A-Z][a-zA-Z0-9+\-]+(\/[A-Z][a-zA-Z0-9+\-_]+){0,2}/)
      end
      def _tz_delta(i)
        rex(nil, i, /[-+]([01][0-9]|2[0-4]):?(00|15|30|45)/)
      end
      def _tz(i); alt(:tz, i, :_tz_delta, :_tz_name); end

      def duration(i)
        rex(
          :duration, i,
          /
            \d+
            \s?
            (mon(ths?)?|d(ays?)?|h(ours?)?|m(in(ute)?s?)?|s(ec(ond)?s?)?)
          /ix)
      end

      def flag(i); rex(:flag, i, /(every|from|at|after|on|in)/i); end

      def datum(i)
        alt(nil, i,
          :day_range,
          :plain_day, :biz_day, :name_day,
          :_tz,
          :flag,
          :duration,
          :name_hour, :numeral_hour, :digital_hour, :simple_hour)
      end

      def sugar(i); rex(nil, i, /(and|or|[, \t]+)/i); end

      def elt(i); alt(nil, i, :sugar, :datum); end
      def nat(i); rep(:nat, i, :elt, 1); end

      # rewrite parsed tree

      def rewrite_nat(t)

#Raabro.pp(t, colours: true)
        t
          .subgather(nil)
          .collect { |tt|

            k = tt.name
            v = tt.string.downcase

            case k
            when :tz
              [ k, [ tt.string.strip, EtOrbi.get_tzone(tt.string.strip) ] ]
            when :duration
              [ k, [ Fugit::Duration.parse(tt.string.strip) ] ]
            when :digital_hour
              v = v.gsub(/:/, '')
              [ k, [ v[0, 2], v[2, 2] ] ]
            when :name_hour
              [ :digital_hour, NHOURS[v] ]
            when :name_day
              [ k, WEEKDAYS.index(v[0, 3]) ]
            when :day_range
              [ k, tt.subgather(nil).collect { |st| st.string.downcase } ]
            when :numeral_hour, :simple_hour
              vs = tt.subgather(nil).collect { |ttt| ttt.string.downcase.strip }
              v = k == :simple_hour ? vs[0].to_i : NUMS.index(vs[0])
              v += 12 if vs[1] == 'pm'
              [ k, v ]
            else
              [ k, v ]
            end }
      end
    end
  end
end

