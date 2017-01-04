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

      case e = h[:every]
        when :biz_day
          c.set_weekdays((1..5).to_a.map { |i| [ i, nil ] })
        when :plain_day
          c.set_monthdays(nil)
        else
          c.set_weekdays([ [ Fugit::Cron::Parser::WEEKDS.index(e) ] ])
      end

      c.set_hour(*(h[:at] || [ 0, 0 ]))

      c
    end

    module CronParser include Raabro

      NUMS = %w[
        zero
        one two three four five six seven eight nine
        ten eleven twelve ]

      WEEKDAYS =
        Fugit::Cron::Parser::WEEKDAYS + Fugit::Cron::Parser::WEEKDS

      # piece parsers bottom to top

      def s(i); rex(nil, i, /[ \t]+/); end

      def after(i); rex(:after, i, /[ \t]+after[ \t]+/i); end

      def digital_hour(i)
        rex(:digital_hour, i, /(2[0-4]|[01][0-9]):?[0-5]\d/)
      end
      def simple_hour(i)
        rex(:simple_hour, i, /(2[0-4]|[01]?[0-9])( +(am|pm))?/i)
      end
      def numeral_hour(i)
        rex(:numeral_hour, i, /(#{NUMS.join('|')})( +(am|pm))?/i)
      end
      def name_hour(i)
        rex(:name_hour, i, /(noon|midnight)/i)
      end
      def hour(i)
        alt(nil, i, :numeral_hour, :name_hour, :digital_hour, :simple_hour);
      end

      def min_after_hour(i)
str(nil, i, 'TODO')
      end

      def at_elt(i)
        alt(nil, i, :min_after_hour, :hour);
      end

      def plain_day(i); rex(:plain_day, i, /day/i); end
      def biz_day(i); rex(:biz_day, i, /(biz|business|week) *day/i); end
      def name_day(i); rex(:name_day, i, /#{WEEKDAYS.join('|')}/i); end

      def ev_elt(i)
        alt(nil, i, :plain_day, :biz_day, :name_day)
      end

      def at_(i); rex(nil, i, /at[ \t]+/i); end
      def ev_(i); rex(nil, i, /every[ \t]+/i); end

      def at(i); seq(:at, i, :at_, :at_elt); end
      def ev(i); seq(:ev, i, :ev_, :ev_elt); end

      def ev_at(i); seq(nil, i, :ev, :s, :at); end
      def at_ev(i); seq(nil, i, :at, :s, :ev); end

      def nat(i); alt(:nat, i, :ev_at, :at_ev, :ev); end

      # rewrite parsed tree

      NHOURS = { 'noon' => [ 12, 0 ], 'midnight' => [ 0, 0 ] }

      def rewrite_nat(t)

#Raabro.pp(t)
        h = {}

        et = t.lookup(:ev).sublookup(nil)

        h[:every] = et.name == :name_day ? et.string.downcase[0, 3] : et.name

        at = t.lookup(:at)
        at = at.sublookup(nil) if at

        h[:at] =
          case at && at.name
            when :digital_hour
              s = at.string
              [ s[0, 2], s.split(':')[1] || s[2, 2] ]
            when :simple_hour
              s = at.string.downcase
              v = s.to_i
              [ v + (s.index('pm') ? 12 : 0), 0 ]
            when :numeral_hour
              [ NUMS.index(at.string.downcase), 0 ]
            when :name_hour
              NHOURS[at.string.downcase]
            else nil
          end

        # TODO `10 after 5 pm`

        h
      end
    end
  end
end

