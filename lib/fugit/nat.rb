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

  # A natural language set of parsers for fugit.
  # Focuses on cron expressions. The rest is better left to Chronic and friends.
  #
  module Nat

    def self.parse(s)

#p s; Raabro.pp(CronParser.parse(s, debug: 3))
      h = CronParser.parse(s)
#p h

      c = Fugit::Cron.allocate.send(:init, nil, nil)

      case h[:every]
        when :week_day then c.set_weekdays((1..5).to_a.map { |i| [ i, nil ] })
        #when :plain_day then c.set_monthdays([ nil ])
        else c.set_monthdays(nil)
      end

      case h[:at]
        when 'five' then c.set_hour(5, 0)
        else c.set_hour(12, 0)
      end

      c
    end

    module CronParser include Raabro

      # piece parsers bottom to top

      def s(i); rex(nil, i, /[ \t]+/); end

      def dgt_hou(i); rex(:dgt_hou, i, /\d+/); end
      def wrd_hou(i); rex(:wrd_hou, i, /five/); end

      def plain_day(i); rex(:plain_day, i, /day/i); end
      def week_day(i); rex(:week_day, i, /(biz|business|week) *day/i); end

      def day(i); alt(nil, i, :plain_day, :week_day); end
      def hou(i); alt(:hou, i, :dgt_hou, :wrd_hou); end

      def at_(i); rex(nil, i, /at[ \t]+/i); end
      def ev_(i); rex(nil, i, /every[ \t]+/i); end

      def at(i); seq(:at, i, :at_, :hou); end
      def ev(i); seq(:ev, i, :ev_, :day); end

      def ev_at(i); seq(nil, i, :ev, :s, :at); end
      def at_ev(i); seq(nil, i, :at, :s, :ev); end

      def nat(i); alt(:nat, i, :ev_at, :at_ev, :ev); end

      # rewrite parsed tree

      def rewrite_nat(t)

#Raabro.pp(t)
        evt = t.lookup(:ev)
        dayt = evt.sublookup(nil)
        att = t.lookup(:at)
        hout = att ? att.lookup(:hou) : nil

        { every: dayt.name, at: hout ? hout.string : nil }
      end
    end
  end
end

