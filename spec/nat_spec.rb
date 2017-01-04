
#
# Specifying fugit
#
# Wed Jan  4 07:23:09 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Nat do

  describe '.parse' do

    [
      [ 'every day at five', '0 5 * * *' ],
      [ 'every weekday at five', '0 5 * * 1,2,3,4,5' ],
      [ 'every day at 5 pm', '0 17 * * *' ],
      [ 'every tuesday at 5 pm', '0 17 * * 2' ],
      [ 'every wed at 5 pm', '0 17 * * 3' ],
      [ 'every day at 16:30', '30 16 * * *' ],
      [ 'every day at noon', '0 12 * * *' ],
      [ 'every day at midnight', '0 0 * * *' ],
#      [ 'every 1st of the month at midnight', '' ],
#      [ 'every tuesday and monday at 5pm', '' ],
#      [ 'at 5 after 4, everyday', '' ],
    ].each do |nat, cron|

      it "parses #{nat.inspect} into #{cron.inspect}" do

        c = Fugit::Nat.parse(nat)

        expect(c.class).to eq(Fugit::Cron)
        expect(c.to_cron_s).to eq(cron)
      end
    end
  end
end

