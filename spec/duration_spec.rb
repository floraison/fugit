
#
# Specifying fugit
#
# Tue Jan  3 11:31:29 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Duration do

  DURATIONS = [
    [ '1y2M', '1Y2M', 'P1Y2M', 123 ]
  ]

  describe '.parse' do

    DURATIONS.each do |source, target, _, _|

      it "parses #{source.inspect} as #{target.inspect}" do

        d = Fugit::Duration.parse(source)

        expect(d.class).to eq(::Fugit::Duration)
        expect(d.to_duration_s).to eq(target)
      end
    end
  end

  describe '.to_sec' do

    it 'turns approximates a duration into a number of seconds'
  end

  describe '#compact' do

    it 'compacts'
  end
end

