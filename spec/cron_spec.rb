
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

      expect(c.to_cron_string).to eq('0 0 1 1 *')
    end

    it 'parses @annually'
    it 'parses @monthly' # "0 0 1 * *"
    it 'parses @weekly' # "0 0 * * 0"
    it 'parses @daily' # "0 0 * * *"
    it 'parses @midnight'
    it 'parses @hourly' # "0 * * * *"
  end
end

