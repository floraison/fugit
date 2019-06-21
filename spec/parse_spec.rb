
#
# Specifying fugit
#
# Tue Jan  3 11:19:52 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit do

  describe '.parse' do

    it 'parses time points' do

      t = Fugit.parse('2017-01-03 11:21:17')

      expect(t.class).to eq(::EtOrbi::EoTime)
      expect(Fugit.time_to_plain_s(t, false)).to eq('2017-01-03 11:21:17')
    end

    it 'parses cron strings' do

      c = Fugit.parse('00 00 L 5 *')

      expect(c.class).to eq(Fugit::Cron)
      expect(c.to_cron_s).to eq('0 0 -1 5 *')
    end

    it 'parses durations' do

      d = Fugit.parse('1Y3M2d')

      expect(d.class).to eq(Fugit::Duration)
      expect(d.to_plain_s).to eq('1Y3M2D')
    end

    it 'parses durations' do

      d = Fugit.parse('1Y2h')

      expect(d.class).to eq(Fugit::Duration)
      expect(d.to_plain_s).to eq('1Y2h')
    end

    [
      [ '0 0 1 jan *', ::Fugit::Cron ],
      [ '12y12M', ::Fugit::Duration ],
      [ '2017-12-12', ::EtOrbi::EoTime ],
      #[ 'every day at noon', ::Fugit::Cron ],
    ].each do |str, kla|

      it "parses #{str.inspect} into a #{kla} instance" do

        r = Fugit.parse(str)

        expect(r.class).to eq(kla)
      end
    end

    it 'parses "nats"' do

      c = Fugit.parse('every day at noon')

      expect(c.class).to eq(Fugit::Cron)
      expect(c.to_cron_s).to eq('0 12 * * *')
    end

    it 'disables nat parsing when nat: false' do

      x = Fugit.parse('* * * * 1', nat: false)
      expect(x.class).to eq(Fugit::Cron)

      x = Fugit.parse('every day at noon', nat: false)
      expect(x).to eq(nil)

      x = Fugit.parse('* * * * 1', cron: false)
      expect(x).to eq(nil)

      x = Fugit.parse('every day at noon', cron: false)
      expect(x.class).to eq(Fugit::Cron)
    end

    it 'returns nil when it cannot parse' do

      expect(Fugit.parse(true)).to eq(nil)
      expect(Fugit.parse('I have a pen, I have an apple, pen apple')).to eq(nil)
    end

    [

      'every 5 minutes',
      'every 15 minutes',
      'every 30 minutes',
      'every 40 minutes',

    ].each do |s|

      it "uses #parse_nat for #{s.inspect}" do

        o = Fugit.parse(s)
        n = Fugit.parse_nat(s)

        expect(o).to eq(n)
      end
    end
  end

  describe '.do_parse' do

    it 'parses' do

      c = Fugit.do_parse('every day at midnight')

      expect(c.class).to eq(Fugit::Cron)
      expect(c.to_cron_s).to eq('0 0 * * *')
    end

    it 'fails when it cannot parse' do

      expect {
        Fugit.do_parse('I have a pen, I have an apple, pineapple!')
      }.to raise_error(
        ArgumentError,
        'found no time information in ' +
        '"I have a pen, I have an apple, pineapple!"'
      )
    end
  end

  describe '.determine_type' do

    it 'returns nil if it cannot determine' do

      expect(Fugit.determine_type('nada')).to eq(nil)
      expect(Fugit.determine_type(true)).to eq(nil)
    end

    it 'returns the right type' do

      expect(Fugit.determine_type('* * * * *')).to eq('cron')
      expect(Fugit.determine_type('* * * * * *')).to eq('cron')
      expect(Fugit.determine_type('1s')).to eq('in')
      expect(Fugit.determine_type('2017-01-01')).to eq('at')
    end
  end
end

