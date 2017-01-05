#--
# Copyright (c) 2017-2017, John Mettraux, jmettraux+flor@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


module Fugit

  class Cron

    SPECIALS = {
      '@reboot' => :reboot,
      '@yearly' => '0 0 1 1 *',
      '@annually' => '0 0 1 1 *',
      '@monthly' => '0 0 1 * *',
      '@weekly' => '0 0 * * 0',
      '@daily' => '0 0 * * *',
      '@midnight' => '0 0 * * *',
      '@hourly' => '0 * * * *',
    }

    attr_reader :original

    attr_reader :minutes, :hours, :monthdays, :months, :weekdays

    def self.new(original)

      parse(original)
    end

    def to_cron_s

      @cron_s ||=
        [
          @seconds == [ 0 ] ? nil : (@seconds || [ '*' ]).join(','),
          (@minutes || [ '*' ]).join(','),
          (@hours || [ '*' ]).join(','),
          (@monthdays || [ '*' ]).join(','),
          (@months || [ '*' ]).join(','),
          (@weekdays || [ [ '*' ] ]).map { |d| d.compact.join('#') }.join(',')
        ].compact.join(' ')
    end

    def self.parse(s)

      return s if s.is_a?(self)

      original = s
      s = SPECIALS[s] || s

#p s; Raabro.pp(Parser.parse(s, debug: 3))
      h = Parser.parse(s)

      return nil unless h

      self.allocate.send(:init, s, h)
    end

    def self.do_parse(s)

      parse(s) || fail(ArgumentError.new("not a cron string #{s.inspect}"))
    end

    class NextTime # TODO at some point, use ZoTime

      def initialize(t)
        @t = t.is_a?(NextTime) ? t.time : t
      end

      def time; @t; end
      def to_i; @t.to_i; end

      %w[ year month day wday hour min sec ]
        .collect(&:to_sym).each { |k| define_method(k) { @t.send(k) } }

      def inc(i)
        u = @t.utc?
        @t = ::Time.at(@t.to_i + i)
        @t = @t.utc if u
        self
      end
      def dec(i); inc(-i); end

      def inc_month
        y = @t.year
        m = @t.month + 1
        if m == 13; m = 1; y += 1; end
        @t = Time.send((@t.utc? ? :utc : :local), y, m)
        self
      end
      def inc_day; inc((24 - @t.hour) * 3600 - @t.min * 60 - @t.sec); end
      def inc_hour; inc((60 - @t.min) * 60 - @t.sec); end
      def inc_min; inc(60 - @t.sec); end

      def inc_sec(seconds)
        if s = seconds.find { |s| s > @t.sec }
          inc(s - @t.sec)
        else
          inc(60 - @t.sec + seconds.first)
        end
      end

      def dec_month
        dec(@t.day * 24 * 3600 + @t.hour * 3600 + @t.min * 60 + @t.sec + 1)
      end
      def dec_day; dec(@t.hour * 3600 + @t.min * 60 + @t.sec + 1); end
      def dec_hour; dec(@t.min * 60 + @t.sec + 1); end
      def dec_min; dec(@t.sec + 1); end

      def dec_sec(seconds)
        target = seconds.reverse.find { |s| s < @t.sec } || seconds.last
        inc(target - @t.sec)
      end

      def count_weeks(inc)
        c = 0
        t = @t
        until t.month != @t.month
          c += 1
          t += inc * (7 * 24 * 3600)
        end
        c
      end

      def wday_in_month
        [ count_weeks(-1), - count_weeks(1) ]
      end
    end

    def month_match?(nt); ( ! @months) || @months.include?(nt.month); end
    def hour_match?(nt); ( ! @hours) || @hours.include?(nt.hour); end
    def min_match?(nt); ( ! @minutes) || @minutes.include?(nt.min); end
    def sec_match?(nt); ( ! @seconds) || @seconds.include?(nt.sec); end

    def weekday_match?(nt)

      return true if @weekdays.nil?

      wd, hsh = @weekdays.find { |wd, hsh| wd == nt.wday }

      return false unless wd
      return true if hsh.nil?

      phsh, nhsh = nt.wday_in_month

      if hsh > 0
        hsh == phsh # positive wday, from the beginning of the month
      else
        hsh == nhsh # negative wday, from the end of the month, -1 == last
      end
    end

    def monthday_match?(nt)

      return true if @monthdays.nil?

      last = (NextTime.new(nt).inc_month.time - 24 * 3600).day + 1

      @monthdays
        .collect { |d| d < 1 ? last + d : d }
        .include?(nt.day)
    end

    def day_match?(nt)

      return weekday_match?(nt) || monthday_match?(nt) \
        if @weekdays && @monthdays

      return false unless weekday_match?(nt)
      return false unless monthday_match?(nt)

      true
    end

    def match?(t)

      t = Fugit.do_parse_at(t)
      t = NextTime.new(t)

      month_match?(t) && day_match?(t) &&
      hour_match?(t) && min_match?(t) && sec_match?(t)
    end

    def next_time(from=Time.now)

      nt = NextTime.new(from)

      loop do
#p [ :l, Fugit.time_to_s(nt.time) ]
        (from.to_i == nt.to_i) && (nt.inc(1); next)
        month_match?(nt) || (nt.inc_month; next)
        day_match?(nt) || (nt.inc_day; next)
        hour_match?(nt) || (nt.inc_hour; next)
        min_match?(nt) || (nt.inc_min; next)
        sec_match?(nt) || (nt.inc_sec(@seconds); next)
        break
      end

      nt.time
    end

    def previous_time(from=Time.now)

      nt = NextTime.new(from)

      loop do
#p [ :l, Fugit.time_to_s(nt.time) ]
        month_match?(nt) || (nt.dec_month; next)
        day_match?(nt) || (nt.dec_day; next)
        hour_match?(nt) || (nt.dec_hour; next)
        min_match?(nt) || (nt.dec_min; next)
        sec_match?(nt) || (nt.dec_sec(@seconds); next)
        #nt.dec_sec
        break
      end

      nt.time
    end

    # Mostly used as a #next_time sanity check.
    # Avoid for "business" use, it's slow.
    #
    # 2017 is non leap year (though it is preceded by a leap second)
    #
    def brute_frequency(year=2017)

      FREQUENCY_CACHE["#{to_cron_s}|#{year}"] ||=
        begin

          deltas = []

          t = Time.parse("#{year}-01-01") - 1
          t0 = nil
          t1 = nil
          loop do
            t1 = next_time(t)
            deltas << (t1 - t).to_i if t0
            t0 ||= t1
            break if deltas.any? && t1.year > year
            break if t1.year - t0.year > 7
            t = t1
          end

          occurences = deltas.size
          span = t1 - t0
          span_years = span / (365 * 24 * 3600)
          yearly_occurences = occurences.to_f / span_years

          [ deltas.min, deltas.max, occurences,
            span.to_i, span_years.to_i, yearly_occurences.to_i ]
        end
    end

    def to_a

      [ @seconds, @minutes, @hours, @monthdays, @months, @weekdays ]
    end

    def ==(o)

      o.is_a?(::Fugit::Cron) && o.to_a == to_a
    end
    alias eql? ==

    def hash

      to_a.hash
    end

    protected

    FREQUENCY_CACHE = {}

    def init(original, h)

      @original = original
      @cron_s = nil # just to be sure

      determine_seconds(h[:sec])
      determine_minutes(h[:min])
      determine_hours(h[:hou])
      determine_monthdays(h[:dom])
      determine_months(h[:mon])
      determine_weekdays(h[:dow])

      self
    end

    def expand(min, max, r)

      sta, edn, sla = r

      sla = nil if sla == 1 # don't get fooled by /1

      return [ nil ] if sta.nil? && edn.nil? && sla.nil?
      return [ sta ] if sta && edn.nil?

      sla = 1 if sla == nil
      sta = min if sta == nil
      edn = max if edn == nil
      sta, edn = edn, sta if sta > edn

      (sta..edn).step(sla).to_a
    end

    def compact(key)

      arr = instance_variable_get(key)

      return instance_variable_set(key, nil) if arr.include?(nil)
        # reductio ad astrum

      arr.uniq!
      arr.sort!
    end

    def determine_seconds(a)
      @seconds = (a || [ 0 ]).inject([]) { |a, r| a.concat(expand(0, 59, r)) }
      compact(:@seconds)
    end

    def determine_minutes(a)
      @minutes = a.inject([]) { |a, r| a.concat(expand(0, 59, r)) }
      compact(:@minutes)
    end

    def determine_hours(a)
      @hours = a.inject([]) { |a, r| a.concat(expand(0, 23, r)) }
      @hours = @hours.collect { |h| h == 24 ? 0 : h }
      compact(:@hours)
    end

    def determine_monthdays(a)
      @monthdays = a.inject([]) { |a, r| a.concat(expand(1, 31, r)) }
      compact(:@monthdays)
    end

    def determine_months(a)
      @months = a.inject([]) { |a, r| a.concat(expand(1, 12, r)) }
      compact(:@months)
    end

    def determine_weekdays(a)

      @weekdays = []

      a.each do |a, z, s, h| # a to z, slash and hash
        if h
          @weekdays << [ a, h ]
        elsif s
          ((a || 0)..(z || (a ? a : 6))).step(s < 1 ? 1 : s)
            .each { |i| @weekdays << [ i ] }
        elsif z
          (a..z).each { |i| @weekdays << [ i ] }
        elsif a
          @weekdays << [ a ]
        #else
        end
      end

      @weekdays.each { |wd| wd[0] = 0 if wd[0] == 7 } # turn sun7 into sun0
      @weekdays.uniq!
      @weekdays = nil if @weekdays.empty?
    end

    module Parser include Raabro

      WEEKDAYS = %w[ sunday monday tuesday wednesday thursday friday saturday ]
      WEEKDS = WEEKDAYS.collect { |d| d[0, 3] }

      MONTHS = %w[ - jan feb mar apr may jun jul aug sep oct nov dec ]

      # piece parsers bottom to top

      def s(i); rex(nil, i, /[ \t]+/); end
      def star(i); str(nil, i, '*'); end
      def hyphen(i); str(nil, i, '-'); end
      def comma(i); str(nil, i, ','); end

      def slash(i); rex(:slash, i, /\/\d\d?/); end

      def core_mos(i); rex(:mos, i, /[0-5]?\d/); end # min or sec
      def core_hou(i); rex(:hou, i, /(2[0-4]|[01]?[0-9])/); end
      def core_dom(i); rex(:dom, i, /(-?(3[01]|[012]?[0-9])|last|l)/i); end
      def core_mon(i); rex(:mon, i, /(1[0-2]|0?[0-9]|#{MONTHS[1..-1].join('|')})/i); end
      def core_dow(i); rex(:dow, i, /([0-7]|#{WEEKDS.join('|')})/i); end

      def dow_hash(i); rex(:hash, i, /#(-?[1-5]|last|l)/i); end

      def mos(i); core_mos(i); end
      def hou(i); core_hou(i); end
      def dom(i); core_dom(i); end
      def mon(i); core_mon(i); end
      def dow(i); core_dow(i); end

      def _mos(i); seq(nil, i, :hyphen, :mos); end
      def _hou(i); seq(nil, i, :hyphen, :hou); end
      def _dom(i); seq(nil, i, :hyphen, :dom); end
      def _mon(i); seq(nil, i, :hyphen, :mon); end
      def _dow(i); seq(nil, i, :hyphen, :dow); end

      # r: range
      def r_mos(i); seq(nil, i, :mos, :_mos, '?'); end
      def r_hou(i); seq(nil, i, :hou, :_hou, '?'); end
      def r_dom(i); seq(nil, i, :dom, :_dom, '?'); end
      def r_mon(i); seq(nil, i, :mon, :_mon, '?'); end
      def r_dow(i); seq(nil, i, :dow, :_dow, '?'); end

      # sor: star or range
      def sor_mos(i); alt(nil, i, :star, :r_mos); end
      def sor_hou(i); alt(nil, i, :star, :r_hou); end
      def sor_dom(i); alt(nil, i, :star, :r_dom); end
      def sor_mon(i); alt(nil, i, :star, :r_mon); end
      def sor_dow(i); alt(nil, i, :star, :r_dow); end

      # sorws: star or range with[out] slash
      def sorws_mos(i); seq(:elt, i, :sor_mos, :slash, '?'); end
      def sorws_hou(i); seq(:elt, i, :sor_hou, :slash, '?'); end
      def sorws_dom(i); seq(:elt, i, :sor_dom, :slash, '?'); end
      def sorws_mon(i); seq(:elt, i, :sor_mon, :slash, '?'); end
      def sorws_dow(i); seq(:elt, i, :sor_dow, :slash, '?'); end

      def h_dow(i); seq(:elt, i, :core_dow, :dow_hash); end

      def _sorws_dow(i); alt(nil, i, :h_dow, :sorws_dow); end

      def list_sec(i); jseq(:sec, i, :sorws_mos, :comma); end
      def list_min(i); jseq(:min, i, :sorws_mos, :comma); end
      def list_hou(i); jseq(:hou, i, :sorws_hou, :comma); end
      def list_dom(i); jseq(:dom, i, :sorws_dom, :comma); end
      def list_mon(i); jseq(:mon, i, :sorws_mon, :comma); end
      def list_dow(i); jseq(:dow, i, :_sorws_dow, :comma); end

      def lsec_(i); seq(nil, i, :list_sec, :s); end
      def lmin_(i); seq(nil, i, :list_min, :s); end
      def lhou_(i); seq(nil, i, :list_hou, :s); end
      def ldom_(i); seq(nil, i, :list_dom, :s); end
      def lmon_(i); seq(nil, i, :list_mon, :s); end
      alias ldow list_dow

      def classic_cron(i)
        seq(:ccron, i, :lmin_, :lhou_, :ldom_, :lmon_, :ldow)
      end
      def second_cron(i)
        seq(:scron, i, :lsec_, :lmin_, :lhou_, :ldom_, :lmon_, :ldow)
      end

      def cron(i)
        alt(:cron, i, :second_cron, :classic_cron)
      end

      # rewriting the parsed tree

      def to_i(k, t)

        s = t.string.downcase

        (k == :mon && MONTHS.index(s)) ||
        (k == :dow && WEEKDS.index(s)) ||
        ((k == :dom) && s[0, 1] == 'l' && -1) || # L, l, last
        s.to_i
      end

      def rewrite_elt(k, t)

        (a, z), others = t
          .subgather(nil)
          .partition { |tt| ![ :hash, :slash ].include?(tt.name) }
        s = others.find { |tt| tt.name == :slash }
        h = others.find { |tt| tt.name == :hash }

        h = h ? h.string[1..-1] : nil
        h = -1 if h && h.upcase[0, 1] == 'L'
        h = h.to_i if h

        a = a ? to_i(k, a) : nil
        z = z ? to_i(k, z) : nil
        a, z = z, a if a && z && a > z

        [ a, z, s ? s.string[1..-1].to_i : nil, h ]
      end

      def rewrite_entry(t)

        t
          .subgather(:elt)
          .collect { |et| rewrite_elt(t.name, et) }
      end

      def rewrite_cron(t)

        t
          .sublookup(nil) # go to :ccron or :scron
          .subgather(nil) # list min, hou, mon, ...
          .inject({}) { |h, tt| h[tt.name] = rewrite_entry(tt); h }
      end
    end
  end
end

