
#
# Specifying fugit
#
# Tue Jan  3 11:31:29 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Duration do

  describe '.parse' do

    it 'returns nil when it cannot parse' do

      expect(Fugit::Duration.parse('NADA')).to eq(nil)
    end

    it 'accepts a Numeric' do

      expect(Fugit::Duration.parse(0).to_plain_s).to eq('0s')
      expect(Fugit::Duration.parse(1000).to_plain_s).to eq('1000s')
      expect(Fugit::Duration.parse(1001.05).to_plain_s).to eq('1001.05s')

      expect(Fugit::Duration.parse(0).to_iso_s).to eq('PT0S')
      expect(Fugit::Duration.parse(1000).to_iso_s).to eq('PT1000S')
      expect(Fugit::Duration.parse(1001.05).to_iso_s).to eq('PT1001.05S')
    end

    it "returns the input immediately if it's a duration" do

      d = Fugit::Duration.parse('1s'); expect(d.class).to eq(Fugit::Duration)

      d1 = Fugit::Duration.parse(d)

      expect(d1.class).to eq(Fugit::Duration)
      expect(d1.object_id).to eq(d.object_id)
    end

    it 'returns nil if it cannot parse' do

      expect(Fugit::Duration.parse(true)).to eq(nil)
      expect(Fugit::Duration.parse('nada')).to eq(nil)
    end

    DAY_S = 24 * 3600

    [

      [ '1y2M', '1y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ '1M1y1M', '1y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ '10d10h', '10d10h', 'P10DT10H', 10 * DAY_S + 10 * 3600 ],
      [ '100s', '100s', 'PT100S', 100 ],

      [ '-1y-2M', '-1y2M', 'P-1Y-2M', - 365 * DAY_S - 60 * DAY_S ],
      [ '1M-1y-1M', '-1y', 'P-1Y', - 365 * DAY_S ],

      [ '-1y+2M', '-1y+2M', 'P-1Y2M', - 365 * DAY_S + 60 * DAY_S ],
      [ '1M+1y-1M', '1y', 'P1Y', 365 * DAY_S ],

      [ '1y 2M', '1y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ '1M 1y  1M', '1y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ ' 1M1y1M ', '1y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],

      [ '1 year and 2 months', '1y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ '1 y, 2 M, and 2 months', '1y4M', 'P1Y4M', 41904000 ],
      [ '1 y, 2 M and 2 m', '1y2M2m', 'P1Y2MT2M', 36720120 ],

      [ 'P1Y2M', '1y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ 'P1Y2M', '1y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ 'P10DT10H', '10d10h', 'P10DT10H', 10 * DAY_S + 10 * 3600 ],
      [ 'PT100S', '100s', 'PT100S', 100 ],

      [ 'P-1Y-2M', '-1y2M', 'P-1Y-2M', - 365 * DAY_S - 60 * DAY_S ],
      [ 'p1M-1y-1Mt-1M', '-1y1m', 'P-1YT-1M', -31536060 ],

      [ '1.4s', '1.4s', 'PT1.4S', 1.4 ],
      [ 'PT1.5S', '1.5s', 'PT1.5S', 1.5 ],
      [ '.4s', '0.4s', 'PT0.4S', 0.4 ],
      [ 'PT.5S', '0.5s', 'PT0.5S', 0.5 ],

      [ '1.0d1.0w1.0d', '1.0w2.0d', 'P1.0W2.0D', 777_600.0 ],

      [ '-5.s', '-5.0s', 'PT-5.0S', -5.0 ],

    ].each do |source, target, iso_target, sec|

      it "parses #{source.inspect}" do

        d = Fugit::Duration.parse(source)

        expect(d.class).to eq(::Fugit::Duration)
        expect(d.to_plain_s).to eq(target)
        expect(d.to_iso_s).to eq(iso_target)
        expect(d.to_sec).to eq(sec)
      end
    end

    it 'rejects lower case when ISO and :stricter' do

      expect(
        Fugit::Duration.parse('p1y', stricter: true)
      ).to eq(nil)
    end

    it 'rejects when :iso and not ISO' do

      expect(
        Fugit::Duration.parse('1y', iso: true)
      ).to eq(nil)
    end
  end

  describe '.do_parse' do

    it 'raises an ArgumentError when it cannot parse' do

      expect {
        Fugit::Duration.do_parse('NADA')
      }.to raise_error(
        ArgumentError, 'not a duration "NADA"'
      )
    end
  end

  describe '#deflate' do

    [

      %w[ 3600s    3600s     1h     ],
      %w[ 1y3600s  1y3600s   1y1h   ],
      %w[ 1d60s    86460s    1d1m   ],

      %w[ 3d-3h    248400s   2d21h  ],

      %w[ 0s       0s        0s  ],

    ].each do |source, step, target|

      it(
        "deflates #{source.inspect} via #{step.inspect} into #{target.inspect}"
      ) do

        d = Fugit::Duration.new(source)

        id = d.inflate

        expect(id.class).to eq(::Fugit::Duration)
        expect(id.to_plain_s).to eq(step)

        cd = d.deflate

        expect(cd.class).to eq(::Fugit::Duration)
        expect(cd.to_plain_s).to eq(target)
      end
    end
  end

  describe '#opposite' do

    it 'returns the additive inverse' do

      d = Fugit::Duration.new('1y2m-3h')
      od = d.opposite

      expect(od.to_plain_s).to eq('-1y+3h-2m')
      expect(od.to_iso_s).to eq('P-1YT3H-2M')
    end
  end

  describe '#-@' do

    it 'returns the additive inverse' do

      d = Fugit::Duration.new('1y2m-3h')
      od = - d

      expect(od.to_plain_s).to eq('-1y+3h-2m')
      expect(od.to_iso_s).to eq('P-1YT3H-2M')
    end
  end

  describe '#add' do

    it 'adds Numeric instances' do

      d = Fugit.parse('1Y2h')

      expect(d.add(1).to_plain_s).to eq('1y2h1s')
      expect((d + 1).to_plain_s).to eq('1y2h1s')
    end

    it 'adds Duration instances' do

      d0 = Fugit.parse('1y2h')
      d1 = Fugit.parse('1Y2h1s')

      expect(d0.add(d1).to_plain_s).to eq('2y4h1s')
      expect((d0 + d1).to_plain_s).to eq('2y4h1s')
    end

    it 'adds String instances (parses them as Duration)' do

      d = Fugit.parse('1Y2h')
      s = '1Y-1h1s'

      expect(d.add(s).to_plain_s).to eq('2y1h-1s')
      expect((d + s).to_plain_s).to eq('2y1h-1s')
    end

    it 'yields a Time instance when adding a Time instance' do

      d = Fugit.parse('1Y1m17s')
      t = Time.parse('2017-01-03 17:02:00')

      t1 = d.add(t)
      expect(Fugit.time_to_plain_s(t1, false)).to eq('2018-01-03 17:03:17')

      t1 = d + t
      expect(Fugit.time_to_plain_s(t1, false)).to eq('2018-01-03 17:03:17')
    end

    [
      [ '1Y1m17s', '2016-12-30 17:00:00', '2017-12-30 17:01:17' ],
      [ '1Y1M17s', '2016-12-30 17:00:00', '2018-01-30 17:00:17' ],
      [ '1M', '2016-02-02', '2016-03-02' ],
    ].each do |d, t, tt|

      it "adding #{t.inspect} to #{d.inspect} yields #{tt.inspect}" do

        d = Fugit.parse(d)
        t = Fugit.parse(t)

        t1 = d.add(t)

        expect(
          Fugit.time_to_plain_s(t1, false)
        ).to eq(
          Fugit.time_to_plain_s(Time.parse(tt), false)
        )
      end
    end

    it 'fails else' do

      d = Fugit.parse('1Y2h')
      x = false

      expect {
        d.add(x)
      }.to raise_error(
        ArgumentError, 'cannot add FalseClass instance to a Fugit::Duration'
      )
      expect {
        d + x
      }.to raise_error(
        ArgumentError, 'cannot add FalseClass instance to a Fugit::Duration'
      )
    end

    it 'preserves the zone of an EoTime instance (local)' do

      t = ::EtOrbi::EoTime.now
      t1 = Fugit.parse('1Y2M3m') + t

      expect(t1.zone).to eq(t.zone)
    end

    it 'preserves the zone of an EoTime instance (UTC)' do

      t = ::EtOrbi::EoTime.parse('2017-06-22 00:00:00 UTC')
      t1 = Fugit.parse('1Y2M3m') + t

      expect(t1.zone.canonical_identifier).to eq('UTC')
    end
  end

  describe '#substract' do

    it 'substracts Numeric instances' do

      d = Fugit.parse('1Y2h')

      expect(d.add(-1).to_plain_s).to eq('1y2h-1s')
      expect((d + -1).to_plain_s).to eq('1y2h-1s')
      expect((d - 1).to_plain_s).to eq('1y2h-1s')

      expect((d - 1).deflate.to_plain_s).to eq('1y1h59m59s')
    end

    it 'substracts Duration instances' do

      d0 = Fugit.parse('1Y2h')
      d1 = Fugit.parse('1Y2h1s')

      expect(d0.substract(d1).to_plain_s).to eq('-1s')
      expect((d0 + -d1).to_plain_s).to eq('-1s')
      expect((d0 - d1).to_plain_s).to eq('-1s')
    end

    it 'substracts String instances (parses them as Duration)' do

      d = Fugit.parse('1Y2h')
      s = '1Y-1h1s'

      expect(d.substract(s).to_plain_s).to eq('3h1s')
      expect((d - s).to_plain_s).to eq('3h1s')
    end

    it 'fails else' do

      d = Fugit.parse('1Y2h')
      x = false

      expect {
        d.substract(x)
      }.to raise_error(
        ArgumentError,
        'cannot substract FalseClass instance to a Fugit::Duration'
      )
      expect {
        d - x
      }.to raise_error(
        ArgumentError,
        'cannot substract FalseClass instance to a Fugit::Duration'
      )
    end
  end

  describe '#==' do

    it 'returns true when equal' do

      expect(
        Fugit::Duration.new('1Y2m') ==
        Fugit::Duration.new('1Y2m')
      ).to eq(true)

      expect(
        Fugit::Duration.new('1Y2m') ==
        Fugit::Duration.new('2m1Y')
      ).to eq(true)
    end

    it 'returns false else' do

      expect(
        Fugit::Duration.new('1Y2m') ==
        Fugit::Duration.new('1Y3m')
      ).to eq(false)

      expect(
        Fugit::Duration.new('1Y2m') !=
        Fugit::Duration.new('1Y3m')
      ).to eq(true)

      expect(
        Fugit::Duration.new('1Y2m') ==
        1
      ).to eq(false)

      expect(
        Fugit::Duration.new('1Y2m') !=
        1
      ).to eq(true)
    end
  end

  describe '#to_long_s' do

    [
      [ '1M1Y1M3h', '2 months, 1 year, and 3 hours' ],
      [ '1Y1M3h', '1 year, 1 month, and 3 hours' ],
    ].each do |duration, long|

      it "renders #{duration.inspect} as #{long.inspect}" do

        expect(Fugit::Duration.parse(duration).to_long_s).to eq(long)
      end
    end

    it 'understands the oxford: false option' do

      expect(
        Fugit::Duration.parse('1Y1M3h').to_long_s(oxford: false)
      ).to eq(
        '1 year, 1 month and 3 hours'
      )
    end
  end

  describe '#next_time' do

    it 'returns now + this duration if no argument' do

      d = Fugit::Duration.new('1Y')
      t = d.next_time

      expect(t.class).to eq(::EtOrbi::EoTime)

      expect(
        t.strftime('%Y-%m-%d')
      ).to eq(
        "#{Time.now.year + 1}-#{Time.now.strftime('%m-%d')}"
      )
    end

    it 'returns arg + this duration' do

      d = Fugit::Duration.new('1Y')
      t = d.next_time(Time.parse('2016-12-31'))

      expect(t.class).to eq(::EtOrbi::EoTime)
      expect(Fugit.time_to_plain_s(t, false)).to eq('2017-12-31 00:00:00')
    end
  end

  describe '.to_plain_s(o)' do

    it 'works' do

      expect(Fugit::Duration.to_plain_s(1000)).to eq('16m40s')
      expect(Fugit::Duration.to_plain_s('100d')).to eq('14w2d')
    end
  end

  describe '.to_iso_s(o)' do

    it 'works' do

      expect(Fugit::Duration.to_iso_s(1000)).to eq('PT16M40S')
      expect(Fugit::Duration.to_iso_s('100d')).to eq('P14W2D')
      expect(Fugit::Duration.to_iso_s('77d88s')).to eq('P11WT1M28S')
    end

    it 'may fail with an ArgumentError' do

      expect {
        Fugit::Duration.to_iso_s('77d88')
      }.to raise_error(ArgumentError, 'not a duration "77d88"')
    end
  end

  describe '.to_long_s(o)' do

    it 'works' do

      expect(
        Fugit::Duration.to_long_s(1000)).to eq('16 minutes, and 40 seconds')
      expect(
        Fugit::Duration.to_long_s('100d')).to eq('14 weeks, and 2 days')
    end
  end
end

