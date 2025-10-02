
require 'et-orbi'

puts
puts '###   20 0 * * mon%2,wed%3+1'
puts

t = EtOrbi.parse('2025-09-21 12:00')

#p t.to_s
#      (nt.rweek % mo) == (di % mo)

36.times do

  puts "%14s | rweek: %3d | %%2: %d | %%3: %d | +1%%3: %d | cur: %s | new: %s" % [
    t.strftime('%F %a'),
    t.rweek,
    t.rweek % 2, t.rweek % 3, (t.rweek + 1) % 3,
    t.rweek % 3 == 1 % 3,
    t.rweek % 3 - 1 == 0,
      ]

  w = t.rweek
  t = t.add(24 * 3600)
  puts if w != t.rweek
end

