
#
# Specifying fugit
#
# Wed Jan  4 07:23:09 JST 2017  Ishinomaki
#


group Fugit::Nat do

  group '.parse' do

    group '(single crons)' do

      File.read('test/_nat_single_crons.txt')
        .gsub(/\\\n/, '')
        .split("\n")
        .select { |l| l.match(/^[a-zA-Z]/) }
        .collect { |l| l.split('#').first }
        .collect { |l| l.split(/⟶/).collect(&:strip) }
        .each do |nat, cron|

          test "parses #{nat.inspect} into #{cron.inspect}" do

            c = Fugit::Nat.parse(nat)

            assert c.class, Fugit::Cron
            assert c.original, cron
            #assert c.to_cron_s, cron
          end
        end
    end

    test 'parses "every Fri-Sun at 18:00 UTC" (gh-27)' do

      c = Fugit::Nat.parse('every Fri-Sun at 18:00 UTC')

      assert c.original, '0 18 * * 5-0 UTC'
      assert c.weekdays, [ [ 0 ], [ 5 ], [ 6 ] ]
    end

    group 'multi:' do

      { # mostly for gh-24 and `multi: true`

        [ 'every day at 18:15 and 20:45', {} ] =>
          '15 18 * * *',
        [ 'every day at 18:15 and 20:45', { multi: true } ] =>
          [ '15 18 * * *', '45 20 * * *' ],
        [ 'every day at 18:15', { multi: true } ] =>
          [ '15 18 * * *' ],
        [ 'every day at 18:15 and 20:45', { multi: :fail } ] =>
          [ ArgumentError, /\Amultiple crons in / ],
        [ 'every 1 hour', { multi: :fail } ] => # gh-28
          '0 * * * *',

      }.each do |(nat, opts), result|

        if (
          result.is_a?(Array) &&
          result[0].is_a?(Class) &&
          result[0].ancestors.include?(Exception)
        ) then

          test "fails for #{nat.inspect} (#{opts.inspect})" do

            assert_error(
              lambda { Fugit::Nat.parse(nat, opts) },
              *result)
          end

        else

          test(
            "parses #{nat.inspect} (#{opts.inspect}) into #{result.inspect}"
          ) do

            r = Fugit::Nat.parse(nat, opts)
#File.open('out.rb', 'ab') { |f| f.puts("\n#{nat.inspect}\n  #{r.inspect}") }
#p r
#expect(r).not_to eq(nil)

            if opts[:multi] == true
              assert r.collect(&:class).uniq, [ Fugit::Cron ]
              assert r.collect(&:original), result
            else
              assert r.class, Fugit::Cron
              assert r.original, result
            end
          end
        end
      end
    end

    [

      true,
      'nada',
      'every 2 years',
      'every 2 weeks',

      #'every 17 hours',
        # by default/strict:false --> "0 */17 * * *"
      #'every 27 hours',
        # by default/strict:false --> "0 */27 * * *"

      #'every 90 minutes',
      'every 100 minutes',
        # because the parser accepts 2 digits...

    ].each do |input|

      test "rejects (returns nil) for #{input.inspect}" do

        assert_nil Fugit::Nat.parse(input)
      end
    end

    group 'strict: true' do

      [

        'every 17 hours',

        'every 27 hours',
        'every 2 years',
        'every 2 weeks',

        'every 90 minutes',
        'every 100 minutes',

      ].each do |input|

        test "rejects (returns nil) for #{input.inspect}" do

          assert_nil Fugit::Nat.parse(input, strict: true)
        end
      end
    end

    test "rejects (returns nil) if input length > 256" do

      assert_nil Fugit::Nat.parse('a' * 5000)
    end
  end

  group '.do_parse' do

    [

      'at noon',
      'at midnight',

    ].each do |input|

      test "parses as a Fugit::Cron #{input.inspect}" do

        assert Fugit.do_parse(input).class, Fugit::Cron
      end
    end

    [

      true,
      'nada',
      'every 2 years',
      'every 2 weeks',

      #'every 17 hours',
        # by default/strict:false --> "0 */17 * * *"
      #'every 27 hours',
        # by default/strict:false --> "0 */27 * * *"

    ].each do |input|

      test "fails with an ArgumentError for #{input.inspect}" do

        assert_error(
          lambda { Fugit::Nat.do_parse(input) },
          ArgumentError, /could not parse a nat/)
      end
    end

    test "fails with an ArgumentError if input length > 256" do

      assert_error(
        lambda { Fugit::Nat.do_parse('a' * 5000) },
        ArgumentError, /too long .+ 5000 > 256/)
    end
  end
end

group Fugit do

  group '.parse_nat' do

    {

      "every day at five" => '0 5 * * *',
      "every day at 5 pm in Asia/Tokyo" => '0 17 * * * Asia/Tokyo',
      " \nevery day at five \n" => '0 5 * * *',
      "\n every day at 5 pm  in Asia/Tokyo\n" => '0 17 * * * Asia/Tokyo',

    }.each do |src, cron_s|

      test "strips and parses #{src.inspect}" do

        r = Fugit.parse_nat(src)

        assert r.class, Fugit::Cron
        assert r.to_cron_s, cron_s
      end
    end
  end
end

