
require 'fugit'

##c = Fugit.parse_cron('20 0 * * wed%4,wed%4+1')
##puts c.next.take(7).map { |t| t.rr.inspect }
#
#
##require 'et-orbi' # >= 1.1.8 and < 1.4.0
#
#puts EtOrbi.parse('2018-12-30').d
#puts EtOrbi.parse('2018-12-31').d
#puts EtOrbi.parse('2019-01-01').d
#puts EtOrbi.parse('2019-01-02').d
#puts EtOrbi.parse('2019-01-31').d
#
#puts EtOrbi.parse('2019-04-11').d
#puts EtOrbi.parse('2025-09-30').d

#require 'et-orbi' # >= 1.1.8 and < 1.4.0

p EtOrbi::VERSION

class EtOrbi::EoTime
  def d # debug
    "%14s | rday: %4d | rweek: %3d" % [ strftime('%a'), rday, rweek ]
  end
end

## the reference
#puts EtOrbi.parse('2019-01-01').d       # => Tue | rday:    1 | rweek:   1
#p EtOrbi.parse('2019-01-01').rweek % 2  # => 1
#
## today (as of this coding...)
#puts EtOrbi.parse('2019-04-11').d       # => Thu | rday:  101 | rweek:  15
#p EtOrbi.parse('2019-04-11').rweek % 2  # => 1
#
#c = Fugit.parse('* * * * tue%2')
#p c.match?('2019-01-01')  # => false, since rweek % 2 == 1
#p c.match?('2019-01-08')  # => true, since rweek % 2 == 0
#
#c = Fugit.parse('* * * * tue%2+1')
#p c.match?('2019-01-01')  # => true, since (rweek + 1) % 2 == 0
#p c.match?('2019-01-08')  # => false, since (rweek + 1) % 2 == 1
#
#Fugit.parse('* * * * tue%2+1')
#
####
#
#puts '---'

class EtOrbi::EoTime
  def d # debug
    "%14s | rday: %4d | rweek: %3d |   %d |   %d" % [
      strftime('%F %a'), rday, rweek, rweek % 2, rweek % 3 ]
  end
end

c = Fugit.parse_cron('20 0 * * mon%2,wed%3+1')
puts c.next('2025-09-21').take(10).map(&:d)

