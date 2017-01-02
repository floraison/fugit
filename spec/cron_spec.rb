
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
    [ '* * L * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '* * last * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '* * -1 * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '0 0 -4,-3 * *', '2016-02-26 00:00:00', '2016-02-01' ],
    [ '0 0 -4,-3 * *', '2016-02-27 00:00:00', '2016-02-26 12:00' ],

    [ '* * * * sun', '2017-01-8' ],

    [ '* * -2 * *', '2017-01-30' ],

    [ '* * * * mon#2', '2017-01-09' ],
    [ '* * * * mon#-1', '2017-01-30' ],
    [ '* * * * tue#L', '2017-01-31' ],
    [ '* * * * tue#last', '2017-01-31' ],
    [ '* * * * mon#2,tue', '2016-12-06', '2016-12-01' ],
    [ '* * * * mon#2,tue', '2016-12-12', '2016-12-07' ],

    # Note: The day of a command's execution can be specified by two fields
    # -- day of month, and day of week.
    # If both fields are restricted (ie, are not *), the command will be run
    # when either field matches the current time.  For example,
    # ``30 4 1,15 * 5'' would cause a command to be run at 4:30 am on the
    # 1st and 15th of each month, plus every Friday.
    #
    # Thanks to Dominik Sander for pointing to that in
    # https://github.com/jmettraux/rufus-scheduler/pull/226

    [ '30 04 1,15 * 5', '2017-01-06 04:30:00', '2017-01-03' ],
    [ '30 04 1,15 * 5', '2017-01-15 04:30:00', '2017-01-14' ],
    [ '30 04 1,15 * 5', '2017-01-20 04:30:00', '2017-01-16' ],
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

