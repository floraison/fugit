
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

    [ '* * * * *', '2017-01-02 12:01:00' ],

    [ '5 0 * * *', '2017-01-03 00:05:00' ],
    [ '15 14 1 * *', '2017-02-01 14:15:00' ],

    [ '0 0 1 1 *', '2018-01-01 00:00:00' ],
    [ '* * 29 * *', '2017-01-29 00:00:00' ],
    [ '* * 29 * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '* * L * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '* * last * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '* * -1 * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '* * L * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '0 0 -4,-3 * *', '2016-02-26 00:00:00', '2016-02-01' ],
    [ '0 0 -4,-3 * *', '2016-02-27 00:00:00', '2016-02-26 12:00' ],

    [ '* * * * sun', '2017-01-8' ],

    [ '* * -2 * *', '2017-01-30' ],
    [ '* * -1 * *', '2017-01-31' ],
    [ '* * L * *', '2017-01-31' ],

    [ '* * * * mon#2', '2017-01-09' ],
    [ '* * * * mon#-1', '2017-01-30' ],
    [ '* * * * tue#L', '2017-01-31' ],
    [ '* * * * tue#last', '2017-01-31' ],
    [ '* * * * mon#2,tue', '2016-12-06', '2016-12-01' ],
    [ '* * * * mon#2,tue', '2016-12-12', '2016-12-07' ],

    [ '0 0 * * mon#2,tue', '2017-01-09', '2017-01-06' ],
    [ '0 0 * * mon#2,tue', '2017-01-31', '2017-01-30' ],

    [ '00 24 * * *', '2017-01-02 00:00:00', '2017-01-01 12:00' ],

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

    #
    # gh-5  '0 8 L * * mon-thu', last day of month on Saturday
    #
    # gh-35  '59 6 1-7 * 2', monthdays 1-7 being ignored

    # Note: The day of a command's execution can be specified by two fields --
    # day of month, and day of week.  If both fields are restricted (ie, are
    # not *), the command will be run when either field matches the current
    # time.  For example, ``30 4 1,15 * 5'' would cause a command to be run
    # at 4:30 am on the 1st and 15th of each month, plus every Friday.

    [ '0 8 L * mon-thu',
      '2018-06-30 08:00:00', '2018-06-28 18:00:00', 'Europe/Berlin' ],
      #
    [ '0 9 -2 * *',
      '2018-06-29 09:00:00', '2018-06-28 18:00:00', 'Europe/Berlin' ],
    [ '0 0 -5 * *',
      '2018-07-27 00:00:00', '2018-06-28 18:00:00', 'Europe/Berlin' ],
      #
    [ '0 8 L * *',
      '2018-06-30 08:00:00', '2018-06-28 18:00:00', 'Europe/Berlin' ],

    [ '0 9 29 feb *', '2016-02-29 09:00', '2016-01-23' ], # gh-18 (mirror #prev)

    [ '59 6 1-7 * 2',
      '2020-03-17 06:59:00', # not '2020-04-07 06:59:00', tuesday 2 matches
      '2020-03-15 07:29:00' ],
    [ '59 6 1-7 * 2',
      '2020-02-11 06:59:00', # not '2020-03-03 06:59:00', tuesday 2 matches
      '2020-02-08 07:29:00' ],
    [ '59 6 1-7 * 2',
      '2020-03-01 06:59:00', # not '2020-03-03 06:59:00', monthday 1-7 matches
      '2020-02-29 07:29:00' ],

    #
    # gh-1 '0 9 * * sun%2' and '* * * * sun%2+1'
    #      every other Sunday

    [ '0 9 * * sat%2',
      '2019-01-12 09:00:00', '2019-01-01 09:00:00' ],
    [ '0 10 * * sun%2',
      '2019-04-21 10:00:00', '2019-04-11 09:00:00', 'Europe/Berlin' ],
    [ '0 10 * * sun%2+1',
      '2019-04-14 10:00:00', '2019-04-11 09:00:00', 'Europe/Berlin' ],

    # gh-52

    [ '59 23 * * 2', '2021-02-02 23:59:00', '2021-02-02 00:00:00' ],
    [ '59 23 * * 2', '2021-02-02 23:59:00', '2021-02-02 00:00:00', 'UTC' ],
    #[ '59 23 * * 2', '2021-02-02 23:59:00', '2021-02-02 00:00:00', 'utc' ],

    [ '59 18 * * 2#2', '2021-02-09 18:59:00', '2021-02-09 17:41:10' ],
    [ '59 18 * * 2#2', '2021-02-09 18:59:00', '2021-02-09 17:41:10', 'UTC' ],
    #[ '59 18 * * 2#1', '2021-02-09 18:59:00', '2021-02-09 17:41:10', 'utc' ],
  ]

  describe '#next_time' do

    NEXT_TIMES.each do |cron, next_time, now, zone_name|

      d = "succeeds #{cron.inspect} -> #{next_time.inspect}"
      d += " in #{zone_name}" if zone_name

      it(d) do

        in_zone(zone_name) do

          c = Fugit::Cron.parse(cron)

          expect(c.class).to eq(Fugit::Cron)

          ent = Time.parse(next_time)
          now = Time.parse(now) if now

          nt = c.next_time(now || NOW)

          expect(
            Fugit.time_to_plain_s(nt, false)
          ).to eq(
            Fugit.time_to_plain_s(ent, false)
          )

          expect(nt.zone.name).to eq(zone_name) if zone_name
        end
      end
    end

    context 'implicit tz DST transition' do

      [
        [ 'America/Los_Angeles', '* * * * *', '2015-03-08 09:59:00 UTC',
          '2015-03-08 03:00:00 PDT -0700' ],

      ].each do |tz, cron, from, target|

        it "correctly transit in or out of DST for #{tz.inspect}" do

          in_zone(tz) do

            c = Fugit::Cron.parse(cron)
            f = ::EtOrbi.make_time(from)
            nt = c.next_time(f).localtime

            expect(Fugit.time_to_zone_s(nt)).to eq(target)
          end
        end
      end

      it 'correctly increments every minute into DST' do

        in_zone 'America/Los_Angeles' do

          c = Fugit::Cron.parse('* * * * *')
          t = Time.parse('2015-03-08 01:57:00')

          points =
            4.times.collect do
              t = c.next_time(t)
              t.strftime("%H:%M_%Z") + '__' + t.dup.utc.strftime("%H:%M_%Z")
            end

          expect(points.join("\n")).to eq(%w[
            01:58_PST__09:58_UTC
            01:59_PST__09:59_UTC
            03:00_PDT__10:00_UTC
            03:01_PDT__10:01_UTC
          ].join("\n"))
        end
      end

      it 'correctly increments every minute into DST (explicit TZ)' do

        in_zone 'America/Los_Angeles' do

          c = Fugit::Cron.parse('* * * * * Europe/Berlin')
          t = EtOrbi::EoTime.parse('2015-03-08 01:57:00')

          points =
            4.times.collect do
              t = c.next_time(t)
              t.strftime('%H:%M_%Z') + '__' + t.dup.utc.strftime('%H:%M_%Z')
            end

          expect(points.join("\n")).to eq(%w[
            01:58_PST__09:58_UTC
            01:59_PST__09:59_UTC
            03:00_PDT__10:00_UTC
            03:01_PDT__10:01_UTC
          ].join("\n"))
        end
      end

      it 'correctly increments into DST (gh-53 a)' do

        in_zone 'Europe/Zurich' do

          c = Fugit::Nat.parse('every monday at midnight')
          t = EtOrbi::EoTime.parse('2021-03-14 12:00:00')

          points =
            4.times.collect do
              t = c.next_time(t)
              tu = t.dup.utc
              "#{t.strftime('%F_%H:%M_%Z')}__#{tu.strftime('%F_%H:%M_%Z')}"
            end

          expect(points.join("\n")).to eq(%w[
            2021-03-15_00:00_CET__2021-03-14_23:00_UTC
            2021-03-22_00:00_CET__2021-03-21_23:00_UTC
            2021-03-29_00:00_CEST__2021-03-28_22:00_UTC
            2021-04-05_00:00_CEST__2021-04-04_22:00_UTC
          ].join("\n"))
        end
      end

      it 'correctly increments into DST (gh-53 b)' do

        in_zone 'Europe/Zurich' do

          #c = Fugit::Nat.parse('every monday at midnight')
          c = Fugit::Cron.parse('0 0 * * 1')
          t = EtOrbi::EoTime.parse('2021-03-14 12:00:00')

          points =
            4.times.collect do
              t = c.next_time(t)
              tu = t.dup.utc
              "#{t.strftime('%F_%H:%M_%Z')}__#{tu.strftime('%F_%H:%M_%Z')}"
            end

          expect(points.join("\n")).to eq(%w[
            2021-03-15_00:00_CET__2021-03-14_23:00_UTC
            2021-03-22_00:00_CET__2021-03-21_23:00_UTC
            2021-03-29_00:00_CEST__2021-03-28_22:00_UTC
            2021-04-05_00:00_CEST__2021-04-04_22:00_UTC
          ].join("\n"))
        end
      end

      it 'correctly increments into DST (gh-53 c)' do

        in_zone 'Europe/Zurich' do

          #c = Fugit::Nat.parse('every monday at midnight')
          c = Fugit::Cron.parse('0 0 * * 2')
          t = EtOrbi::EoTime.parse('2021-03-14 12:00:00')

          points =
            4.times.collect do
              t = c.next_time(t)
              tu = t.dup.utc
              "#{t.strftime('%F_%H:%M_%Z')}__#{tu.strftime('%F_%H:%M_%Z')}"
            end

          expect(points.join("\n")).to eq(%w[
            2021-03-16_00:00_CET__2021-03-15_23:00_UTC
            2021-03-23_00:00_CET__2021-03-22_23:00_UTC
            2021-03-30_00:00_CEST__2021-03-29_22:00_UTC
            2021-04-06_00:00_CEST__2021-04-05_22:00_UTC
          ].join("\n"))
        end
      end

      it 'correctly increments into DST (gh-53 d)' do

        in_zone 'Europe/Zurich' do

          #c = Fugit::Nat.parse('every monday at midnight')
          #c = Fugit::Cron.parse('0 0 * * 2')
          c = Fugit::Nat.parse('every tuesday at 00:00')
          t = EtOrbi::EoTime.parse('2021-03-14 12:00:00')

          points =
            4.times.collect do
              t = c.next_time(t)
              tu = t.dup.utc
              "#{t.strftime('%F_%H:%M_%Z')}__#{tu.strftime('%F_%H:%M_%Z')}"
            end

          expect(points.join("\n")).to eq(%w[
            2021-03-16_00:00_CET__2021-03-15_23:00_UTC
            2021-03-23_00:00_CET__2021-03-22_23:00_UTC
            2021-03-30_00:00_CEST__2021-03-29_22:00_UTC
            2021-04-06_00:00_CEST__2021-04-05_22:00_UTC
          ].join("\n"))
        end
      end

      it 'correctly increments out of DST (gh-53 e)' do

        in_zone 'Europe/Zurich' do

          #c = Fugit::Nat.parse('every monday at midnight')
          c = Fugit::Cron.parse('0 0 * * 2')
          t = EtOrbi::EoTime.parse('2021-10-18 12:00:00')

          points =
            4.times.collect do
              t = c.next_time(t)
              tu = t.dup.utc
              "#{t.strftime('%F_%H:%M_%Z')}__#{tu.strftime('%F_%H:%M_%Z')}"
            end

          expect(points.join("\n")).to eq(%w[
            2021-10-19_00:00_CEST__2021-10-18_22:00_UTC
            2021-10-26_00:00_CEST__2021-10-25_22:00_UTC
            2021-11-02_00:00_CET__2021-11-01_23:00_UTC
            2021-11-09_00:00_CET__2021-11-08_23:00_UTC
          ].join("\n"))
        end
      end

      it 'correctly increments out of DST' do

        in_zone 'America/Los_Angeles' do

          c = Fugit::Cron.parse('15 * * * *')
          t = Time.parse('2015-11-01 00:14:00')

          points =
            5.times
              .collect {
                t = c.next_time(t)
                t.to_zs + ' // ' + t.to_t.to_s }
              .join("\n")

          expect(points).to eq(%{
            2015-11-01 00:15:00 America/Los_Angeles // 2015-11-01 00:15:00 -0700
            2015-11-01 01:15:00 America/Los_Angeles // 2015-11-01 01:15:00 -0700
            2015-11-01 02:15:00 America/Los_Angeles // 2015-11-01 02:15:00 -0800
            2015-11-01 03:15:00 America/Los_Angeles // 2015-11-01 03:15:00 -0800
            2015-11-01 04:15:00 America/Los_Angeles // 2015-11-01 04:15:00 -0800
          }.strip.split("\n").collect(&:strip).join("\n"))

          expect(
            c.brute_frequency(2015).occurrences
          ).to eq(8759)
        end
      end

      it 'correctly increments out of DST (America/New_York)' do

        in_zone 'America/New_York' do

          c = Fugit::Cron.parse('59 1 * * *')
          t = EtOrbi::EoTime.parse('2018-11-03 00:00:00')

          points =
            4.times
              .collect {
                t = c.next_time(t)
                t.to_zs + ' // ' + t.to_t.to_s }
              .join("\n")

          expect(points).to eq(%{
            2018-11-03 01:59:00 America/New_York // 2018-11-03 01:59:00 -0400
            2018-11-04 01:59:00 America/New_York // 2018-11-04 01:59:00 -0400
            2018-11-05 01:59:00 America/New_York // 2018-11-05 01:59:00 -0500
            2018-11-06 01:59:00 America/New_York // 2018-11-06 01:59:00 -0500
          }.strip.split("\n").collect(&:strip).join("\n"))

          expect(
            c.brute_frequency(2018).occurrences
          ).to eq(365)
        end
      end
    end

    it 'returns a plain second' do

      c = Fugit::Cron.parse('* * * * *')
      nt = c.next_time

      expect(nt.seconds.to_s).to eq(nt.seconds.to_i.to_s + '.0')
    end

    context 'explicit timezone' do

      it 'computes in the cron zone but returns in the from zone' do

        c = Fugit::Cron.parse('* * * * * Europe/Rome')
        f = EtOrbi.parse('2017-03-25 21:59 Asia/Tbilisi')
        t = c.next_time(f)

        expect(t.class).to eq(EtOrbi::EoTime)
        expect(t.iso8601).to eq('2017-03-25T22:00:00+04:00')
      end

      it 'returns the right result' do

        c = Fugit::Cron.parse('0 0 1 1 * Europe/Rome')
        f = EtOrbi.parse('2017-03-25 21:59 Asia/Tbilisi')
        t = c.next_time(f)

        expect(t.class)
          .to eq(EtOrbi::EoTime)
        expect(t.iso8601)
          .to eq('2018-01-01T03:00:00+04:00')
        expect(t.translate('Europe/Rome').iso8601)
          .to eq('2018-01-01T00:00:00+01:00')
      end
    end

    it 'breaks if its loop takes too long' do

      c = Fugit::Cron.parse('* * 1 * *')
      c.instance_eval { @monthdays = [ 0 ] }
        #
        # forge an invalid cron

      expect {
        c.next_time
      }.to raise_error(
        RuntimeError,
        "too many loops for \"* * 1 * *\" #next_time, breaking, " +
        "cron expression most likely invalid (Feb 30th like?), " +
        "please fill an issue at https://git.io/fjJC9"
      )
    end

    context '(defective et-orbi)' do

      before :each do
        class Fugit::Cron::TimeCursor
          alias inc _bad_inc
        end
      end
      after :each do
        class Fugit::Cron::TimeCursor
          alias inc _original_inc
        end
      end

      it 'breaks if its loop stalls' do

        c = Fugit::Cron.parse('* * 1 * *')

        expect {
          c.next_time
        }.to raise_error(
          RuntimeError,
          "too many loops for \"* * 1 * *\" #next_time, breaking, " +
          "cron expression most likely invalid (Feb 30th like?), " +
          "please fill an issue at https://git.io/fjJC9"
        )
      end
    end

    context '(Chronic and ActiveSupport, gh-11)' do

      before :each do

        require_chronic
      end

      after :each do

        unrequire_chronic
      end

      it "doesn't stall or loop ad infinitum" do

        in_active_support_zone('UTC') do

          cron = Fugit.do_parse_cron('0 0 1 1 *')

          expect {
            cron.next_time
          }.not_to raise_error
        end
      end
    end

    context 'New York skip (gh-43)' do

      it "doesn't skip" do

        cron = Fugit.parse('0 8-19/4 * * *')

        st = Time.parse('2020-09-11 12:00:00')

        nt = cron.next_time(st)
#p nt
#p nt.to_s
#p nt.to_local_time
#p nt.utc.to_s

        expect(nt.to_s).to match(/ 16:00:00 /)
      end

      it "doesn't skip (TZ UTC)" do

        in_zone('UTC') do

          cron = Fugit.parse('0 8-19/4 * * *')

          st = Time.parse('2020-09-11 12:00:00')

          nt = cron.next_time(st)
#p nt
#p nt.to_s
#p nt.to_local_time
#p nt.utc.to_s

          expect(nt.utc.to_s).to match(/ 16:00:00 /)
        end
      end

      it "doesn't skip (ActiveSupport TZ America/New_York)" do

        in_active_support_zone('America/New_York') do
#EtOrbi._make_info
#p EtOrbi.determine_local_tzone

          cron = Fugit.parse('0 8-19/4 * * *')

          st = Time.parse('2020-09-11 12:00:00 UTC')
#p st

          nt = cron.next_time(st)
#p nt
#p nt.to_s
#p nt.to_local_time
#p nt.utc.to_s

          expect(nt.utc.to_s).to match(/ 16:00:00 /)
        end
      end

      it 'does not break on "* * * * 1%2+2" (gh-47)' do

        cron0 = Fugit.parse('0 8 * * 1%2+2')
        cron1 = Fugit.parse('0 8 * * 1%2')

        expect(cron0.next_time('2021-04-21 07:00:00').to_s
          ).to match(/^2021-05-03 08:00:00 /)
        expect(cron0.next_time('2021-04-21 07:00:00').to_s
          ).to eq(cron1.next_time('2021-04-21 07:00:00').to_s)
      end
    end
  end

  describe '#match?' do

    NEXT_TIMES.each do |cron, next_time, _|

      it "succeeds #{cron.inspect} ? #{next_time.inspect}" do

        c = Fugit::Cron.parse(cron)
        ent = Time.parse(next_time)

        expect(c.match?(ent)).to be(true)
      end
    end

    context '"0 0 * * * Europe/Berlin" (gh-31)' do # in Changi

      before :each do

        @cron = Fugit::Cron.parse('0 0 * * * Europe/Berlin')
      end

      it "doesn't match midnight in London" do

        in_zone('Europe/London') do
          expect(@cron.match?(Time.new(2019, 1, 1))
            ).to eq(false)
        end
      end

      it "matches midnight in Berlin" do

        in_zone('Europe/London') do
          expect(@cron.match?(Fugit.parse('2019-1-1 00:00:00 Europe/Berlin'))
            ).to eq(true)
        end
      end
    end
  end

  PREVIOUS_TIMES = [

    [ '5 0 * * *', '2016-12-31 00:05:00', '2017-01-01' ],
    [ '5 0 * * *', '2017-01-13 00:05:00', '2017-01-14' ],

    [ '0 0 1 1 *', '2017-01-01 00:00:00', '2017-03-15' ],
    [ '0 12 1 1 *', '2016-01-01 12:00:00', '2017-01-01' ],

    [ '* * 29 * *', '2017-01-29 23:59:00', '2017-03-15' ],
    [ '* * 29 * *', '2016-02-29 23:59:00', '2016-03-15' ],
    [ '* * L * *', '2017-02-28 23:59:00', '2017-03-15' ],
    [ '* * L * *', '2016-02-29 23:59:00', '2016-03-15' ],
    [ '* * last * *', '2016-02-29 23:59:00', '2016-03-15' ],
    [ '* * -1 * *', '2016-02-29 23:59:00', '2016-03-15' ],
    [ '0 0 -4,-3 * *', '2017-02-26 00:00:00', '2017-03-15' ],
    [ '0 0 -4,-3 * *', '2017-02-25 00:00:00', '2017-02-25 23:00' ],
    [ '* * * * sun', '2017-01-29 23:59:00', '2017-01-31' ],
    [ '* * * * mon#2', '2017-01-09 23:59:00', '2017-01-31' ],
    [ '* * * * mon#-1', '2017-01-30 23:59:00', '2017-01-31' ],
    [ '* * * * wed#L', '2017-01-25 23:59:00', '2017-01-31' ],
    [ '* * * * wed#last', '2017-01-25 23:59:00', '2017-01-31' ],
    [ '* * * * mon#2,tue', '2017-01-24 23:59:00', '2017-01-30' ],
    [ '* * * * mon#2,wed', '2017-01-09 23:59:00', '2017-01-10' ],
    [ '30 04 1,15 * 5', '2017-01-15 04:30:00', '2017-01-16' ],
    [ '30 04 1,15 * 5', '2017-01-13 04:30:00', '2017-01-15' ],

    [ '00 24 * * *', '2017-01-02', '2017-01-02 12:00' ],

    [ '0 0 * * mon#2,tue', '2017-01-09', '2017-01-09 12:00' ],
    [ '0 0 * * mon#2,tue', '2017-01-03', '2017-01-04' ],

    [ '0 20 31 oct *', '2019-10-31 20:00', '2019-11-01' ], # gh-51
    [ '0 9 29 feb *', '2016-02-29 09:00', '2019-03-23' ], # gh-18

    [ '59 6 1-7 * 2', '2020-03-10 06:59:00', '2020-03-15 07:47' ],
      # not '2020-03-03 06:59:00', tuesday 2 matches
    [ '59 6 1-7 * 2', '2020-03-03 06:59:00', '2020-03-04 06:00' ],
      # yes, either tuesday 2 and monthday 1-7 match
    [ '59 6 1-7 * 2', '2020-02-25 06:59:00', '2020-03-01 06:00' ],
      # not '2020-02-04 06:59:00', tuesday 2 matches
      #
      # gh-35
      #
      # From `man 5 crontab`
      #
      # Note: The day of a command's execution can be specified
      # by two fields -- day of month, and day of week.
      # If both fields are restricted (ie, are not *), the command will be
      # run when either field matches the current time.
      # For example, ``30 4 1,15 * 5'' would cause a command to be run
      # at 4:30 am on the 1st and 15th of each month, plus every Friday.
  ]

  describe '#previous_time' do

    PREVIOUS_TIMES.each do |cron, previous_time, now|

      now = now ? Time.parse(now) : NOW

      it "succeeds #{cron.inspect} #{now} -> #{previous_time.inspect}" do

        c = Fugit::Cron.parse(cron)
        ept = Time.parse(previous_time)

        pt = c.previous_time(now)

        expect(
          Fugit.time_to_plain_s(pt, false)
        ).to eq(
          Fugit.time_to_plain_s(ept, false)
        )

        expect(c.match?(ept)).to eq(true) # quick check
      end
    end

    it 'breaks if its loop takes too long' do

      c = Fugit::Cron.parse('* * 1 * *')
      c.instance_eval { @monthdays = [ 0 ] }
        #
        # forge an invalid cron

      expect {
        c.previous_time
      }.to raise_error(
        RuntimeError,
        "too many loops for \"* * 1 * *\" #previous_time, breaking, " +
        "cron expression most likely invalid (Feb 30th like?), " +
        "please fill an issue at https://git.io/fjJCQ"
      )
    end

    it 'does not go into an endless loop over time == previous_time (gh-15)' do

      c = Fugit.parse('10 * * * * *')
      t = c.previous_time.to_f# + 0.123 #(some float x so that 0.0 <= x < 1.0)

      expect(
        c.previous_time(Time.at(t)).to_i
      ).to eq(
        t.to_i - 60
      )
    end

    context '(defective et-orbi)' do

      before :each do
        class Fugit::Cron::TimeCursor
          alias inc _bad_inc
        end
      end
      after :each do
        class Fugit::Cron::TimeCursor
          alias inc _original_inc
        end
      end

      it 'breaks if its loop stalls' do

        c = Fugit::Cron.parse('* * 1 * *')

        expect {
          c.previous_time
        }.to raise_error(
          RuntimeError,
          "too many loops for \"* * 1 * *\" #previous_time, breaking, " +
          "cron expression most likely invalid (Feb 30th like?), " +
          "please fill an issue at https://git.io/fjJCQ"
        )
      end
    end
  end

  describe '#brute_frequency' do

    [
      [ '* * * * *',
        'dmin: 1m, dmax: 1m, ocs: 525600, spn: 52W1D, spnys: 1, yocs: 525600' ],
      [ '0 0 * * *',
        'dmin: 1D, dmax: 1D, ocs: 365, spn: 52W1D, spnys: 1, yocs: 365' ],
      [ '0 0 * * sun',
        'dmin: 1W, dmax: 1W, ocs: 53, spn: 53W, spnys: 1, yocs: 52' ],
      [ '0 0 1 1 *',
        'dmin: 52W1D, dmax: 52W1D, ocs: 1, spn: 52W1D, spnys: 1, yocs: 1' ],
      [ '0 0 29 2 *',
        'dmin: 208W5D, dmax: 208W5D, ocs: 1, spn: 208W5D, spnys: 4, yocs: 0' ]
    ].each do |cron, freq|

      it "computes #{freq.inspect} for #{cron.inspect}" do

        f = Fugit::Cron.parse(cron).brute_frequency.to_debug_s

        expect(f).to eq(freq)
      end
    end

    it 'accepts a year argument' do

      expect(
        Fugit::Cron.parse('0 0 * * sun').brute_frequency(2016).to_debug_s
      ).to eq(
        'dmin: 1W, dmax: 1W, ocs: 52, spn: 52W, spnys: 0, yocs: 52'
      )
    end
  end

  describe '#rough_frequency' do

    # (seconds               0-59)
      # minute               0-59
        # hour               0-23
          # day of month     1-31
            # month          1-12 (or names, see below)
              # day of week  0-7 (0 or 7 is Sun, or use names)
    {

      '* * * * *' => '1m',
      '* * * * * *' => 1,
      '0 0 * * *' => '1d',
      '10,15 0 * * *' => '5m',
      '0 0 * * sun' => '7d',
      '0 0 1 1 *' => '1Y',
      '0 0 29 2 *' => '1Y', # ! rough frequency !
      '0 0 28 2,3 *' => '1M',
      '0 0 28 2,4 *' => '2M',
      '*/15 * * * * *' => 15,
      '*/15 * * * *' => '15m',

      '5 0 * * *' => '1d',
      '15 14 1 * *' => '1M',
      '* * 29 * *' => '1m',
      '* * L * *' => '1m',
      '* * last * *' => '1m',
      '* * -1 * *' => '1m',
      '0 0 -4,-3 * *' => '1d',
      '* * * * sun' => '1m',
      '* * -2 * *' => '1m',
      '* * * * mon' => '1m',
      '* * * * * mon' => 1,
      '* * * * mon,tue' => '1m',
      '* * * * mon#2' => '1m',
      '* * * * mon#-1' => '1m',
      '* * * * tue#L' => '1m',
      '* * * * tue#last' => '1m',
      '* * * * mon#2,tue' => '1m',
      '0 0 * * mon' => '1W',
      '0 0 * * mon,tue' => '1d',
      '0 0 * * mon#2' => '1M',
      '0 0 * * mon#-1' => '1M',
      '0 0 * * tue#L' => '1M',
      '0 0 * * tue#last' => '1M',
      '0 0 * * mon#2,tue' => '1d',
      '00 24 * * *' => '1d',
      '30 04 1,15 * 5' => '3d', # rough
      '0 8 L * mon-thu' => '1d', # last day of month OR monday to thursday
      '0 9 -2 * *' => '1M',
      '0 0 -5 * *' => '1M',
      '0 8 L * *' => '1M',

      '0 0 */2 * *' => '2d',
      '0 0 */2 * * Europe/Berlin' => '2d',
      '0 0 */3 * *' => '3d',
      '0 0 * * */2' => '1d',

    }.each do |cron, freq|

      it "gets #{cron.inspect} and outputs #{freq.inspect}" do

        f = freq.is_a?(String) ? Fugit.parse(freq).to_sec : freq
        rf = Fugit::Cron.parse(cron).rough_frequency

#p Fugit::Duration.parse(rf).deflate.to_plain_s
        expect(rf).to eq(f)
      end
    end
  end

  describe '.parse' do

    it "returns the input immediately if it's a cron" do

      c = Fugit.parse('* * * * *'); expect(c.class).to eq(Fugit::Cron)

      c1 = Fugit::Cron.parse(c)

      expect(c1.class).to eq(Fugit::Cron)
      expect(c1.object_id).to eq(c.object_id)
    end

    it 'returns nil if it cannot parse' do

      expect(Fugit::Cron.parse(true)).to eq(nil)
      expect(Fugit::Cron.parse('nada')).to eq(nil)
    end

    it 'parses @reboot'

    context 'success' do

      [

        [ '@yearly', '0 0 1 1 *' ],
        [ '@annually', '0 0 1 1 *' ],
        [ '@monthly', '0 0 1 * *' ],
        [ '@weekly', '0 0 * * 0' ],
        [ '@daily', '0 0 * * *' ],
        [ '@midnight', '0 0 * * *' ],
        [ '@noon', '0 12 * * *' ],
        [ '@hourly', '0 * * * *' ],

        # min hou dom mon dow

        [ '5 0 * * *', '5 0 * * *' ],
          # 5 minutes after midnight, every day
        [ '15 14 1 * *', '15 14 1 * *' ],
          # at 1415 on the 1st of every month
        [ '0 22 * * 1-5', '0 22 * * 1,2,3,4,5' ],
          # at 2200 on weekdays
        [ '0 22 * * 0', '0 22 * * 0' ],
        [ '0 22 * * 7', '0 22 * * 0' ],
          # at 2200 on sunday
        [ '0 23 * * 7-1', '0 23 * * 0,1' ],
          # at 2300 sunday to monday
        [ '0 23 * * 6-1', '0 23 * * 0,1,6' ],
          # at 2300 saturday to monday
        [ '23 0-23/2 * * *', '23 0,2,4,6,8,10,12,14,16,18,20,22 * * *' ],
          # 23 minutes after midnight, 0200, 0400, ...
        #[ '5 4 * * sun', :xxx ],
          # 0405 every sunday

        [ '14,24 8-12,14-19/2 * * *', '14,24 8,9,10,11,12,14,16,18 * * *' ],
        [ '24,14 14-19/2,8-12 * * *', '14,24 8,9,10,11,12,14,16,18 * * *' ],

        [ '*/1 1-3/1 * * *', '* 1,2,3 * * *' ],

        [ '0 22 * * 5-1', '0 22 * * 0,1,5,6' ],

        [ '0 9-17/2 * * *', '0 9,11,13,15,17 * * *' ],
        [ '0 */2 * * *', '0 0,2,4,6,8,10,12,14,16,18,20,22 * * *' ],

        [ '0 0 * * */2', '0 0 * * 0,2,4,6' ],
        [ '0 0 * * 1-5/2', '0 0 * * 1,3,5' ],
        [ '0 0 * * 3/2', '0 0 * * 3' ],

        [ '* * 1 * *', '* * 1 * *' ],  # gh-10, double-check that 01 is a dom
        [ '* * 01 * *', '* * 1 * *' ], #
        [ '* * * 1 *', '* * * 1 *' ],  # and that 01 is a month
        [ '* * * 01 *', '* * * 1 *' ], #

        [ '*/15 * * * *', '0,15,30,45 * * * *' ],               # gh-19
        [ '/15 * * * *', '0,15,30,45 * * * *' ],                #
        [ '/15 * * * * *', '0,15,30,45 * * * * *' ],            #
        [ '/15 /4 * * *', '0,15,30,45 0,4,8,12,16,20 * * *' ],  #

        [ '0 18 * * fri-sun UTC', '0 18 * * 0,5,6 UTC' ], # gh-27

        [ '0 19 * 7-8 0', '0 19 * 7,8 0' ],
        [ '0 19 * nov-dec 0', '0 19 * 11,12 0' ],
        [ '0 19 * 11-2 0', '0 19 * 1,2,11,12 0' ],
        [ '0 19 * nov-mar 0', '0 19 * 1,2,3,11,12 0' ], # gh-27 on month

        [ '10-15 7 * * *', '10,11,12,13,14,15 7 * * *' ],
        [ '55-5 7 * * *', '0,1,2,3,4,5,55,56,57,58,59 7 * * *' ],
        [ '10 18-20 * * *', '10 18,19,20 * * *' ],
        [ '10 23-04 * * *', '10 0,1,2,3,4,23 * * *' ],
        [ '0 23 10-15 * *', '0 23 10,11,12,13,14,15 * *' ],
        [ '0 23 30-3 * *', '0 23 1,2,3,30,31 * *' ],
        [ '0 23 1 10-12 *', '0 23 1 10,11,12 *' ],
        [ '0 23 1 11-2 *', '0 23 1 1,2,11,12 *' ],
        [ '0 23 * * fri-sun', '0 23 * * 0,5,6' ],
        [ '0 23 * * 5-0', '0 23 * * 0,5,6' ],
        [ '0 23 * * sat-mon', '0 23 * * 0,1,6' ],
        [ '0 23 * * 6-1', '0 23 * * 0,1,6' ],
        [ '10-15 0 23 * * *', '10,11,12,13,14,15 0 23 * * *' ],
        [ '58-2 0 23 * * *', '0,1,2,58,59 0 23 * * *' ],

        [ '* 0-24 * * *', "* #{(0..23).to_a.collect(&:to_s).join(',')} * * *" ],
        [ '* 22-24 * * *', '* 0,22,23 * * *' ],
        [ '* * * 1-13 *', nil ], # month 13 isn't allowed at parsing
          #
          # gh-30

        [ '59 6 1-7 * 2', '59 6 1,2,3,4,5,6,7 * 2' ],
          #
          # gh-35

        [ '0 8-19/4 * * *', '0 8,12,16 * * *' ],
          #
          # gh-43

      ].each { |c, e|

        it "parses #{c}" do

          c = Fugit::Cron.parse(c)
          expect(c ? c.to_cron_s : c).to eq(e)
        end
      }

      context 'negative monthdays' do

        [
          [ '* * -1 * *', '* * -1 * *' ],
          [ '* * -7--1 * *', '* * -7,-6,-5,-4,-3,-2,-1 * *' ],
          [ '* * -1--27 * *', '* * -31,-30,-29,-28,-27,-1 * *' ],
          [ '* * -7--1/2 * *', '* * -7,-5,-3,-1 * *' ],
          [ '* * L * *', '* * -1 * *' ],
          [ '* * -7-L * *', '* * -7,-6,-5,-4,-3,-2,-1 * *' ],
          [ '* * last * *', '* * -1 * *' ],

          [ '* * 25-l * *', "* * #{(25..31).to_a.map(&:to_s).join(',')} * *" ],
          [ '* * 25-L * *', "* * #{(25..31).to_a.map(&:to_s).join(',')} * *" ],
            # not so negative...

        ].each { |c, e|
          it("parses #{c}") { expect(Fugit::Cron.parse(c).to_cron_s).to eq(e) }
        }
      end

      context 'months' do

        [
          [ '* * * jan-mar *', '* * * 1,2,3 *' ],
          [ '* * * Jan-Aug/2 *', '* * * 1,3,5,7 *' ],
        ].each { |c, e|
          it("parses #{c}") { expect(Fugit::Cron.parse(c).to_cron_s).to eq(e) }
        }
      end

      context 'weekdays' do

        [
          [ '* * * * sun,mon', '* * * * 0,1' ],
          [ '* * * * Sun,mOn', '* * * * 0,1' ],
          [ '* * * * mon-wed', '* * * * 1,2,3' ],
          [ '* * * * sun,2-4', '* * * * 0,2,3,4' ],
          [ '* * * * sun,mon-tue', '* * * * 0,1,2' ],
          [ '* * * * sun,Sun,0,7', '* * * * 0' ],
#a_e  q '0 0 * * mon#1,tue', [[0], [0], [0], nil, nil, [2], ["1#1"]]
        ].each { |c, e|
          it("parses #{c}") { expect(Fugit::Cron.parse(c).to_cron_s).to eq(e) }
        }
      end

      context 'weekdays #' do

        [
          [ '0 0 * * mon#1,tue', '0 0 * * 1#1,2' ],
          [ '0 0 * * mon#-1,tue', '0 0 * * 1#-1,2' ],
          [ '0 0 * * mon#L,tue', '0 0 * * 1#-1,2' ],
          [ '0 0 * * mon#last,tue', '0 0 * * 1#-1,2' ],
        ].each { |c, e|
          it("parses #{c}") { expect(Fugit::Cron.parse(c).to_cron_s).to eq(e) }
        }
      end

      context 'timezone' do

        (
          ::TZInfo::Timezone.all.collect { |tz|
            [ "* * * * * #{tz.name}", tz.name ]
          } +
          [
            [ '* * * * * +09:00', '+09:00' ],
            [ '* * * * * +0900', '+0900' ],
          ]
        ).each do |c, z|

          it "parses #{c}" do

            c = Fugit::Cron.parse(c)
            tz = EtOrbi.get_tzone(z) || fail("unknown tz #{z.inspect}")

            expect(c.class).to eq(Fugit::Cron)
            expect(c.zone).to eq(z)
            expect(c.timezone).to eq(tz)
          end
        end

        [
          '* * * * * America/SaoPaulo',
          '* * * * * America/Los Angeles',
          '* * * * * Issy_Les_Moulineaux',
        ].each { |c|

          it "returns nil for #{c.inspect}" do

            expect(Fugit::Cron.parse(c)).to eq(nil)
          end
        }
      end
    end

    context 'failure' do

      [
        # min hou dom mon dow

        nil,
        '',
        ' ',

        '* 25 * * *',
        '* * -32 * *',

        '* * 0 * *',   # gh-10, 0 is not a valid day of month
        '* * 00 * *',  #
        '* * * 0 *',   # and 0 is not a valid month
        '* * * 00 *',  #

      ].each do |cron|

        it "returns nil for #{cron}" do

          expect(Fugit::Cron.parse(cron)).to eq(nil)
        end
      end
    end

    context 'impossible days' do

      {
        '* * 32 1 *' => nil,

        '* * 30 2 *' => nil,
        '* * 30,31 2 *' => nil,
        '* * 31 4 *' => nil,
        '* * 31 6 *' => nil,
        '* * 31 9 *' => nil,
        '* * 31 11 *' => nil,
        '* * 31 2,4 *' => nil,

        '* * 30,31 2,3 *' => [ [ 3 ], [ 30, 31 ] ],
          # not how February gets dropped
        '* * 30,31 4 *' => [ [ 4 ], [ 30 ] ],
          # not how the 31st gets dropped
        '* * 30,31 3,4 *' => [ [ 3, 4 ], [ 30, 31 ] ],
        '* * 31 3,4 *' => [ [ 3 ], [ 31 ] ],

      }.each do |cron, modays|

        if modays

          it "parses #{cron.inspect} months/monthdays to #{modays.inspect}" do

            c = Fugit::Cron.parse(cron)

            expect([ c.months, c.monthdays ]).to eq(modays)
          end

        else

          it "returns nil for #{cron.inspect}" do

            expect(Fugit::Cron.parse(cron)).to eq(nil)
          end
        end
      end
    end

    context 'weekdays' do

      {
        '* * * * sun#L' => [ [ 0, -1 ] ],
        '* * * * sun%2' => [ [ 0, [ 2, 0 ] ] ],
        '* * * * sun%2+1' => [ [ 0, [ 2, 1 ] ] ],

      }.each do |cron, weekdays|

        it "parses #{cron.inspect} weekdays to #{weekdays.inspect}" do

          c = Fugit::Cron.parse(cron)

          expect(c.weekdays).to eq(weekdays)
        end
      end
    end
  end

  describe '.do_parse' do

    [
      # min hou dom mon dow

      '* 25 * * *',
      '* * -32 * *',

      '* * 0 * *',   # gh-10, 0 is not a valid day of month
      '* * 00 * *',  #
      '* * * 0 *',   # and 0 is not a valid month
      '* * * 00 *',  #

    ].each do |cron|

      it "raises for #{cron}" do
        expect {
          Fugit::Cron.do_parse(cron)
        }.to raise_error(
          ArgumentError, "invalid cron string #{cron.inspect}"
        )
      end
    end
  end

  describe '#==' do

    it 'returns true when equal' do

      expect(
        Fugit::Cron.parse('* * * * *') ==
        Fugit::Cron.parse('* * * * *')
      ).to eq(true)

      expect(
        Fugit::Cron.parse('* * * * *') ==
        Fugit::Cron.parse('* * */1 * *')
      ).to eq(true)
    end

    it 'returns false else' do

      expect(
        Fugit::Cron.parse('* * * * *') ==
        Fugit::Cron.parse('* * * * 1')
      ).to eq(false)

      expect(
        Fugit::Cron.parse('* * * * *') !=
        Fugit::Cron.parse('* * * * 1')
      ).to eq(true)

      expect(Fugit::Cron.parse('* * * * *') == 1).to eq(false)
    end
  end

  describe '#to_cron_s' do

    [

      [ '0 */3 * * 1,2', '0 0,3,6,9,12,15,18,21 * * 1,2' ],
      [ '0 5 * * 1,2,3,4,5', '0 5 * * 1,2,3,4,5' ],
      [ '0 5 * * 1-4,fri#3', '0 5 * * 1,2,3,4,5#3' ],
      [ '* * * * * America/Los_Angeles', '* * * * * America/Los_Angeles' ],
      #[ '0 */3 * * 1,2', '0 */3 * * 1-2' ],
      #[ '0 5 * * 1,2,3,4,5', '0 5 * * 1-5' ],
      #[ '0 5 * * 1,2,3,4,fri#3', '0 5 * * 1-4,5#3' ],

    ].each do |source, target|

      it "represents #{source.inspect} into #{target.inspect}" do

        sc = Fugit::Cron.parse(source)
        tc = Fugit::Cron.parse(target)

        expect(sc).to eq(tc)
        expect(sc.to_cron_s).to eq(target)
      end
    end

    it "produces the same cron if parsing again the to_cron_s" do

      c1 = Fugit::Cron.parse('* * * * * America/Los_Angeles')
      c2 = Fugit::Cron.parse(c1.to_cron_s)

      expect(c1).to eq(c2)
    end
  end

  describe '#seconds' do

    {

      '* * * * *' => [ 0 ],
      '5 * * * * *' => [ 5 ],
      '5,10 * * * * *' => [ 5, 10 ],
      '*/10 * * * * *' => [ 0, 10, 20, 30, 40, 50 ],

    }.each do |string, expected|

      it "returns #{expected.inspect} for #{string}" do

        expect(Fugit::Cron.parse(string).seconds).to eq(expected)
      end
    end
  end

  describe '#range (protected)' do

    {

      { min: 1, max: 12, sta: 2, edn: 4, sla: 1 } => [ 2, 3, 4 ],
      { min: 1, max: 12, sta: 2, edn: 4, sla: 2 } => [ 2, 4 ],
      { min: 1, max: 12, sta: 11, edn: 2, sla: 1 } => [ 11, 12, 1, 2 ],
      { min: 1, max: 12, sta: 11, edn: 2, sla: 2 } => [ 11, 1 ],
      { min: 1, max: 31, sta: -5, edn: -1, sla: 1 } => [ -5, -4, -3, -2, -1 ],
      { min: 1, max: 31, sta: -1, edn: -29, sla: 1 } => [ -1, -31, -30, -29 ],

      { min: 0, max: 23, sta: 0, edn: 24, sla: 1 } => (0..23).to_a,
      #{ min: 1, max: 12, sta: 0, edn: 12, sla: 1 } => ...
      #{ min: 1, max: 12, sta: 1, edn: 13, sla: 1 } => ... # month 13 no parse
        #
        # gh-30

    }.each do |args, result|

      it "returns #{result.inspect} for #{args.inspect}" do

        as = [ :min, :max, :sta, :edn, :sla ].collect { |k| args[k] }

        expect(Fugit::Cron.allocate.send(:range, *as)).to eq(result)
      end
    end
  end
end

describe Fugit::Cron do

  context 'sec6' do

    [

      [ '* 5 0 * * *', '* 5 0 * * *' ],

    ].each do |s0, s1|

      it "parses #{s0.inspect} and renders it as #{s1.inspect}" do

        c = Fugit::Cron.parse(s0)

        expect(c.to_cron_s).to eq(s1)
      end
    end

    [

      [ '0 5 0 * * *', [ [ 0 ], [ 5 ], [ 0 ], nil, nil, nil ] ],
      [ '5 0 * * *', [ [ 0 ], [ 5 ], [ 0 ], nil, nil, nil ] ],

      [ '* 5 0 * * *', [ nil, [ 5 ], [ 0 ], nil, nil, nil ] ],

    ].each do |s, a|

      it "parses #{s.inspect} and stores it as #{a.inspect}" do

        c = Fugit::Cron.parse(s)

        expect(c.to_a).to eq(a)
      end
    end

    [
      # c: cron, f: from, nt: next_time, pt: previous_time

      { c: '15 5 0 * * *', f: '2017-01-01', nt: '2017-01-01 00:05:15' },
      { c: '15 5 0 * * *', f: '2017-01-01', pt: '2016-12-31 00:05:15' },

      { c: '15,30 5 0 * * *', f: '2017-01-01', nt: '2017-01-01 00:05:15' },
      { c: '15,30 5 0 * * *', f: '2017-01-01 00:05:15', nt: '2017-01-01 00:05:30' },
      { c: '15,30 5 0 * * *', f: '2017-01-01 00:05:31', nt: '2017-01-02 00:05:15' },

      { c: '15,30 5 0 * * *', f: '2017-01-01', pt: '2016-12-31 00:05:30' },
      { c: '15,30 5 0 * * *', f: '2017-01-01 00:05:30', pt: '2017-01-01 00:05:15' },

    ].each do |h|

      cron = h[:c]
      from = Time.parse(h[:f]) || Time.now
      nt = h[:nt]
      pt = h[:pt]

      it "computes the #{nt ? 'next' : 'previous'} time correctly for #{cron.inspect}" do

        c = Fugit::Cron.parse(cron)

        if nt
          expect(Fugit.time_to_plain_s(c.next_time(from), false)).to eq(nt)
        else
          expect(Fugit.time_to_plain_s(c.previous_time(from), false)).to eq(pt)
        end
      end
    end
  end
end

