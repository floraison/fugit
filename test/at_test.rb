
#
# Specifying fugit
#
# Sat Jun 10 07:44:42 JST 2017  圓さんの家
#


group Fugit do

  group '.parse_at' do

    test 'parses time points' do

      t = Fugit.parse_at('2017-01-03 11:21:17')

      assert t.class, ::EtOrbi::EoTime
      assert Fugit.time_to_plain_s(t, false), '2017-01-03 11:21:17'
    end

    test 'returns an EoTime instance as is' do

      eot = ::EtOrbi::EoTime.new('2017-01-03 11:21:17', 'America/Los_Angeles')
      t = Fugit.parse_at(eot)

      assert t.class, ::EtOrbi::EoTime
      assert t.object_id, eot.object_id
    end

    test 'strips before parsing' do

      t = Fugit.parse_at(" 2017-01-03 11:21:17\n ")

      assert Fugit.time_to_plain_s(t, false), '2017-01-03 11:21:17'
    end

    group 'with timezones' do

      [

        [ '2018-09-04 06:41:34 +11', '2018-09-04 06:41:34 +11 +1100' ],
        [ '2018-09-04 06:41:34 +1100', '2018-09-04 06:41:34 +1100 +1100' ],
        [ '2018-09-04 06:41:34 +11:00', '2018-09-04 06:41:34 +11:00 +1100' ],
        [ '2018-09-04 06:41:34 Etc/GMT-11', '2018-09-04 06:41:34 +11 +1100' ],
        #[ '2018-09-04 06:41:34 UTC+11', nil ],

        [ "\n2018-09-04 06:41:34 +11:00",
          '2018-09-04 06:41:34 +11:00 +1100' ],
        [ " \n 2018-09-04 06:41:34  Etc/GMT-11",
          '2018-09-04 06:41:34 +11 +1100' ],

      ].each do |string, plain|

        test "parses #{string.inspect}" do

          t = Fugit.parse_at(string)

          assert t.class, ::EtOrbi::EoTime
          assert Fugit.time_to_zone_s(t), plain
        end
      end
    end
  end
end

