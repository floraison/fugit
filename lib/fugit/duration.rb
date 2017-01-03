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

  class Duration

    attr_reader :original, :h

    def self.new(s)

      parse(s)
    end

    def self.parse(s)

#p s; Raabro.pp(Parser.parse(s, debug: 3))
      self.allocate.send(:init, s, Parser.parse(s))
    end

    KEYS = {
      yea: { a: 'Y', i: 'Y', s: 365 * 24 * 3600 },
      mon: { a: 'M', i: 'M', s: 30 * 24 * 3600 },
      wee: { a: 'W', i: 'W', s: 7 * 24 * 3600 },
      day: { a: 'D', i: 'D', s: 24 * 3600, I: true },
      hou: { a: 'h', i: 'H', s: 3600, I: true },
      min: { a: 'm', i: 'M', s: 60, I: true },
      sec: { a: 's', i: 'S', s: 1, I: true },
    }
    INFLA_KEYS = KEYS.select { |k, v| v[:I] }

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
      s = h.delete(:sec)

      INFLA_KEYS.each do |k, v|

        n = s / v[:s]; next if n == 0
        m = s % v[:s]

        h[k] = (h[k] || 0) + n
        s = m
      end

      self.class.allocate.init(@original, h)
    end

    protected

    def init(original, h)

      @original = original
      @h = h

      self
    end

    module Parser include Raabro

      def yea(i); rex(:yea, i, /-?\d+y/i); end
      def mon(i); rex(:mon, i, /-?\d+M/); end
      def wee(i); rex(:wee, i, /-?\d+w/i); end
      def day(i); rex(:day, i, /-?\d+d/i); end
      def hou(i); rex(:hou, i, /-?\d+h/i); end
      def min(i); rex(:min, i, /-?\d+m/); end
      def sec(i); rex(:sec, i, /-?\d+s/i); end
      def elt(i); alt(nil, i, :yea, :mon, :wee, :day, :hou, :min, :sec); end
      def dur(i); rep(:dur, i, :elt, 1); end

      def rewrite_dur(t)

        t.subgather(nil)
          .inject({}) { |h, t| h[t.name] = t.string[0..-2].to_i; h }
      end
    end

    module IsoParser include Raabro
    end

    module LongParser include Raabro
    end
  end
end

