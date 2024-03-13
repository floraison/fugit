
require 'fugit'

def test(x)
  puts
  puts "  --- #{x} ---"
  c = Fugit.parse_cron(x)
  begin
    puts c.previous_time.strftime('%F %T %:z %A')
  rescue => err
    p err
  end
  #begin
  #  puts c.next_time.strftime('%F %T %:z %A')
  #rescue => err
  #  p err
  #end
end

##Fugit.parse_cron('21 0 * * 1%2')
#test('21 0 * * 1%2')
#test('21 0 * * 1%1')
#
## minute hour day-of-month month day-of-week [flags] command
#
#test('21 0 * * 1%2 UTC')
#test('21 0 * * 1%2 America/Chicago')
#test('21 0 * * 1%2 America/New_York')
#
##test('21 0 * * 1%2 America/Rio_Branco')
##test('21 0 * * 1%2 America/Manaus')
##test('21 0 * * 1%2 America/Belem')
##test('21 0 * * 1%2 America/Fortaleza')
##test('21 0 * * 1%2 America/Recife')
##test('21 0 * * 1%2 America/Araguaina')
##test('21 0 * * 1%2 America/Maceio')
#test('21 0 * * 1%2 America/Bahia')
#test('21 0 * * 1%2 America/Sao_Paulo')
#test('21 0 * * 1%2 America/Campo_Grande')
#test('21 0 * * 1%2 America/Cuiaba')
#test('21 0 * * 1%2 America/Santarem')
##test('21 0 * * 1%2 America/Porto_Velho')
##test('21 0 * * 1%2 America/Boa_Vista')
##test('21 0 * * 1%2 America/Manaus')
##test('21 0 * * 1%2 America/Eirunepe')
##test('21 0 * * 1%2 America/Rio_Branco')

if (ARGV[0] || '').match?(/p/)
  test('21 0 * * 1%2 America/Sao_Paulo')
else
  test('21 0 * * 1%2 America/Santarem')
end

puts

# paulo
#["2024-03-04 23:59:59 -0300", 271, "--", 1, "==", 0, "-->", false]
# santarem
#["2024-03-04 23:59:59 -0300", 270, "--", 0, "==", 0, "-->", true]

#p EtOrbi.make_time('2019-01-01 00:00:00', 'America/Sao_Paulo')
#p EtOrbi.make_time('2019-01-01 00:00:00', 'America/Santarem')
#p EtOrbi.make_time('2019-01-01 00:00:00', 'America/Sao_Paulo').to_s
#p EtOrbi.make_time('2019-01-01 00:00:00', 'America/Santarem').to_s

