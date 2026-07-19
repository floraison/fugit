
#
# Specifying fugit
#
# Tue Jan  3 11:19:52 JST 2017  Ishinomaki
#


group Fugit do

  group '.parse' do

    CASES = {
      '2017-01-03 11:21:17' => [ EtOrbi::EoTime, '2017-01-03 11:21:17 Z' ],
      #'2017-01-03 11:21:17' => [ EtOrbi::EoTime, /^2017-/ ],
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

      'now' => [ EtOrbi::EoTime, /^#{Time.now.year}-\d\d-/ ], # gh-111
    }

    CASES.each do |k, (c, s)|

      k, opts = k
      t = k.inspect + (opts ? ' ' + opts.inspect : '')
      opts ||= {}

      test "parses #{t} into #{c} / #{s.inspect}" do

        c = c || NilClass
        x = in_zone('UTC') { Fugit.parse(k, opts) }

        assert x.class, c

        r =
          case x
          when EtOrbi::EoTime then Fugit.time_to_plain_s(x)
          when Fugit::Duration then x.to_plain_s
          when Fugit::Cron then x.to_cron_s
          else nil
          end

        if s.is_a?(Regexp)
          assert r.match?(s)
        else
          assert r, s
        end
      end
    end

    CASES.each do |k, (c, s)|

      k, opts = k

      t = k.inspect + (opts ? ' ' + opts.inspect : '')
      t = " \n #{t} \n "

      opts ||= {}

      test "parses #{t.inspect} into #{c} / #{s.inspect}" do

        c = c || NilClass
        x = in_zone('UTC') { Fugit.parse(k, opts) }

        assert(x.class, c)

        r =
          case x
          when EtOrbi::EoTime then Fugit.time_to_plain_s(x)
          when Fugit::Duration then x.to_plain_s
          when Fugit::Cron then x.to_cron_s
          else nil
          end

        if s.is_a?(Regexp)
          assert r.match?(s)
        else
          assert r, s
        end
      end
    end

    [

      'every 5 minutes',
      'every 15 minutes',
      'every 30 minutes',
      'every 40 minutes',

    ].each do |s|

      test "uses #parse_nat for #{s.inspect}" do

        o = Fugit.parse(s)
        n = Fugit.parse_nat(s)

        assert o, n
      end
    end

    test "returns nil quickly if the input is useless and long, gh-104" do

       o, d = do_time {
         Fugit.parse('0 0' + ' 0' * 10_000 + ' 1 jan * UTC') }

       assert d < 0.1
       assert_nil o
    end

    group '(Chronic)' do

      before do; require_chronic; end
      after do; unrequire_chronic; end

      test 'passes options to Chronic, gh-116' do

        assert_match(
          Fugit.parse('next weekday', now: Time.parse('2026-02-21')).to_s,
          /^2026-02-23 12:00:00/)
      end

      test 'passes options to Chronic, gh-116' do

        assert_match(
          Fugit.parse('next weekday', now: Time.parse('1999-12-03')).to_s,
          /^1999-12-06 12:00:00/)
      end
    end
  end

  group '.do_parse' do

    test 'parses' do

      c = Fugit.do_parse('every day at midnight')

      assert c.class, Fugit::Cron
      assert c.to_cron_s, '0 0 * * *'
    end

    [

      'I have a pen, I have an apple, pineapple!',
      #'0 13 * * 3#2#0', # gh-68 and gh-69

    ].each do |k|

      test "fails when attempting to parse #{k.inspect}" do

        assert_error(
          lambda { Fugit.do_parse(k) },
          ArgumentError)
      end
    end

    test "fails quickly if the input is useless and long, gh-104" do

       r, d = do_time {
         begin
           Fugit.do_parse('0 0' + ' 0' * 10_000 + ' 1 jan * UTC')
         rescue => err
           err
         end }

       assert d < 0.14

       assert(
         r.class,
         ArgumentError)
       assert(
         r.message,
         'invalid cron string "0 0 0 0 0 0 0 0 0 0 0 0 0 0 ... len 20015"')
    end
  end

  CRONISHES = {

    '* * * * *' => '* * * * *',
    'every day' => '0 0 * * *',

    '2022-12-5 11:32' => ArgumentError,
    'nada' => ArgumentError,
    '100 * * * *' => ArgumentError,
      }

  group '.parse_cronish' do

    CRONISHES.each do |k, v|

      if v.is_a?(String)

        test "parses #{k.inspect} to #{v.inspect}" do

          r = Fugit.parse_cronish(k)

          assert r.class, Fugit::Cron
          assert r.original, v
        end
      else

        test "returns nil for #{k.inspect}" do

          assert_nil Fugit.parse_cronish(k)
        end
      end
    end
  end

  group '.do_parse_cronish' do

    CRONISHES.each do |k, v|

      if v.is_a?(String)

        test "parses #{k.inspect} to #{v.inspect}" do

          r = Fugit.do_parse_cronish(k)

          assert r.class, Fugit::Cron
          assert r.original, v
        end
      else

        test "fails on #{k.inspect}" do

          assert_error(
            lambda { Fugit.do_parse_cronish(k) },
            v)
        end
      end
    end
  end

  group '.determine_type' do

    test 'returns nil if test cannot determine' do

      assert_nil Fugit.determine_type('nada')
      assert_nil Fugit.determine_type(true)
    end

    test 'returns the right type' do

      assert Fugit.determine_type('* * * * *'), 'cron'
      assert Fugit.determine_type('* * * * * *'), 'cron'
      assert Fugit.determine_type('1s'), 'in'
      assert Fugit.determine_type('2017-01-01'), 'at'
    end
  end

  group '.parse_max' do

    {

      'every day nada' =>
        [ 'every day', '0 0 * * *' ],

      'every day каждый день' =>
        [ 'every day', '0 0 * * *' ],

      '0 0 * * * Europe/Paris' =>
        [ '0 0 * * * Europe/Paris', '0 0 * * * Europe/Paris' ],

      '0 0 * * * America/New_York' =>
        [ '0 0 * * * America/New_York', '0 0 * * * America/New_York' ],

      '0 0 * * * Asia/Tokyo ever ' =>
        [ '0 0 * * * Asia/Tokyo', '0 0 * * * Asia/Tokyo' ],

      #'1Y2h' => [ '1Y2h', 'y' ],
      #'1Y2h toto' => [ '1Y2h', 'y' ],

    }.each do |k, (capture, original)|

      test "parses #{capture} in #{k}" do

        s, c = Fugit.parse_max(k)

        assert s, capture
        assert c.original, original
      end
    end
  end
end

