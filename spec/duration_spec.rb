
#
# Specifying fugit
#
# Tue Jan  3 11:31:29 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Duration do

  DURATIONS = [
    [ '1y2M', '1Y2M', 'P1Y2M', 123 ],
    [ '10d10h', '10D10h', 'P10DT10H', 123 ],
  ]

  describe '.parse' do

    DURATIONS.each do |source, target, iso_target, _|

      it "parses #{source.inspect}" do

        d = Fugit::Duration.parse(source)

        expect(d.class).to eq(::Fugit::Duration)
        expect(d.to_duration_s).to eq(target)
        expect(d.to_iso_duration_s).to eq(iso_target)
      end
    end
  end

  describe '#compact' do

    it 'compacts'
  end
end

