
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

      expect(t.class).to eq(::Time) # FIXME CHANGEME
      #expect(t.class).to eq(::EtOrbi::EoTime)
      expect(Fugit.time_to_plain_s(t)).to eq('2017-01-03 11:21:17')
    end
  end
end

