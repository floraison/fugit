
#require 'rufus-scheduler'
require 'fugit'

# https://www.timeanddate.com/time/zone/usa/chicago
# https://www.timeanddate.com/time/change/usa/chicago

# https://www.timeanddate.com/time/zone/usa/newyork
# https://www.timeanddate.com/time/change/usa/newyork


ENV['TZ'] =
  ARGV.find { |a| a.match?(/chi/i) } ?
  'America/Chicago' :
  'America/New_York'
    #
    # using ENV['TZ'] so that Time#to_s stays in ENV['TZ'}

c = Fugit.parse_cron(
  ARGV.find { |a| a.match?(/4/) } ?
  '30 4 * * *' :
  '5 0 * * *')


p [ :tz, ENV['TZ'] ]
p [ :ruby, RUBY_VERSION, RUBY_PLATFORM ]
p [ :tzinfo, TZInfo::VERSION ]
p [ :fugit, Fugit::VERSION ]


# into daylight saving time

puts

t = Time.parse('2021-03-10')
7.times do
  t = c.next_time(t)
  puts "#{t} / #{t.zone}"
end

# out of daylight saving time

puts

t = Time.parse('2021-11-05')
7.times do
  t = c.next_time(t)
  puts "#{t} / #{t.zone}"
end

# into daylight saving time

puts

t = Time.parse('2022-03-10')
7.times do
  t = c.next_time(t)
  puts "#{t} / #{t.zone}"
end

