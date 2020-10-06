
#
# Specifying fugit
#
# Wed Jan  4 07:23:09 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Nat do

  describe '.parse' do

    context '(simple crons)' do

      {

        'every day at five' => '0 5 * * *',
        'every weekday' => '0 0 * * 1-5',
        'every weekday at five' => '0 5 * * 1-5',
        'every weekday at five pm' => '0 17 * * 1-5',
        'every day at 5 pm' => '0 17 * * *',
        'every monday' => '0 0 * * 1',
        'every tuesday at 5 pm' => '0 17 * * 2',
        'every wed at 5 pm' => '0 17 * * 3',
        'every day at 16:30' => '30 16 * * *',
        'every day at noon' => '0 12 * * *',
        'every day at midnight' => '0 0 * * *',
        'every day at 5 pm on America/Bogota' => '0 17 * * * America/Bogota',
        'every day at 5 pm in Asia/Tokyo' => '0 17 * * * Asia/Tokyo',
        'every day at 5 pm in Etc/GMT-11' => '0 17 * * * Etc/GMT-11',
        'every day at 5 pm in Etc/GMT+5' => '0 17 * * * Etc/GMT+5',
        'every 3h' => '0 */3 * * *',
        'every 3 hours' => '0 */3 * * *',
        'every 4M' => '0 0 1 */4 *',
        'every 4 months' => '0 0 1 */4 *',
        'every 5m' => '*/5 * * * *',
        'every 5 min' => '*/5 * * * *',
        'every 5 minutes' => '*/5 * * * *',
        'every 15s' => '*/15 * * * * *',
        'every 15 sec' => '*/15 * * * * *',
        'every 15 seconds' => '*/15 * * * * *',
        'every 1 h' => '0 * * * *',
        #'every 1 hour' => '0 * * * *',
        #'every 1 month' => '0 0 1 * *',
        #'every 1 second' => '* * * * * *',
          # those 3 are moved below for gh-37

        'every 12 hours at minute 50' => '50 */12 * * *',
        'every 12h at min 50' => '50 */12 * * *',
          #
          # gh-41

        'every 1st of the month at midnight' => '0 0 1 * *',
        'every first of the month at midnight' => '0 0 1 * *',
        'Every 2nd of the month at 10:00' => '0 10 2 * *',
        'Every second of the month at 10:00' => '0 10 2 * *',
        'every month on day 2 at 10:00' => '0 10 2 * *',
        'every month on day 2 and 5 at 10:00' => '0 10 2,5 * *',
        'every month on days 1,15 at 10:00' => '0 10 1,15 * *',
        'every month on the 1st at 11:00' => '0 11 1 * *',
        'every month on the 1st and 2nd at 12:00 pm' => '0 24 1,2 * *',
        'every month on the 1st and the 2nd at 12:00 pm' => '0 24 1,2 * *',
        'every month on the 1st and the second at 12:00 pm' => '0 24 1,2 * *',
        'every 15th of the month' => '0 0 15 * *', # gh-38 title
          #
          # gh-38

        #'at 5 after 4, everyday' => '',

        'every day at 6pm and 8pm' => '0 18,20 * * *',
        'every day at 6pm and 8pm UTC' => '0 18,20 * * * UTC',
        'every day at 18:00 and 20:00' => '0 18,20 * * *',
        'every day at 18:00 and 20:00 UTC' => '0 18,20 * * * UTC',
          #
          # gh-24

        'every day at 8:30' => '30 8 * * *',
        'every day at 08:30' => '30 8 * * *',
        'every day at 8:30 am' => '30 8 * * *',
        'every day at 08:30 am' => '30 8 * * *',
        'every day at 8:30 AM' => '30 8 * * *',
        'every day at 8:30 pm' => '30 20 * * *',
        'every day at 08:30 pm' => '30 20 * * *',
        'every day at 08:30 PM' => '30 20 * * *',
          #
          # gh-42

        #'every day at 18:15 and 20:45' => '* * * * *',
          #
          # gh-24 see below

        'every friday and thursday' => '0 0 * * 4,5',
        'every tuesday and monday at 5pm' => '0 17 * * 1,2',
        'every wed or Monday at 5pm and 11' => '0 11,17 * * 1,3',
        'every Mon,Tue,Wed,Thu,Fri at 18:00' => '0 18 * * 1,2,3,4,5',
        'every Mon, Tue, and Wed at 18:15' => '15 18 * * 1,2,3',
        'every Mon to Thu at 18:20' => '20 18 * * 1-4',
        'every Mon to Thu, 18:20' => '20 18 * * 1-4',
        'every mon-thu at 18:20' => '20 18 * * 1-4',
        'every Monday to Thursday at 18:20' => '20 18 * * 1-4',
        'every Monday through Friday at 19:20' => '20 19 * * 1-5',
        'from Monday through Friday at 19:21' => '21 19 * * 1-5',
        'from Monday to Friday at 19:22' => '22 19 * * 1-5',
          #
          # gh-25

        'every day at 18:00 and 18:15' => '0,15 18 * * *',
        'every day at 18:00, 18:15' => '0,15 18 * * *',
        'every day at 18:00, 18:15, 20:00, and 20:15' => '0,15 18,20 * * *',
          #
          # gh-29

        'every second'   => '* * * * * *',
        'every 1 second' => '* * * * * *',
        'every minute'   => '* * * * *',
        'every 1 minute' => '* * * * *',
        'every hour'   => '0 * * * *',
        'every 1 hour' => '0 * * * *',
        'every day'   => '0 0 * * *',
        'every 1 day' => '0 0 * * *',
        'every week'   => '0 0 * * 0',
        'every 1 week' => '0 0 * * 0',
        'every month'   => '0 0 1 * *',
        'every 1 month' => '0 0 1 * *',
        'every year'   => '0 0 1 1 *',
        'every 1 year' => '0 0 1 1 *',
          #
          # gh-37
          #
        'every minute at second 10' => '10 * * * * *',
        'every minute at second 10 and 40' => '10,40 * * * * *',
        'every minute at secs 10 and 40' => '10,40 * * * * *',
        'every hour at min 11' => '11 * * * *',
        'every day at 18:22' => '22 18 * * *',
        'every week on monday 18:23' => '23 18 * * 1',
        'every monday 18:24' => '24 18 * * 1',
        'every month at 19:10' => '10 19 1 * *',
        'every year at 20:10' => '10 20 1 1 *',

        'every day at zero dark twenty' => '20 0 * * *',
        'every day at one dark fifty' => '50 1 * * *',
        #'every day at oh dark fourty' => '40 0 * * *',
        'every day at noon' => '0 12 * * *',
        'every day at midnight' => '0 0 * * *',

        'every 2 days' => '0 0 */2 * *',
        'every 2 days at 17:00' => '0 17 */2 * *',
        'every 2 months' => '0 0 1 */2 *',

        'every day from the 25th to the last' => '0 0 25-L * *',
        'every day at noon from the 25th to the last' => '0 12 25-L * *',
        'from the 25th to the last' => '0 0 25-L * *',
        'from the 25th to the last, at noon and midnight' => '0 0,12 25-L * *',
          #
          # gh-45

        'every weekday 8am to 5pm' => '0 8-17 * * 1-5',
        'every weekday 8am to 5pm on the hour' => '0 8-17 * * 1-5',
        'every weekday 8am to 5pm on the minute' => '* 8-16 * * 1-5',
        'every weekday 8am to 5pm on minute 10 and 30' => '10,30 8-16 * * 1-5',
        'every hour, 8am to 5pm' => '0 8-17 * * *',
        'every hour, from 8am to 5pm' => '0 8-17 * * *',
        'every minute, 8am to 5pm' => '* 8-16 * * *',
        'every minute from 8am to 5pm' => '* 8-16 * * *',
          #
          # gh-44

        # minute hour day-of-month month day-of-week

      }.each do |nat, cron|

        it "parses #{nat.inspect} into #{cron.inspect}" do

          c = Fugit::Nat.parse(nat)
#File.open('out.rb', 'ab') { |f| f.puts("\n#{nat.inspect}\n  #{c.inspect}") }
#p c
#expect(c).not_to eq(nil)

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

    it 'returns nil if it cannot parse' do

      expect(Fugit::Nat.parse(true)).to eq(nil)
      expect(Fugit::Nat.parse('nada')).to eq(nil)
    end

    it 'rejects strings that cannot be turned into crons' do

      expect(Fugit::Nat.parse('every 2 years')).to eq(nil)
      expect(Fugit::Nat.parse('every 2 weeks')).to eq(nil)
    end
  end

  describe '.do_parse' do

    it 'fails if it cannot parse' do

      expect { Fugit::Nat.do_parse(true) }.to raise_error(ArgumentError)
      expect { Fugit::Nat.do_parse('nada') }.to raise_error(ArgumentError)
    end
  end
end

