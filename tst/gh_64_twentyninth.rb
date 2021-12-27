
MAX_YEAR = 2030

#matcher = lambda { |t|
#  if t.month != 2
#    false
#  elsif t.day != 29
#    false
#  elsif t.wday != 0 && t.wday != 6
#    false
#  else
#    true
#  end }

#matcher = lambda { |t|
#  if t.month != 11 || t.day != 11
#    false
#  elsif ! [ 0, 1, 2, 3, 4, 5, 6, 7 ].include?(t.wday)
#    false
#  else
#    true
#  end }
    #
    # ["Fri 2022-11-11", 5]
    # ["Sat 2023-11-11", 6]
    # ["Mon 2024-11-11", 1]
    # ["Tue 2025-11-11", 2]
    # ["Wed 2026-11-11", 3]
    # ["Thu 2027-11-11", 4]
    # ["Sat 2028-11-11", 6]
    # ["Sun 2029-11-11", 0]

  # '0 0 11 * 3-6'  <-------------- NO NO NO it's mday = 11 OR wday in 3-6
  #                                          OR, not AND !!!!
  #
matcher = lambda { |t|
  if t.day != 11
    false
  elsif ! [ 3, 4, 5, 6 ].include?(t.wday)
    false
  else
    true
  end }
    #
    # ["Fri 2022-02-11", 5]
    # ["Fri 2022-03-11", 5]
    # ["Wed 2022-05-11", 3]
    # ["Sat 2022-06-11", 6]
    # ["Thu 2022-08-11", 4]
    # ["Fri 2022-11-11", 5]



t = Time.now

loop do
  t = t + 24 * 3600
  break if t.year >= MAX_YEAR
  p [ t.strftime('%a %F'), t.wday ] if matcher[t]
end

