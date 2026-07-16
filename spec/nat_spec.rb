
#
# Specifying fugit
#
# Wed Jan  4 07:23:09 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Nat do

  describe '.parse' do

    context '(single crons)' do

      File.read('spec/_nat_single_crons.txt')
        .gsub(/\\\n/, '')
        .split("\n")
        .select { |l| l.match(/^[a-zA-Z]/) }
        .collect { |l| l.split('#').first }
        .collect { |l| l.split(/⟶/).collect(&:strip) }
        .each do |nat, cron|

          it "parses #{nat.inspect} into #{cron.inspect}" do

            c = Fugit::Nat.parse(nat)

            expect(c.class).to eq(Fugit::Cron)
            expect(c.original).to eq(cron)
            #expect(c.to_cron_s).to eq(cron)
          end
        end
    end

    it 'parses "every Fri-Sun at 18:00 UTC" (gh-27)' do

      c = Fugit::Nat.parse('every Fri-Sun at 18:00 UTC')

      expect(c.original).to eq('0 18 * * 5-0 UTC')
      expect(c.weekdays).to eq([ [ 0 ], [ 5 ], [ 6 ] ])
    end

    context 'multi:' do

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

          it "fails for #{nat.inspect} (#{opts.inspect})" do

            expect { Fugit::Nat.parse(nat, opts) }.to raise_error(*result)
          end

        else

          it "parses #{nat.inspect} (#{opts.inspect}) into #{result.inspect}" do

            r = Fugit::Nat.parse(nat, opts)
#File.open('out.rb', 'ab') { |f| f.puts("\n#{nat.inspect}\n  #{r.inspect}") }
#p r
#expect(r).not_to eq(nil)

            if opts[:multi] == true
              expect(r.collect(&:class).uniq).to eq([ Fugit::Cron ])
              expect(r.collect(&:original)).to eq(result)
            else
              expect(r.class).to eq(Fugit::Cron)
              expect(r.original).to eq(result)
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

      it "rejects (returns nil) for #{input.inspect}" do

        expect(Fugit::Nat.parse(input)).to eq(nil)
      end
    end

    context 'strict: true' do

      [

        'every 17 hours',

        'every 27 hours',
        'every 2 years',
        'every 2 weeks',

        'every 90 minutes',
        'every 100 minutes',

      ].each do |input|

        it "rejects (returns nil) for #{input.inspect}" do

          expect(Fugit::Nat.parse(input, strict: true)).to eq(nil)
        end
      end
    end

    it "rejects (returns nil) if input length > 256" do

      expect(Fugit::Nat.parse('a' * 5000)).to be(nil)
    end
  end

  describe '.do_parse' do

    [

      'at noon',
      'at midnight',

    ].each do |input|

      it "parses as a Fugit::Cron #{input.inspect}" do

        expect(Fugit.do_parse(input).class).to eq(Fugit::Cron)
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

      it "fails with an ArgumentError for #{input.inspect}" do

        expect { Fugit::Nat.do_parse(input)
          }.to raise_error(ArgumentError, /could not parse a nat/)
      end
    end

    it "fails with an ArgumentError if input length > 256" do

      expect { Fugit::Nat.do_parse('a' * 5000)
        }.to raise_error(ArgumentError, /too long .+ 5000 > 256/)
    end
  end
end

describe Fugit do

  describe '.parse_nat' do

    {

      "every day at five" => '0 5 * * *',
      "every day at 5 pm in Asia/Tokyo" => '0 17 * * * Asia/Tokyo',
      " \nevery day at five \n" => '0 5 * * *',
      "\n every day at 5 pm  in Asia/Tokyo\n" => '0 17 * * * Asia/Tokyo',

    }.each do |src, cron_s|

      it "strips and parses #{src.inspect}" do

        r = Fugit.parse_nat(src)

        expect(r.class).to eq(Fugit::Cron)
        expect(r.to_cron_s).to eq(cron_s)
      end
    end
  end
end

