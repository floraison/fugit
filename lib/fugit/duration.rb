
module Fugit

  class Duration

    attr_reader :original, :h

    def self.new(s)

      parse(s)
    end

    def self.parse(s, opts={})

      return s if s.is_a?(self)

      original = s

      s = s.to_s if s.is_a?(Numeric)

      return nil unless s.is_a?(String)

      s = s.strip
      s = s + 's' if s.match(/\A-?(\d*\.)?\d+\z/)
#p [ original, s ]; Raabro.pp(Parser.parse(s, debug: 3))

      h =
        if opts[:iso]
          IsoParser.parse(opts[:stricter] ? s : s.upcase)
        elsif opts[:plain]
          Parser.parse(s)
        else
          Parser.parse(s) || IsoParser.parse(opts[:stricter] ? s : s.upcase)
        end

      h ? self.allocate.send(:init, original, h) : nil
    end

    def self.do_parse(s, opts={})

      parse(s, opts) || fail(ArgumentError.new("not a duration #{s.inspect}"))
    end

    KEYS = {
      yea: { a: 'Y', i: 'Y', s: 365 * 24 * 3600, x: 0, l: 'year' },
      mon: { a: 'M', i: 'M', s: 30 * 24 * 3600, x: 1, l: 'month' },
      wee: { a: 'W', i: 'W', s: 7 * 24 * 3600, I: true, l: 'week' },
      day: { a: 'D', i: 'D', s: 24 * 3600, I: true, l: 'day' },
      hou: { a: 'h', i: 'H', s: 3600, I: true, l: 'hour' },
      min: { a: 'm', i: 'M', s: 60, I: true, l: 'minute' },
      sec: { a: 's', i: 'S', s: 1, I: true, l: 'second' },
    }
    INFLA_KEYS, NON_INFLA_KEYS =
      KEYS.partition { |k, v| v[:I] }

    def to_plain_s

      KEYS.inject(StringIO.new) { |s, (k, a)|
        v = @h[k]; next s unless v; s << v.to_s; s << a[:a]
      }.string
    end

    def to_iso_s

      t = false

      s = StringIO.new
      s << 'P'

      KEYS.each_with_index do |(k, a), i|
        v = @h[k]; next unless v
        if i > 3 && t == false
          t = true
          s << 'T'
        end
        s << v.to_s; s << a[:i]
      end

      s.string
    end

    def to_long_s(opts={})

      s = StringIO.new
      adn = [ false, 'no' ].include?(opts[:oxford]) ? ' and ' : ', and '

      a = @h.to_a
      while kv = a.shift
        k, v = kv
        aa = KEYS[k]
        s << v.to_i
        s << ' '; s << aa[:l]; s << 's' if v > 1
        s << (a.size == 1 ? adn : ', ') if a.size > 0
      end

      s.string
    end

    class << self
      def to_plain_s(o); do_parse(o).deflate.to_plain_s; end
      def to_iso_s(o); do_parse(o).deflate.to_iso_s; end
      def to_long_s(o, opts={}); do_parse(o).deflate.to_long_s(opts); end
    end

    # Warning: this is an "approximation", months are 30 days and years are
    # 365 days, ...
    #
    def to_sec

      KEYS.inject(0) { |s, (k, a)| v = @h[k]; next s unless v; s += v * a[:s] }
    end

    def inflate

      h =
        @h.inject({ sec: 0 }) { |h, (k, v)|
          a = KEYS[k]
          if a[:I]
            h[:sec] += (v * a[:s])
          else
            h[k] = v
          end
          h
        }

      self.class.allocate.init(@original, h)
    end

    def deflate

      id = inflate
      h = id.h.dup
      s = h.delete(:sec) || 0

      INFLA_KEYS.each do |k, v|

        n = s / v[:s]; next if n == 0
        m = s % v[:s]

        h[k] = (h[k] || 0) + n
        s = m
      end

      self.class.allocate.init(@original, h)
    end

    def opposite

      h = @h.inject({}) { |h, (k, v)| h[k] = -v; h }

      self.class.allocate.init(nil, h)
    end

    alias -@ opposite

    def add_numeric(n)

      h = @h.dup
      h[:sec] = (h[:sec] || 0) + n.to_i

      self.class.allocate.init(nil, h)
    end

    def add_duration(d)

      h = d.h.inject(@h.dup) { |h, (k, v)| h[k] = (h[k] || 0) + v; h }

      self.class.allocate.init(nil, h)
    end

    def add_to_time(t)

      INFLA_KEYS.each do |k, a|

        v = @h[k]; next unless v

        t = t + v * a[:s]
      end

      NON_INFLA_KEYS.each do |k, a|

        v = @h[k]; next unless v
        at = [ t.year, t.month, t.day, t.hour, t.min, t.sec ]

        at[a[:x]] += v

        if at[1] > 12
          n, m = at[1] / 12, at[1] % 12
          at[0], at[1] = at[0] + n, m
        elsif at[1] < 1
          n, m = -at[1] / 12, -at[1] % 12
          at[0], at[1] = at[0] - n, m
        end

        t = Time.send(t.utc? ? :utc : :local, *at)
      end

      t
    end

    def add(a)

      case a
      when Numeric then add_numeric(a)
      when Fugit::Duration then add_duration(a)
      when String then add_duration(self.class.parse(a))
      when ::Time, EtOrbi::EoTime then add_to_time(a)
      else fail ArgumentError.new(
        "cannot add #{a.class} instance to a Fugit::Duration")
      end
    end
    alias + add

    def substract(a)

      case a
      when Numeric then add_numeric(-a)
      when Fugit::Duration then add_duration(-a)
      when String then add_duration(-self.class.parse(a))
      when ::Time, EtOrbi::EoTime then add_to_time(a)
      else fail ArgumentError.new(
        "cannot substract #{a.class} instance to a Fugit::Duration")
      end
    end
    alias - substract

    def ==(o)

      o.is_a?(Fugit::Duration) && o.h == @h
    end
    alias eql? ==

    def hash

      @h.hash
    end

    def next_time(from=Time.now)

      add(from)
    end

    protected

    def init(original, h)

      @original = original

      @h = h.reject { |k, v| v == 0 }
        # which copies h btw

      self
    end

    def self.common_rewrite_dur(t)

      t
        .subgather(nil)
        .inject({}) { |h, t|
          v = t.string; v = v.index('.') ? v.to_f : v.to_i
            # drops ending ("y", "m", ...) by itself
          h[t.name] = (h[t.name] || 0) + v
          h
        }
    end

    module Parser include Raabro

      # piece parsers bottom to top

      def sep(i); rex(nil, i, /([ \t,]+|and)*/i); end

      def yea(i); rex(:yea, i, /-?\d+ *y(ears?)?/i); end
      def mon(i); rex(:mon, i, /-?\d+ *(M|months?)/); end
      def wee(i); rex(:wee, i, /-?\d+ *(weeks?|w)/i); end
      def day(i); rex(:day, i, /-?\d+ *(days?|d)/i); end
      def hou(i); rex(:hou, i, /-?\d+ *(hours?|h)/i); end
      def min(i); rex(:min, i, /-?\d+ *(mins?|minutes?|m)/); end

      def sec(i); rex(:sec, i, /-?((\d*\.)?\d+) *(secs?|seconds?|s)/i); end
        # always last!

      def elt(i); alt(nil, i, :yea, :mon, :wee, :day, :hou, :min, :sec); end

      def dur(i); jseq(:dur, i, :elt, :sep); end

      # rewrite parsed tree

      def rewrite_dur(t); Fugit::Duration.common_rewrite_dur(t); end
    end

    module IsoParser include Raabro

      # piece parsers bottom to top

      def p(i); rex(nil, i, /P/); end
      def t(i); rex(nil, i, /T/); end

      def yea(i); rex(:yea, i, /-?\d+Y/); end
      def mon(i); rex(:mon, i, /-?\d+M/); end
      def wee(i); rex(:wee, i, /-?\d+W/); end
      def day(i); rex(:day, i, /-?\d+D/); end
      def hou(i); rex(:hou, i, /-?\d+H/); end
      def min(i); rex(:min, i, /-?\d+M/); end
      def sec(i); rex(:sec, i, /-?(\d*\.)?\d+S/); end

      def delt(i); alt(nil, i, :yea, :mon, :wee, :day); end
      def telt(i); alt(nil, i, :hou, :min, :sec); end

      def date(i); rep(nil, i, :delt, 1); end
      def time(i); rep(nil, i, :telt, 1); end
      def t_time(i); seq(nil, i, :t, :time); end

      def dur(i); seq(:dur, i, :p, :date, '?', :t_time, '?'); end

      # rewrite parsed tree

      def rewrite_dur(t); Fugit::Duration.common_rewrite_dur(t); end
    end
  end
end

