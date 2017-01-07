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

  def self.parse_at(s)

    Time.parse(s) rescue nil
  end

  def self.do_parse_at(s)

    return s if s.is_a?(Time)
    Time.parse(s)
  end

  def self.parse_cron(s); ::Fugit::Cron.parse(s); end
  def self.parse_duration(s); ::Fugit::Duration.parse(s); end
  def self.parse_in(s); parse_duration(s); end
  def self.parse_nat(s); ::Fugit::Nat.parse(s); end

  def self.do_parse_cron(s); ::Fugit::Cron.do_parse(s); end
  def self.do_parse_duration(s); ::Fugit::Duration.do_parse(s); end
  def self.do_parse_in(s); do_parse_duration(s); end
  def self.do_parse_nat(s); ::Fugit::Nat.do_parse(s); end

  def self.parse(s)

    parse_cron(s) || parse_duration(s) || parse_at(s) || parse_nat(s)
  end

  def self.do_parse(s)

    parse(s) ||
    fail(ArgumentError.new("found no time information in #{s.inspect}"))
  end
end

