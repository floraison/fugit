
#
# Specifying fugit
#
# Tue Jan  3 11:31:29 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Duration do

  describe '.parse' do

    it 'fails with an ArgumentError when it cannot parse' do

      expect {
        Fugit::Duration.parse('NADA')
      }.to raise_error(
        ArgumentError, 'cannot derive Fugit::Duration out of "NADA"'
      )
    end

    it 'accepts a Numeric' do

      expect(Fugit::Duration.parse(1000).to_plain_s).to eq('1000s')
      expect(Fugit::Duration.parse(1001.05).to_plain_s).to eq('1001s')
    end

    DAY_S = 24 * 3600

    [

      [ '1y2M', '1Y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ '1M1y1M', '1Y2M', 'P1Y2M', 365 * DAY_S + 60 * DAY_S ],
      [ '10d10h', '10D10h', 'P10DT10H', 10 * DAY_S + 10 * 3600 ],
      [ '100', '100s', 'PT100S', 100 ],

      [ '-1y-2M', '-1Y-2M', 'P-1Y-2M', - 365 * DAY_S - 60 * DAY_S ],
      [ '1M-1y-1M', '-1Y', 'P-1Y', - 365 * DAY_S ],

    ].each do |source, target, iso_target, sec|

      it "parses #{source.inspect}" do

        d = Fugit::Duration.parse(source)

        expect(d.class).to eq(::Fugit::Duration)
        expect(d.to_plain_s).to eq(target)
        expect(d.to_iso_s).to eq(iso_target)
        expect(d.to_sec).to eq(sec)
      end
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
end

