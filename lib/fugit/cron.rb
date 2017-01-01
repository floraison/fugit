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

    def initialize(original, h)

      @original = original
      @h = h
#p @h

      determine_minutes
      determine_hours
      determine_monthdays
      determine_months
      determine_weekdays
#@original = nil; @h = nil; p self
    end

    def self.parse(s)

      original = s
      s = SPECIALS[s] || s

#p s; Raabro.pp(Parser.parse(s, debug: 3))
      x = Parser.parse(s)

      fail ArgumentError.new(
        "couldn't parse #{original.inspect}"
      ) unless x

      self.new(original, x)
    end

    protected

    def unpack_range(min, max, r)

      sta, edn, sla = r

      return [ sta ] if sta && edn.nil?

      sla = 1 if sla == nil
      sta = min if sta == nil
      edn = max if edn == nil

      (sta..edn).step(sla).to_a
    end

    def determine_minutes
      @minutes =
        @h[:min].inject([]) { |a, r| a.concat(unpack_range(0, 59, r)) }
    end

    def determine_hours
      @hours =
        @h[:hou].inject([]) { |a, r| a.concat(unpack_range(0, 23, r)) }
    end

    def determine_monthdays
    end

    def determine_months
      @months =
        @h[:mon].inject([]) { |a, r| a.concat(unpack_range(1, 12, r)) }
    end

    def determine_weekdays
    end

    module Parser include Raabro

      def s(i); rex(:s, i, /[ \t]+/); end
      def star(i); str(:star, i, '*'); end
      def hyphen(i); str(nil, i, '-'); end
      def comma(i); str(nil, i, ','); end

      def slash(i); rex(:slash, i, /\/\d\d?/); end

      def core_min(i); rex(:min, i, /[0-5]?\d/); end
      def core_hou(i); rex(:hou, i, /(2[0-3]|[01]?[0-9])/); end
      def core_dom(i); rex(:dom, i, /(3[01]|[012]?[0-9])/); end
      def core_mon(i); rex(:mon, i, /(1[0-2]|0?[0-9])/); end
      def core_dow(i); rex(:dow, i, /[0-7]/); end

      def min(i); core_min(i); end
      def hou(i); core_hou(i); end
      def dom(i); core_dom(i); end
      def mon(i); core_mon(i); end
      def dow(i); core_dow(i); end

      def _min(i); seq(nil, i, :hyphen, :min); end
      def _hou(i); seq(nil, i, :hyphen, :hou); end
      def _dom(i); seq(nil, i, :hyphen, :dom); end
      def _mon(i); seq(nil, i, :hyphen, :mon); end
      def _dow(i); seq(nil, i, :hyphen, :dow); end

      # r: range
      def r_min(i); seq(nil, i, :min, :_min, '?'); end
      def r_hou(i); seq(nil, i, :hou, :_hou, '?'); end
      def r_dom(i); seq(nil, i, :dom, :_dom, '?'); end
      def r_mon(i); seq(nil, i, :mon, :_mon, '?'); end
      def r_dow(i); seq(nil, i, :dow, :_dow, '?'); end

      # sor: star or range
      def sor_min(i); alt(nil, i, :star, :r_min); end
      def sor_hou(i); alt(nil, i, :star, :r_hou); end
      def sor_dom(i); alt(nil, i, :star, :r_dom); end
      def sor_mon(i); alt(nil, i, :star, :r_mon); end
      def sor_dow(i); alt(nil, i, :star, :r_dow); end

      # sorws: star or range with[out] slash
      def sorws_min(i); seq(nil, i, :sor_min, :slash, '?'); end
      def sorws_hou(i); seq(nil, i, :sor_hou, :slash, '?'); end
      def sorws_dom(i); seq(nil, i, :sor_dom, :slash, '?'); end
      def sorws_mon(i); seq(nil, i, :sor_mon, :slash, '?'); end
      def sorws_dow(i); seq(nil, i, :sor_dow, :slash, '?'); end

      def list_min(i); jseq(:min, i, :sorws_min, :comma); end
      def list_hou(i); jseq(:hou, i, :sorws_hou, :comma); end
      def list_dom(i); jseq(:dom, i, :sorws_dom, :comma); end
      def list_mon(i); jseq(:mon, i, :sorws_mon, :comma); end
      def list_dow(i); jseq(:dow, i, :sorws_dow, :comma); end

      def lmin_(i); seq(nil, i, :list_min, :s); end
      def lhou_(i); seq(nil, i, :list_hou, :s); end
      def ldom_(i); seq(nil, i, :list_dom, :s); end
      def lmon_(i); seq(nil, i, :list_mon, :s); end
      alias ldow list_dow

      def cron(i); seq(:cron, i, :lmin_, :lhou_, :ldom_, :lmon_, :ldow); end

      def rewrite_entry(t)

        k = t.name

        t.children.select { |ct| ct.children.any? }.inject([]) { |a, ct|

          xts = ct.gather(k)
#xts.each { |xt| Raabro.pp(xt) }
          range = xts.any? ? xts.collect { |xt| xt.string.to_i } : []
          while range.size < 2; range << nil; end

          st = ct.lookup(:slash)
          range << (st ? st.string[1..-1].to_i : nil)

          a << range

          a
        }
      end

      SYMS = %w[ min hou dom mon dow ].collect(&:to_sym)

      def rewrite_cron(t)

        SYMS.inject({}) { |h, k| h[k] = rewrite_entry(t.lookup(k)); h }
      end
    end
  end
end

