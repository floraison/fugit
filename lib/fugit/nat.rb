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

      return s if s.is_a?(Fugit::Cron) || s.is_a?(Fugit::Duration)

      return nil unless s.is_a?(String)

#p s; Raabro.pp(Parser.parse(s, debug: 3))
      a = Parser.parse(s)

#p a
      return nil unless a

      if a.include?([ :flag, 'every' ])
        parse_cron(a)
      else
        nil
      end
    end

    def self.do_parse(s)

      parse(s) || fail(ArgumentError.new("could not parse a nat #{s.inspect}"))
    end

    def self.parse_cron(a)

      h = { min: nil, hou: [], dom: [ nil ], mon: [ nil ], dow: [ nil ] }

      a.each do |key, val|
        if key == :biz_day
          h[:dow] = [ [ 1, 5 ] ]
        elsif key == :simple_hour || key == :numeral_hour
          (h[:hou] ||= []) << [ val ]
        elsif key == :digital_hour
          h[:hou] = [ val[0, 1] ]
          h[:min] = [ val[1, 1] ]
        elsif key == :name_day
          (h[:dow] ||= []) << [ val ]
        elsif key == :flag && val == 'pm' && h[:hou]
          h[:hou][-1] =  [ h[:hou][-1].first + 12 ]
        end
      end
      h[:min] ||= [ 0 ]
      h[:dow].sort_by! { |a, z| a || 0 }

      Fugit::Cron.allocate.send(:init, nil, h)
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

      def digital_hour(i)
        rex(:digital_hour, i, /(2[0-4]|[01][0-9]):?[0-5]\d/)
      end
      def simple_hour(i)
        rex(:simple_hour, i, /(2[0-4]|[01]?[0-9])/)
      end
      def numeral_hour(i)
        rex(:numeral_hour, i, /(#{NUMS.join('|')})/i)
      end
      def name_hour(i)
        rex(:name_hour, i, /(#{NHOURS.keys.join('|')})/i)
      end
      def hour(i)
        alt(nil, i, :numeral_hour, :name_hour, :digital_hour, :simple_hour);
      end

      def plain_day(i); rex(:plain_day, i, /day/i); end
      def biz_day(i); rex(:biz_day, i, /(biz|business|week) *day/i); end
      def name_day(i); rex(:name_day, i, /#{WEEKDAYS.reverse.join('|')}/i); end

      def flag(i); rex(:flag, i, /(every|day|at|after|am|pm)/i); end

      def datum(i)
        alt(nil, i,
          :flag,
          :plain_day, :biz_day, :name_day,
          :name_hour, :numeral_hour, :digital_hour, :simple_hour)
      end

      def sugar(i); rex(nil, i, /(and|or|[, \t]+)/i); end

      def elt(i); alt(nil, i, :sugar, :datum); end
      def nat(i); rep(:nat, i, :elt, 1); end

      # rewrite parsed tree

      def rewrite_nat(t)

#Raabro.pp(t)
        t
          .subgather(nil)
          .collect { |tt|

            k = tt.name
            v = tt.string.downcase

            case k
              when :numeral_hour
                [ k, NUMS.index(v) ]
              when :simple_hour
                [ k, v.to_i ]
              when :digital_hour
                v = v.gsub(/:/, '')
                [ k, [ v[0, 2], v[2, 2] ] ]
              when :name_hour
                [ :digital_hour, NHOURS[v] ]
              when :name_day
                [ k, WEEKDAYS.index(v[0, 3]) ]
              else
                [ k, v ]
            end
          }
      end
    end
  end
end

