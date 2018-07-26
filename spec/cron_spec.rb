
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

    [ '00 24 * * *', '2017-01-02', '2017-01-01 12:00' ],

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
  ]

  describe '#next_time' do

    NEXT_TIMES.each do |cron, next_time, now, zone_name|

      it "succeeds #{cron.inspect} -> #{next_time.inspect}" do

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
        f = EtOrbi.parse('2017-03-25 21:59 Asia/Tokyo')
        t = c.next_time(f)

        expect(t.class).to eq(EtOrbi::EoTime)
        expect(t.iso8601).to eq('2017-03-25T22:00:00+09:00')
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

      '* * * * *' => 60,
      '* * * * * *' => 1,
      '0 0 * * *' => 24 * 3600,
      '10,15 0 * * *' => 5 * 60,
      '0 0 * * sun' => 7 * 24 * 3600,
      '0 0 1 1 *' => 365 * 24 * 3600,
      '0 0 29 2 *' => 365 * 24 * 3600, # ! rough frequency !
      '0 0 28 2,3 *' => 30 * 24 * 3600,
      '0 0 28 2,4 *' => 2 * 30 * 24 * 3600,

    }.each do |cron, freq|

      it "gets #{cron.inspect} and outputs #{freq.inspect}" do

        expect(
          Fugit::Cron.parse(cron)
            .rough_frequency
        ).to eq(
          freq
        )
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
        [ '@hourly', '0 * * * *' ],

        [ '5 0 * * *', '5 0 * * *' ],
          # 5 minutes after midnight, every day
        [ '15 14 1 * *', '15 14 1 * *' ],
          # at 1415 on the 1st of every month
        [ '0 22 * * 1-5', '0 22 * * 1,2,3,4,5' ],
          # at 2200 on weekdays
        [ '23 0-23/2 * * *', '23 0,2,4,6,8,10,12,14,16,18,20,22 * * *' ],
          # 23 minutes after midnight, 0200, 0400, ...
        #[ '5 4 * * sun', :xxx ],
          # 0405 every sunday

        [ '14,24 8-12,14-19/2 * * *', '14,24 8,9,10,11,12,14,16,18 * * *' ],
        [ '24,14 14-19/2,8-12 * * *', '14,24 8,9,10,11,12,14,16,18 * * *' ],

        [ '*/1 1-3/1 * * *', '* 1,2,3 * * *' ],

        [ '0 22 * * 5-1', '0 22 * * 1,2,3,4,5' ],

        [ '0 9-17/2 * * *', '0 9,11,13,15,17 * * *' ],
        [ '0 */2 * * *', '0 0,2,4,6,8,10,12,14,16,18,20,22 * * *' ],

        [ '0 0 * * */2', '0 0 * * 0,2,4,6' ],
        [ '0 0 * * 1-5/2', '0 0 * * 1,3,5' ],
        [ '0 0 * * 3/2', '0 0 * * 3' ],

      ].each { |c, e|
        it("parses #{c}") { expect(Fugit::Cron.parse(c).to_cron_s).to eq(e) }
      }

      context 'negative monthdays' do

        [
          [ '* * -1 * *', '* * -1 * *' ],
          [ '* * -7--1 * *', '* * -7,-6,-5,-4,-3,-2,-1 * *' ],
          [ '* * -1--7 * *', '* * -7,-6,-5,-4,-3,-2,-1 * *' ],
          [ '* * -7--1/2 * *', '* * -7,-5,-3,-1 * *' ],
          [ '* * L * *', '* * -1 * *' ],
          [ '* * -7-L * *', '* * -7,-6,-5,-4,-3,-2,-1 * *' ],
          [ '* * last * *', '* * -1 * *' ],
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

        [
          [ '* * * * * America/Los_Angeles', 'America/Los_Angeles' ],
          [ '* * * * * +09:00', '+09:00' ],
        ].each { |c, z|

          it "parses #{c}" do

            c = Fugit::Cron.parse(c)
            tz = EtOrbi.get_tzone(z) || fail("unknown tz #{z.inspect}")

            expect(c.class).to eq(Fugit::Cron)
            expect(c.zone).to eq(z)
            expect(c.timezone).to eq(tz)
          end
        }

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
        '* 25 * * *',
        '* * -32 * *'
      ].each do |cron|

        it "returns nil for #{cron}" do

          expect(Fugit::Cron.parse(cron)).to eq(nil)
        end
      end
    end
  end

  describe '.do_parse' do

    [
      '* 25 * * *',
      '* * -32 * *'
    ].each do |cron|

      it "raises for #{cron}" do
        expect {
          Fugit::Cron.do_parse(cron)
        }.to raise_error(
          ArgumentError, "not a cron string #{cron.inspect}"
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

