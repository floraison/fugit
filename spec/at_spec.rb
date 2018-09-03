
#
# Specifying fugit
#
# Sat Jun 10 07:44:42 JST 2017  圓さんの家
#

require 'spec_helper'


describe Fugit do

  describe '.parse_at' do

    it 'parses time points' do

      t = Fugit.parse_at('2017-01-03 11:21:17')

      expect(t.class).to eq(::EtOrbi::EoTime)
      expect(Fugit.time_to_plain_s(t, false)).to eq('2017-01-03 11:21:17')
    end

    it 'returns an EoTime instance as is' do

      eot = ::EtOrbi::EoTime.new('2017-01-03 11:21:17', 'America/Los_Angeles')
      t = Fugit.parse_at(eot)

      expect(t.class).to eq(::EtOrbi::EoTime)
      expect(t.object_id).to eq(eot.object_id)
    end

    context 'with timezones' do

      [

        [ '2018-09-04 06:41:34 +11', '2018-09-04 06:41:34 +11 +1100' ],
        [ '2018-09-04 06:41:34 +1100', '2018-09-04 06:41:34 +1100 +1100' ],
        [ '2018-09-04 06:41:34 +11:00', '2018-09-04 06:41:34 +11:00 +1100' ],
        [ '2018-09-04 06:41:34 Etc/GMT-11', '2018-09-04 06:41:34 +11 +1100' ],
        #[ '2018-09-04 06:41:34 UTC+11', nil ],

      ].each do |string, plain|

        it "parses #{string}" do

          t = Fugit.parse_at(string)

          expect(t.class).to eq(::EtOrbi::EoTime)
          expect(Fugit.time_to_zone_s(t)).to eq(plain)
        end
      end
    end
  end
end

