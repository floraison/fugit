
#
# Specifying fugit
#
# Mon Jan  2 11:17:40 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Cron do

  describe '#next_time' do

    now = Time.parse('2016-01-02 12:00:00')

    success =
      proc { |cron, next_time|

        it "succeeds #{cron.inspect} -> #{next_time.inspect}" do

          c = Fugit::Cron.parse(cron)
          ent = Time.parse(next_time)

          nt = c.next_time(now)

          expect(
            Fugit.time_to_plain_s(nt)
          ).to eq(
            Fugit.time_to_plain_s(ent)
          )
        end
      }

    [
      [ '5 0 * * *', '2016-01-03 00:05:00' ],
      [ '15 14 1 * *', '2016-02-01 14:15:00' ],
    ].each(&success)
  end
end

