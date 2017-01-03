
require 'fugit'

c = Fugit::Cron.parse('0 0 * *  sun')
  # or
c = Fugit::Cron.new('0 0 * *  sun')

p Time.now  # => 2017-01-03 09:53:27 +0900

p c.next_time      # => 2017-01-08 00:00:00 +0900
p c.previous_time  # => 2017-01-01 00:00:00 +0900

p c.brute_frequency  # => [ 604800, 604800, 53 ]
                     #    [ delta min, delta max, occurrence count ]

