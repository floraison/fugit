
#
# Specifying fugit
#
# Sun Jan  1 16:40:00 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Cron do

  describe '.parse' do

    it 'parses @reboot'

    it 'parses @yearly' do # "0 0 1 1 *"

      c = Fugit::Cron.parse('@yearly')

      pp c
      #expect(c.to_cron_string).to eq('0 0 1 1 *')
    end

    it 'parses @annually'
    it 'parses @monthly' # "0 0 1 * *"
    it 'parses @weekly' # "0 0 * * 0"
    it 'parses @daily' # "0 0 * * *"
    it 'parses @midnight'
    it 'parses @hourly' # "0 * * * *"

    [
      [ '5 0 * * *', :xxx ], # 5 minutes after midnight, every day
      [ '15 14 1 * *', :xxx ], # at 1415 on the 1st of every month
      [ '0 22 * * 1-5', :xxx ], # at 2200 on weekdays
      [ '23 0-23/2 * * *', :xxx ], # 23 minutes after midnight, 0200, 0400, ...
      #[ '5 4 * * sun', :xxx ], # 0405 every sunday
    ].each do |cron, expected|

      it "parses #{cron}" do

        c = Fugit::Cron.parse(cron)

        expect(c).not_to eq(nil)
      end
    end

    it 'rejects * 25 * * *' do

      expect {
        Fugit::Cron.parse('* 25 * * *')
      }.to raise_error(
        ArgumentError, 'couldn\'t parse "* 25 * * *"'
      )
    end
  end
end

