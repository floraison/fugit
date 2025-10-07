
require 'fugit'

c = Fugit.parse_cron('0 12 * * mon%2,wed%3+1')

t = EtOrbi.parse('2025-09-20 12:00')

44.times do

  wd = t.strftime('%a')
  wd = %w[ Mon Wed ].include?(wd) ? '*' + wd.upcase : ' ' + wd.downcase

  puts "%14s | rweek: %3d | %%2: %d == 0 | %%3: %d == 1 | ? %3s" % [
    t.strftime('%F') + ' ' + wd,
    t.rweek,
    t.rweek % 2, t.rweek % 3,
    c.match?(t)
      ].map { |e| e == true ? 'YES' : e == false ? 'no' : e }

  w = t.rweek
  t = t.add(24 * 3600)
  puts if t.rweek != w
end

