
#
# Specifying fugit
#
# Mon Jan  2 11:17:40 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Cron do

  NOW = Time.parse('2017-01-02 12:00:00')

  NEXT_TIMES = [

    # min hou dom mon dow, expected next time[, now]

    [ '5 0 * * *', '2017-01-03 00:05:00' ],
    [ '15 14 1 * *', '2017-02-01 14:15:00' ],

    [ '0 0 1 1 *', '2018-01-01 00:00:00' ],
    [ '* * 29 * *', '2017-01-29 00:00:00' ],
    [ '* * 29 * *', '2016-02-29 00:00:00', '2016-02-01' ],

    [ '* * * * sun', '2017-01-8' ],

    [ '* * -2 * *', '2017-01-30' ],
  ]

  describe '#next_time' do

    success =
      proc { |cron, next_time, now|

        it "succeeds #{cron.inspect} -> #{next_time.inspect}" do

          c = Fugit::Cron.parse(cron)
          ent = Time.parse(next_time)
          now = Time.parse(now) if now

          nt = c.next_time(now || NOW)

          expect(
            Fugit.time_to_plain_s(nt)
          ).to eq(
            Fugit.time_to_plain_s(ent)
          )
        end
      }

    NEXT_TIMES.each(&success)
  end

  describe '#match?' do

    success =
      proc { |cron, next_time, _|

        it "succeeds #{cron.inspect} ? #{next_time.inspect}" do

          c = Fugit::Cron.parse(cron)
          ent = Time.parse(next_time)

          expect(c.match?(ent)).to be(true)
        end
      }

    NEXT_TIMES.each(&success)
  end
end

