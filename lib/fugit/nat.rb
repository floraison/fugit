
module Fugit

  # A natural language set of parsers for fugit.
  # Focuses on cron expressions. The rest is better left to Chronic and friends.
  #
  module Nat

    class << self

      def parse(s, opts={})

        return s if s.is_a?(Fugit::Cron) || s.is_a?(Fugit::Duration)

        return nil unless s.is_a?(String)

p s; Raabro.pp(Parser.parse(s, debug: 3), colours: true)
(p s; Raabro.pp(Parser.parse(s, debug: 1), colours: true)) rescue nil
        parse_crons(s, Parser.parse(s), opts)
      end

      def do_parse(s, opts={})

        parse(s, opts) ||
        fail(ArgumentError.new("could not parse a nat #{s.inspect}"))
      end

      protected

      def parse_crons(s, a, opts)

        return nil unless a

        h = a
          .reverse
          .inject({}) { |r, e| send("parse_#{e[0]}_elt", e, opts, r); r }
            #
            # the reverse ensure that in "every day at five", the
            # "at five" is placed before the "every day" so that
            # parse_x_elt calls have the right sequence
p [ :h, h ]

        hms = h[:hms]

        hours = (hms || [])
          .uniq
          .inject({}) { |r, hm| (r[hm[1]] ||= []) << hm[0]; r }
          .inject({}) { |r, (m, hs)| (r[hs.sort] ||= []) << m; r }
          .to_a
          .sort_by { |hs, ms| -hs.size }
        hours << [ [ '*' ], [ '*' ] ] if hours.empty?

        hours
          .collect { |hm| assemble_cron(h.merge(hms: hm)) }
          .first # FIXME
      end

      def assemble_cron(h)

        puts "h: " + h.inspect

        s = []
        s << h[:sec] if h[:sec]
        s << h[:hms][1].join(',')
        s << h[:hms][0].join(',')
        s << (h[:dom] || '*') << (h[:mon] || '*') << (h[:dow] || '*')
        s << h[:tz] if h[:tz]
p s.join(' ')

        Fugit::Cron.parse(s.join(' '))
      end

#      def parse_crons(s, a, opts)
#
#        hms, aa = a
#          .partition { |e| e[0] == :point && e[1][0] == :hour }
#        ms = hms
#          .inject({}) { |h, e| (h[e[1][1]] ||= []) << e[1][2]; h }
#          .values
#          .uniq
#        crons =
#          ms.size > 1 ?
#          hms.collect { |e| parse_cron([ e ] + aa, opts) } :
#          [ parse_cron(a, opts) ]
#
#        fail ArgumentError.new(
#          "multiple crons in #{s.inspect} " +
#          "(#{crons.collect(&:original).join(' | ')})"
#        ) if opts[:multi] == :fail && crons.size > 1
#
#        if opts[:multi] == true || (opts[:multi] && opts[:multi] != :fail)
#          crons
#        else
#          crons.first
#        end
#      end

      def eone(e); e1 = e[1]; e1 == 1 ? '*' : "*/#{e1}"; end

      def parse_interval_elt(e, opts, h)

        case e[2]
        when 's', 'sec', 'second', 'seconds'
          h[:sec] = eone(e)
        when 'm', 'min', 'mins', 'minute', 'minutes'
          #(h[:hms] ||= []) << [ '*', eone(e) ]
          h[:hms] ||= [ [ '*', eone(e) ] ]
        when 'h', 'hour', 'hours'
          h[:hms] ||= [ [ eone(e), 0 ] ]
        when 'd', 'day', 'days'
          h[:hms] ||= [ [ 0, 0 ] ]
        when 'w', 'week', 'weeks'
          h[:hms] ||= [ [ 0, 0 ] ]
          h[:dow] ||= 0
        when 'M', 'month', 'months'
          h[:hms] ||= [ [ 0, 0 ] ]
          h[:dom] = 1
          h[:mon] = eone(e)
        when 'Y', 'y', 'year', 'years'
          h[:hms] ||= [ [ 0, 0 ] ]
          h[:dom] = 1
          h[:mon] = 1
        end
      end

      def parse_day_list_elt(e, opts, h)

        h[:dow] = e[1..-1].collect(&:to_s).sort.join(',')
      end

      def parse_day_range_elt(e, opts, h)

        h[:dow] = e[1] == e[2] ? e[1] : "#{e[1]}-#{e[2]}"
      end

      def parse_at_elt(e, opts, h)

        (h[:hms] ||= []).concat(e[1])

        l = h[:hms].last
        h[:sec] = l.pop if l.size > 2
      end

      def parse_on_elt(e, opts, h)

        e1 = e[1]
        h[:dow] = e1[0]
        h[:hms] = [ e1[1] ]

        l = h[:hms].last
        h[:sec] = l.pop if l.size > 2
      end

      def parse_tz_elt(e, opts, h)

        h[:tz] = e[1]
      end
    end

    module Parser include Raabro

      NUMS = %w[
        zero one two three four five six seven eight nine ten eleven twelve ]

      WEEKDAYS =
        Fugit::Cron::Parser::WEEKDS + Fugit::Cron::Parser::WEEKDAYS

      NHOURS = {
        'noon' => [ 12, 0 ],
        'midnight' => [ 0, 0 ], 'oh' => [ 0, 0 ] }
      NMINUTES = {
        "o'clock" => 0, 'five' => 5,
        'ten' => 10, 'fifteen' => 15,
        'twenty' => 20, 'twenty-five' => 25,
        'thirty' => 30, 'thirty-five' => 35,
        'fourty' => 40, 'fourty-five' => 45,
        'fifty' => 50, 'fifty-five' => 55 }

      # piece parsers bottom to top

      def _from(i); rex(nil, i, /\s*from\s+/); end
      def _every(i); rex(nil, i, /\s*(every)\s+/); end
      def _at(i); rex(nil, i, /\s*at\s+/); end
      def _in(i); rex(nil, i, /\s*(in|on)\s+/); end
      def _to(i); rex(nil, i, /\s*to\s+/); end
      def _dash(i); rex(nil, i, /-\s*/); end
      def _and(i); rex(nil, i, /\s*and\s+/); end
      def _on(i); rex(nil, i, /\s*on\s+/); end

      def _and_or_comma(i)
        rex(nil, i, /\s*(,?\s*and\s|,?\s*or\s|,)\s*/)
      end
      def _at_comma(i)
        rex(nil, i, /\s*(at\s|,|)\s*/)
      end
      def _to_through(i)
        rex(nil, i, /\s*(to|through)\s+/)
      end

      def integer(i); rex(:int, i, /\d+\s*/); end

      def tz_name(i)
        rex(nil, i,
          /\s*[A-Z][a-zA-Z0-9+\-]+(\/[A-Z][a-zA-Z0-9+\-_]+){0,2}(\s+|$)/)
      end
      def tz_delta(i)
        rex(nil, i,
          /\s*[-+]([01][0-9]|2[0-4]):?(00|15|30|45)(\s+|$)/)
      end
      def tzone(i)
        alt(:tzone, i, :tz_delta, :tz_name)
      end

      def and_named_digits(i)
rex(:xxx, i, 'TODO')
      end

      def dname(i)
        rex(:dname, i, /(s(ec(onds?)?)?|m(in(utes?)?)?)\s+/)
      end
      def named_digit(i)
        seq(:named_digit, i, :dname, :integer)
      end
      def named_digits(i)
        seq(nil, i, :named_digit, '+', :and_named_digits, '*')
      end

      def am_pm(i)
        rex(:am_pm, i, /\s*(am|pm|dark)\s*/i)
      end

      def nminute(i)
        rex(:nminute, i, /(#{NMINUTES.keys.join('|')})\s*/i)
      end
      def nhour(i)
        rex(:nhour, i, /(#{NUMS.join('|')})\s*/i)
      end
      def numeral_hour(i)
        seq(:numeral_hour, i, :nhour, :am_pm, '?', :nminute, '?')
      end

      def named_hour(i)
        rex(:named_hour, i, /(#{NHOURS.keys.join('|')})/i)
      end

      def shour(i)
        rex(:shour, i, /(2[0-4]|[01]?[0-9])/)
      end
      def simple_hour(i)
        seq(:simple_hour, i, :shour, :am_pm, '?')
      end

      def digital_hour(i)
        rex(:digital_hour, i, /(2[0-4]|[01][0-9]):?[0-5]\d/)
      end

      def at_point(i)
        alt(nil, i,
          :digital_hour, :simple_hour, :named_hour, :numeral_hour,
          :named_digits)
      end

      def weekday(i)
        rex(:weekday, i, /(#{WEEKDAYS.reverse.join('|')})\s*/i)
      end

      def and_at(i)
        seq(nil, i, :_and_or_comma, :at_point)
      end

      def _intervals(i)
        rex(:intervals, i,
          /(
            y(ears?)?|months?|w(eeks?)?|d(ays?)?|
            h(ours?)?|m(in(ute)?s?)?|s(ec(ond)?s?)?
          )(\s+|$)/ix)
      end

      def sinterval(i)
        rex(:sinterval, i,
          /(year|month|week|day|hour|min(ute)?|sec(ond)?)(\s+|$)/i)
      end
      def ninterval(i)
        seq(:ninterval, i, :integer, :_intervals)
      end

      def day_class(i)
        rex(:day_class, i, /(weekday)(\s+|$)/)
      end

      def day(i)
        seq(:day, i, :weekday)
      end
      def and_or_day(i)
        seq(nil, i, :_and_or_comma, :day)
      end
      def day_list(i)
        seq(:day_list, i, :day, :and_or_day, '*')
      end

      def to_day_range(i)
        seq(:day_range, i, :weekday, :_to_through, :weekday)
      end
      def dash_day_range(i)
        seq(:day_range, i, :weekday, :_dash, :weekday)
      end
      def day_range(i)
        alt(nil, i, :to_day_range, :dash_day_range)
      end

      def interval(i)
        alt(nil, i, :sinterval, :ninterval)
      end

      def every_object(i)
        alt(nil, i, :interval, :day_range, :day_list, :day_class)
      end
      def from_object(i)
        alt(nil, i, :interval, :to_day_range)
      end

      def tz(i)
        seq(nil, i, :_in, '?', :tzone)
      end
      def on(i)
        seq(:on, i, :_on, :weekday, :at_point, :and_at, '*')
      end
      def at(i)
        seq(:at, i, :_at_comma, :at_point, :and_at, '*')
      end
      def from(i)
        seq(:from, i, :_from, :from_object)
      end
      def every(i)
        seq(:every, i, :_every, :every_object)
      end

      def at_from(i)
        seq(nil, i, :at, :from, :tz, '?')
      end
      def at_every(i)
        seq(nil, i, :at, :every, :tz, '?')
      end

      def from_at(i)
        seq(nil, i, :from, :at, '?', :tz, '?')
      end

      def every_(i)
        seq(nil, i, :every, :tz, '?')
      end
      def every_on(i)
        seq(nil, i, :every, :on, :tz, '?')
      end
      def every_at(i)
        seq(nil, i, :every, :at, :tz, '?')
      end

      def nat(i)
        alt(:nat, i,
          :every_at, :every_on, :every_,
          :from_at,
          :at_every, :at_from)
      end

      # rewrite parsed tree

      #def _rewrite_single(t)
      #  [ t.name, rewrite(t.sublookup(nil)) ]
      #end
      def _rewrite_children(t)
        t.subgather(nil).collect { |tt| rewrite(tt) }
      end
      def _rewrite_multiple(t)
        [ t.name, _rewrite_children(t) ]
      end
      def _rewrite_child(t)
        rewrite(t.sublookup(nil))
      end

      def rewrite_tzone(t)

        [ :tz, t.strim ]
      end

      def rewrite_sinterval(t)

        [ :interval, 1, t.strim ]
      end

      def rewrite_ninterval(t)

        [ :interval,
          t.sublookup(:int).string.to_i,
          t.sublookup(:intervals).strim ]
      end

      def rewrite_named_digit(t)

        i = t.sublookup(:int).string.to_i

        case n = t.sublookup(:dname).strim
        when /^s/ then [ '*', '*', i ]
        when /^m/ then [ '*', i ]
        end
      end

      def rewrite_named_hour(t)
        NHOURS[t.strim.downcase]
      end
      def rewrite_numeral_hour(t)
        vs = t.subgather(nil).collect { |st| st.strim.downcase }
        v = NUMS.index(vs[0])
        v += 12 if vs[1] == 'pm'
        m = NMINUTES[vs[2]] || 0
        [ v, m ]
      end
      def rewrite_simple_hour(t)
        vs = t.subgather(nil).collect { |st| st.strim.downcase }
        v = vs[0].to_i
        v += 12 if vs[1] == 'pm'
        [ v, 0 ]
      end
      def rewrite_digital_hour(t)
        m = t.string.match(/(\d\d?):?(\d\d)/)
        [ m[1].to_i, m[2].to_i ]
      end

      def rewrite_weekday(t)

        WEEKDAYS.index(t.strim.downcase[0, 3])
      end

      alias rewrite_day _rewrite_child

      def rewrite_day_list(t)

        [ :day_list, *_rewrite_children(t) ]
      end

      def rewrite_day_class(t)

        [ :day_range, 1, 5 ] # only "weekday" for now
      end

      def rewrite_day_range(t)

        tts = t.subgather(nil)

        [ :day_range, rewrite(tts[0]), rewrite(tts[1]) ]
      end

      alias rewrite_on _rewrite_multiple
      alias rewrite_at _rewrite_multiple

      alias rewrite_from _rewrite_child
      alias rewrite_every _rewrite_child

      def rewrite_nat(t)

        t.subgather(nil).collect { |tt| rewrite(tt) }
.tap { |x| pp x }
      end
    end
  end
end

