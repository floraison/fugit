
#
# exploring weekday modulo crons vs #previous_time
#
#   https://github.com/floraison/fugit/issues/95
#   https://github.com/floraison/fugit/issues/96
#

require 'fugit'

p [ :etorbi, EtOrbi::VERSION ]
p [ :fugit, Fugit::VERSION ]

NOW = Time.parse('2024-03-21 22:00')

def test(x)
  puts
  puts "  --- #{x} ---"
  c = Fugit.parse_cron(x)
  begin
    t = c.previous_time(NOW)
    puts "prev> #{t.strftime('%F %T %:z %A')} #{t.rweek}"
  rescue => err
    puts "\e[31m#{err.inspect}\e[0;0m"
  end
  begin
    t = c.next_time(NOW)
    puts "next> #{t.strftime('%F %T %:z %A')} #{t.rweek}"
  rescue => err
    puts "\e[31m#{err.inspect}\e[0;0m"
  end
end

# minute hour day-of-month month day-of-week

test('21 0 * * 1%2')
test('21 0 * * 1%1')

test('21 0 * * 1%2 UTC')
test('21 0 * * 1%2 America/Chicago')
test('21 0 * * 1%2 America/New_York')

test('21 0 * * 1%2 America/Rio_Branco')
test('21 0 * * 1%2 America/Manaus')
test('21 0 * * 1%2 America/Belem')
test('21 0 * * 1%2 America/Fortaleza')
test('21 0 * * 1%2 America/Recife')
test('21 0 * * 1%2 America/Araguaina')
test('21 0 * * 1%2 America/Maceio')
test('21 0 * * 1%2 America/Bahia')
test('21 0 * * 1%2 America/Sao_Paulo') # works
test('21 0 * * 1%2 America/Campo_Grande')
test('21 0 * * 1%2 America/Cuiaba')
test('21 0 * * 1%2 America/Santarem')
test('21 0 * * 1%2 America/Porto_Velho')
test('21 0 * * 1%2 America/Boa_Vista')
test('21 0 * * 1%2 America/Manaus')
test('21 0 * * 1%2 America/Eirunepe')
test('21 0 * * 1%2 America/Rio_Branco')

test('20 0 * * 2%4 Europe/London') #fails
test('20 0 * * 2%4 Etc/UTC') # fails
test('20 9 * * 2%4 Australia/Melbourne') # fails
test('0 7 * * 2%2 America/Bogota') # fails

test('0 5 * * 2%6 Europe/Berlin')
test('0 10 * * 2%2 America/New_York')
test('20 0 * * 2%2 America/Los_Angeles')
test('20 9 * * 2%8 America/New_York')

#if (ARGV[0] || '').match?(/p/)
#  test('21 0 * * 1%2 America/Sao_Paulo')
#else
#  test('21 0 * * 1%2 America/Santarem')
#end

puts

# paulo
#["2024-03-04 23:59:59 -0300", 271, "--", 1, "==", 0, "-->", false]
# santarem
#["2024-03-04 23:59:59 -0300", 270, "--", 0, "==", 0, "-->", true]

#p EtOrbi.make_time('2019-01-01 00:00:00', 'America/Sao_Paulo')
#p EtOrbi.make_time('2019-01-01 00:00:00', 'America/Santarem')
#p EtOrbi.make_time('2019-01-01 00:00:00', 'America/Sao_Paulo').to_s
#p EtOrbi.make_time('2019-01-01 00:00:00', 'America/Santarem').to_s

