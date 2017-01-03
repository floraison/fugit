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

    attr_reader :original

    def self.new(s)

      parse(s)
    end

    def self.parse(s)

#p s; Raabro.pp(Parser.parse(s, debug: 3))
      self.allocate.send(:init, s, Parser.parse(s))
    end

    def to_sec

fail NotImplementedError # TODO
    end

    KEYS = {
      yea: { a: 'Y', d: 365 * 24 * 3600 },
      mon: { a: 'M', d: 30 * 24 * 3600 },
      wee: { a: 'W', d: 7 * 24 * 3600 },
      day: { a: 'D', d: 24 * 3600 },
      hou: { a: 'h', d: 3600 },
      min: { a: 'm', d: 60 },
      sec: { a: 's', d: 1 },
    }

    def to_duration_s

      KEYS.inject(StringIO.new) { |s, (k, a)|
        v = @h[k]; s << "#{v}#{a[:a]}" if v; s
      }.string
    end

    def to_iso_duration_s

fail NotImplementedError # TODO
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

