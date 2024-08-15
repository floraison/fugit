
#
# Specifying fugit
#
# Tue Jan  3 11:19:52 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit do

  describe '.parse' do

    CASES = {
      '2017-01-03 11:21:17' => [ EtOrbi::EoTime, '2017-01-03 11:21:17 Z' ],
      '00 00 L 5 *' => [ Fugit::Cron, '0 0 -1 5 *' ],
      '1Y3M2d' => [ Fugit::Duration, '1Y3M2D' ],
      '1Y2h' => [ Fugit::Duration, '1Y2h' ],
      '0 0 1 jan *' => [ Fugit::Cron, '0 0 1 1 *' ],
      '12y12M' => [ Fugit::Duration, '12Y12M' ],
      '2017-12-12' => [ EtOrbi::EoTime, '2017-12-12 00:00:00 Z' ],
      'every day at noon' => [ Fugit::Cron, '0 12 * * *' ],

      'at 12:00 PM' => [ Fugit::Cron, '0 12 * * *' ],
      'at 12 PM' => [ Fugit::Cron, '0 12 * * *' ],
      'at noon' => [ Fugit::Cron, '0 12 * * *' ],

        # testing nat: false and cron: false
        #
      [ '* * * * 1', { nat: false } ] => [ Fugit::Cron, '* * * * 1' ],
      [ 'every day at noon', { cron: false } ] => [ Fugit::Cron, '0 12 * * *' ],
        #
      [ 'every day at noon', { nat: false } ] => nil,
      [ '* * * * 1', { cron: false } ] => nil,

      true => nil,
      'I have a pen, I have an apple, pen apple' => nil,

      'every day at  noon' => [ Fugit::Cron, '0 12 * * *' ],
      '0  0 1 jan  *' => [ Fugit::Cron, '0 0 1 1 *' ],
      'at  12  PM' => [ Fugit::Cron, '0 12 * * *' ],
      'at  noon' => [ Fugit::Cron, '0 12 * * *' ],
    }

    CASES.each do |k, (c, s)|

      k, opts = k
      t = k.inspect + (opts ? ' ' + opts.inspect : '')
      opts ||= {}

      it "parses #{t} into #{c} / #{s.inspect}" do

        c = c || NilClass
        x = in_zone('UTC') { Fugit.parse(k, opts) }

        expect(x.class).to eq(c)

        expect(
          case x
          when EtOrbi::EoTime then Fugit.time_to_plain_s(x)
          when Fugit::Duration then x.to_plain_s
          when Fugit::Cron then x.to_cron_s
          else nil
          end
        ).to eq(s)
      end
    end

    CASES.each do |k, (c, s)|

      k, opts = k

      t = k.inspect + (opts ? ' ' + opts.inspect : '')
      t = " \n #{t} \n "

      opts ||= {}

      it "parses #{t.inspect} into #{c} / #{s.inspect}" do

        c = c || NilClass
        x = in_zone('UTC') { Fugit.parse(k, opts) }

        expect(x.class).to eq(c)

        expect(
          case x
          when EtOrbi::EoTime then Fugit.time_to_plain_s(x)
          when Fugit::Duration then x.to_plain_s
          when Fugit::Cron then x.to_cron_s
          else nil
          end
        ).to eq(s)
      end
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

    it "returns nil quickly if the input is useless and long, gh-104" do

       o, d = do_time {
         Fugit.parse('0 0' + ' 0' * 10_000 + ' 1 jan * UTC') }

       expect(o).to be(nil)
       expect(d).to be < 0.042
    end
  end

  describe '.do_parse' do

    it 'parses' do

      c = Fugit.do_parse('every day at midnight')

      expect(c.class).to eq(Fugit::Cron)
      expect(c.to_cron_s).to eq('0 0 * * *')
    end

    [

      'I have a pen, I have an apple, pineapple!',
      #'0 13 * * 3#2#0', # gh-68 and gh-69

    ].each do |k|

      it "fails when attempting to parse #{k.inspect}" do

        expect { Fugit.do_parse(k) }.to raise_error(ArgumentError)
      end
    end

    it "fails quickly if the input is useless and long, gh-104" do

       r, d = do_time {
         begin
           Fugit.do_parse('0 0' + ' 0' * 10_000 + ' 1 jan * UTC')
         rescue => err
           err
         end }

       expect(r.class).to be(
         ArgumentError)
       expect(r.message).to eq(
         'invalid cron string "0 0 0 0 0 0 0 0 0 0 0 0 0 0 ... len 20015"')

       expect(d).to be < 0.042
    end
  end

  CRONISHES = {

    '* * * * *' => '* * * * *',
    'every day' => '0 0 * * *',

    '2022-12-5 11:32' => ArgumentError,
    'nada' => ArgumentError,
    '100 * * * *' => ArgumentError,
      }

  describe '.parse_cronish' do

    CRONISHES.each do |k, v|

      if v.is_a?(String)

        it "parses #{k.inspect} to #{v.inspect}" do

          r = Fugit.parse_cronish(k)

          expect(r.class).to eq(Fugit::Cron)
          expect(r.original).to eq(v)
        end
      else

        it "returns nil for #{k.inspect}" do

          expect(Fugit.parse_cronish(k)).to eq(nil)
        end
      end
    end
  end

  describe '.do_parse_cronish' do

    CRONISHES.each do |k, v|

      if v.is_a?(String)

        it "parses #{k.inspect} to #{v.inspect}" do

          r = Fugit.do_parse_cronish(k)

          expect(r.class).to eq(Fugit::Cron)
          expect(r.original).to eq(v)
        end
      else

        it "fails on #{k.inspect}" do

          expect { Fugit.do_parse_cronish(k) }.to raise_error(v)
        end
      end
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

