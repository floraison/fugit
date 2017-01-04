
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

      expect(Fugit::Duration.parse(1000).to_plain_s).to eq('1000s')
      expect(Fugit::Duration.parse(1001.05).to_plain_s).to eq('1001.05s')
    end

    DAY_S = 24 * 3600

    [

      [ '1y2M', '1Y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ '1M1y1M', '1Y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ '10d10h', '10D10h', 'P10DT10H', 10 * DAY_S + 10 * 3600 ],
      [ '100', '100s', 'PT100S', 100 ],

      [ '-1y-2M', '-1Y-2M', 'P-1Y-2M', - 365 * DAY_S - 60 * DAY_S ],
      [ '1M-1y-1M', '-1Y', 'P-1Y', - 365 * DAY_S ],

      [ '1y 2M', '1Y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ '1M 1y  1M', '1Y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ ' 1M1y1M ', '1Y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],

      [ '1 year and 2 months', '1Y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ '1 y, 2 M, and 2 months', '1Y4M', 'P1Y4M', 41904000 ],
      [ '1 y, 2 M and 2 m', '1Y2M2m', 'P1Y2MT2M', 36720120 ],

      [ 'P1Y2M', '1Y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ 'P1Y2M', '1Y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ 'P10DT10H', '10D10h', 'P10DT10H', 10 * DAY_S + 10 * 3600 ],
      [ 'PT100S', '100s', 'PT100S', 100 ],

      [ 'P-1Y-2M', '-1Y-2M', 'P-1Y-2M', - 365 * DAY_S - 60 * DAY_S ],
      [ 'p1M-1y-1Mt-1M', '-1Y-1m', 'P-1YT-1M', -31536060 ],

      [ '1.4s', '1.4s', 'PT1.4S', 1.4 ],
      [ 'PT1.5S', '1.5s', 'PT1.5S', 1.5 ],
      [ '.4s', '0.4s', 'PT0.4S', 0.4 ],
      [ 'PT.5S', '0.5s', 'PT0.5S', 0.5 ],

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

      [ '3600s', '3600s', '1h' ],
      [ '1y3600s', '1Y3600s', '1Y1h' ],
      [ '1d60s', '86460s', '1D1m' ],

      [ '3d-3h', '248400s', '2D21h' ],

    ].each do |source, step, target|

      it "deflates #{source.inspect} via #{step.inspect} into #{target.inspect}" do

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

      expect(od.to_plain_s).to eq('-1Y3h-2m')
      expect(od.to_iso_s).to eq('P-1YT3H-2M')
    end
  end

  describe '#-@' do

    it 'returns the additive inverse' do

      d = Fugit::Duration.new('1y2m-3h')
      od = - d

      expect(od.to_plain_s).to eq('-1Y3h-2m')
      expect(od.to_iso_s).to eq('P-1YT3H-2M')
    end
  end

  describe '#add' do

    it 'adds Numeric instances' do

      d = Fugit.parse('1Y2h')

      expect(d.add(1).to_plain_s).to eq('1Y2h1s')
      expect((d + 1).to_plain_s).to eq('1Y2h1s')
    end

    it 'adds Duration instances' do

      d0 = Fugit.parse('1Y2h')
      d1 = Fugit.parse('1Y2h1s')

      expect(d0.add(d1).to_plain_s).to eq('2Y4h1s')
      expect((d0 + d1).to_plain_s).to eq('2Y4h1s')
    end

    it 'adds String instances (parses them as Duration)' do

      d = Fugit.parse('1Y2h')
      s = '1Y-1h1s'

      expect(d.add(s).to_plain_s).to eq('2Y1h1s')
      expect((d + s).to_plain_s).to eq('2Y1h1s')
    end

    it 'yields a Time instance when adding a Time instance' do

      d = Fugit.parse('1Y1m17s')
      t = Time.parse('2017-01-03 17:02:00')

      t1 = d.add(t)
      expect(Fugit.time_to_plain_s(t1)).to eq('2018-01-03 17:03:17')

      t1 = d + t
      expect(Fugit.time_to_plain_s(t1)).to eq('2018-01-03 17:03:17')
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
          Fugit.time_to_plain_s(t1)
        ).to eq(
          Fugit.time_to_plain_s(Time.parse(tt))
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

    it 'preserves the zone of a Time instance' do

      t = Time.now
      t1 = Fugit.parse('1Y2M3m') + t

      expect(t1.zone).to eq(t.zone)

      t = Time.now.utc
      t1 = Fugit.parse('1Y2M3m') + t

      expect(t1.zone).to eq('UTC')
    end
  end

  describe '#substract' do

    it 'substracts Numeric instances' do

      d = Fugit.parse('1Y2h')

      expect(d.add(-1).to_plain_s).to eq('1Y2h-1s')
      expect((d + -1).to_plain_s).to eq('1Y2h-1s')
      expect((d - 1).to_plain_s).to eq('1Y2h-1s')

      expect((d - 1).deflate.to_plain_s).to eq('1Y1h59m59s')
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

      expect(d.substract(s).to_plain_s).to eq('3h-1s')
      expect((d - s).to_plain_s).to eq('3h-1s')
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

      expect(t.class).to eq(Time)

      expect(
        t.strftime('%Y-%m-%d')
      ).to eq(
        "#{Time.now.year + 1}-#{Time.now.strftime('%m-%d')}"
      )
    end

    it 'returns arg + this duration' do

      d = Fugit::Duration.new('1Y')
      t = d.next_time(Time.parse('2016-12-31'))

      expect(t.class).to eq(Time)
      expect(Fugit.time_to_s(t)).to eq('2017-12-31T00:00:00')
    end
  end
end

