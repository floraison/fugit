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

    def self.parse(s)

      original = s
      s = SPECIALS[s] || s

p s
Raabro.pp(Parser.parse(s, debug: 3))
      x = Parser.parse(s)

      x
    end

    module Parser include Raabro

      def s(i); rex(:s, i, /[ \t]+/); end
      def star(i); str(:star, i, '*'); end

      def min(i); rex(nil, i, /[0-5]?\d/); end
      def hou(i); rex(nil, i, /([01]?[0-9]|2[0-3])/); end
      def dom(i); rex(nil, i, /([012]?[0-9]|3[01])/); end
      def mon(i); rex(nil, i, /(0?[0-9]|1[0-2])/); end
      def dow(i); rex(nil, i, /[0-7]/); end

      def so_min(i); alt(:min, i, :star, :min); end
      def so_hou(i); alt(:hou, i, :star, :hou); end
      def so_dom(i); alt(:dom, i, :star, :dom); end
      def so_mon(i); alt(:mon, i, :star, :mon); end
      def so_dow(i); alt(:dow, i, :star, :dow); end

      def min_(i); seq(nil, i, :so_min, :s); end
      def hou_(i); seq(nil, i, :so_hou, :s); end
      def dom_(i); seq(nil, i, :so_dom, :s); end
      def mon_(i); seq(nil, i, :so_mon, :s); end

      def cron(i); seq(:cron, i, :min_, :hou_, :dom_, :mon_, :so_dow); end

      def rewrite_entry(t)

        t.string
      end

      SYMS = %w[ min hou dom mon dow ].collect(&:to_sym)

      def rewrite_cron(t)

        SYMS.inject({}) { |h, k| h[k] = rewrite_entry(t.lookup(k)); h }
      end
    end
  end
end

