
require 'fugit'

t = EtOrbi.parse('2018-12-28 12:00')

15.times do |i|

  puts " * %14s / rday: %5d / rweek: %5d" % [
    t.strftime('%F %a'), t.rday, t.rweek ]

  w = t.rweek
  t = t.add(24 * 3600)
  puts if t.rweek != w

  if i == 8
    puts "\n  (...)\n\n"
    t = EtOrbi.parse('2025-10-04 12:00')
  end
end

