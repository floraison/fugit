
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
#(p s; Raabro.pp(Parser.parse(s, debug: 1), colours: true)) rescue nil
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

        hms, aa = a
          .partition { |e| e[0] == :point && e[1][0] == :hour }
        ms = hms
          .inject({}) { |h, e| (h[e[1][1]] ||= []) << e[1][2]; h }
          .values
          .uniq
        crons =
          ms.size > 1 ?
          hms.collect { |e| parse_cron([ e ] + aa, opts) } :
          [ parse_cron(a, opts) ]

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

        h = { min: nil, hou: nil, dom: nil, mon: nil, dow: nil }
        hkeys = h.keys

        i0s, es = a.partition { |e| e[0] == :interval0 }
        a = es + i0s
          # interval0s are fallback

        a.each do |key, val|
          case key
          when :biz_day
            (h[:dow] ||= []) << '1-5'
          when :name_day
            (h[:dow] ||= []) << val
          when :day_range
            (h[:dow] ||= []) << val.collect { |v| v.to_s[0, 3] }.join('-')
          when :tz
            h[:tz] = val
          when :point
            process_point(h, *val)
          when :interval1
            process_interval1(h, *val[0].to_h.first)
          when :interval0
            process_interval0(h, val)
          end
        end

        return nil if h[:fail]

        h[:min] = (h[:min] || [ 0 ]).uniq
        h[:hou] = (h[:hou] || []).uniq.sort
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

      def process_point(h, key, *value)

        case key
        when :hour
          v0, v1 = value
          v0 = v0.to_i if v0.is_a?(String) && v0.match(/^\d+$/)
          (h[:hou] ||= []) << v0
          (h[:min] ||= []) << v1.to_i if v1
        when :sec, :min
          (h[key] ||= []) << value[0]
        end
      end

      def process_interval0(h, value)

        case value
        when 'sec', 'second'
          h[:min] = [ '*' ]
          h[:sec] = [ '*' ]
        when 'min', 'minute'
          h[:min] = [ '*' ]
        when 'hour'
          unless h[:min] || h[:hou]
            h[:min] = [ 0 ]
            h[:hou] = [ '*' ]
          end
        when 'day'
          unless h[:min] || h[:hou]
            h[:min] = [ 0 ]
            h[:hou] = [ 0 ]
          end
        when 'week'
          unless h[:min] || h[:hou] || h[:dow]
            h[:min] = [ 0 ]
            h[:hou] = [ 0 ]
            h[:dow] = [ 0 ]
          end
        when 'month'
          unless h[:min] || h[:hou]
            h[:min] = [ 0 ]
            h[:hou] = [ 0 ]
          end
          (h[:dom] ||= []) << 1
        when 'year'
          unless h[:min] || h[:hou]
            h[:min] = [ 0 ]
            h[:hou] = [ 0 ]
          end
          (h[:dom] ||= []) << 1
          (h[:mon] ||= []) << 1
        end
      end

      def process_interval1(h, interval, value)

        if value != 1 && [ :yea, :wee ].include?(interval)
          int = interval == :year ? 'years' : 'weeks'
          h[:fail] = "cannot cron for \"every #{value} #{int}\""
          return
        end

        case interval
        when :yea
          h[:hou] = [ 0 ]
          h[:mon] = [ 1 ]
          h[:dom] = [ 1 ]
        when :mon
          h[:hou] = [ 0 ]
          h[:dom] = [ 1 ]
          h[:mon] = [ value == 1 ? '*' : "*/#{value}" ]
        when :wee
          h[:hou] = [ 0 ]
          h[:dow] = [ 0 ] # Sunday
        when :day
          h[:hou] = [ 0 ]
          h[:dom] = [ value == 1 ? '*' : "*/#{value}" ]
        when :hou
          h[:hou] = [ value == 1 ? '*' : "*/#{value}" ]
        when :min
          h[:hou] = [ '*' ]
          h[:min] = [ value == 1 ? '*' : "*/#{value}" ]
        when :sec
          h[:hou] = [ '*' ]
          h[:min] = [ '*' ]
          h[:sec] = [ value == 1 ? '*' : "*/#{value}" ]
        end
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

      def interval0(i)
        rex(:interval0, i,
          /(year|month|week|day|hour|min(ute)?|sec(ond)?)(?![a-z])/i)
      end

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

      def interval1(i)
        rex(:interval1, i,
          /
            \d+
            \s?
            (y(ears?)?|months?|w(eeks?)?|d(ays?)?|
              h(ours?)?|m(in(ute)?s?)?|s(ec(ond)?s?)?)
          /ix)
      end

      def min_or_sec(i)
        rex(:min_or_sec, i, /(min(ute)?|sec(ond)?)\s+\d+/i)
      end

      def point(i)
        alt(:point, i,
          :min_or_sec,
          :name_hour, :numeral_hour, :digital_hour, :simple_hour)
      end

      def flag(i); rex(:flag, i, /(every|from|at|after|on|in)/i); end

      def datum(i)
        alt(nil, i,
          :flag,
          :interval1,
          :point,
          :interval0,
          :day_range, :biz_day, :name_day,
          :_tz)
      end

      def sugar(i); rex(nil, i, /(and|or|[, \t]+)/i); end

      def elt(i); alt(nil, i, :sugar, :datum); end
      def nat(i); rep(:nat, i, :elt, 1); end

      # rewrite parsed tree

      def _rewrite(t)
        [ t.name, t.string.downcase ]
      end
      alias rewrite_flag _rewrite
      alias rewrite_interval0 _rewrite
      alias rewrite_biz_day _rewrite

      def rewrite_name_day(t)
        [ :name_day, WEEKDAYS.index(t.string.downcase[0, 3]) ]
      end

      def rewrite_day_range(t)
        [ :day_range, t.subgather(nil).collect { |st| st.string.downcase } ]
      end

      def rewrite_name_hour(t)
        [ :hour, *NHOURS[t.string.strip.downcase] ]
      end
      def rewrite_numeral_hour(t)
        vs = t.subgather(nil).collect { |st| st.string.downcase.strip }
        v = NUMS.index(vs[0])
        v += 12 if vs[1] == 'pm'
        [ :hour, v, 0 ]
      end
      def rewrite_simple_hour(t)
        vs = t.subgather(nil).collect { |st| st.string.downcase.strip }
        v = vs[0].to_i
        v += 12 if vs[1] == 'pm'
        [ :hour, v, 0 ]
      end
      def rewrite_digital_hour(t)
        v = t.string.gsub(/:/, '')
        [ :hour, v[0, 2], v[2, 2] ]
      end

      def rewrite_min_or_sec(t)
        unit, num = t.string.split(/\s+/)
        [ unit[0, 3].to_sym, num.to_i ]
      end

      def rewrite_point(t)
        [ :point, rewrite(t.sublookup) ]
      end

      def rewrite_tz(t)
        [ :tz,  [ t.string.strip, EtOrbi.get_tzone(t.string.strip) ] ]
      end

      def rewrite_interval1(t)
        [ t.name, [ Fugit::Duration.parse(t.string.strip) ] ]
      end

      def rewrite_nat(t)

#Raabro.pp(t, colours: true)
        t.subgather(nil).collect { |tt| rewrite(tt) }
      end
    end
  end
end

