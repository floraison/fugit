
# fugit

[![Build Status](https://secure.travis-ci.org/floraison/fugit.svg)](http://travis-ci.org/floraison/fugit)
[![Gem Version](https://badge.fury.io/rb/fugit.svg)](http://badge.fury.io/rb/fugit)

Time tools for [flor](https://github.com/floraison/flor) and the floraison group.

It uses [et-orbi](https://github.com/floraison/et-orbi) to represent time instances and [raabro](https://github.com/floraison/raabro) as a basis for its parsers.

Fugit is a core dependency of [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) 3.5.x.


## Related projects

### Sister projects

The intersection of those two projects is where fugit is born:

* [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) - a cron/at/in/every/interval in-process scheduler, in fact, it's the father project to this fugit project
* [flor](https://github.com/floraison/flor) - a Ruby workflow engine, fugit provides the foundation for its time scheduling capabilities

### Similar, sometimes overlapping projects

* [chronic](https://github.com/mojombo/chronic) - a pure Ruby natural language date parser
* [parse-cron](https://github.com/siebertm/parse-cron) - parses cron expressions and calculates the next occurrence after a given date
* [ice_cube](https://github.com/seejohnrun/ice_cube) - Ruby date recurrence library
* [ISO8601](https://github.com/arnau/ISO8601) - Ruby parser to work with ISO8601 dateTimes and durations
* ...

### Projects using fugit

* [arask](https://github.com/Ebbe/arask) - "Automatic RAils taSKs" uses fugit to parse cron strings
* [sideqik-cron](https://github.com/ondrejbartas/sidekiq-cron) - recent versions of Sideqik-Cron use fugit to parse cron strings
* [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) -
* [flor](https://github.com/floraison/flor) - used in the [cron](https://github.com/floraison/flor/blob/master/doc/procedures/cron.md) procedure
* ...


## `Fugit.parse(s)`

The simplest way to use fugit is via `Fugit.parse(s)`.

```ruby
require 'fugit'

Fugit.parse('0 0 1 jan *').class         # ==> ::Fugit::Cron
Fugit.parse('12y12M').class              # ==> ::Fugit::Duration

Fugit.parse('2017-12-12').class          # ==> ::EtOrbi::EoTime
Fugit.parse('2017-12-12 UTC').class      # ==> ::EtOrbi::EoTime

Fugit.parse('every day at noon').class   # ==> ::Fugit::Cron
```

## `Fugit::Cron`

A class `Fugit::Cron` to parse cron strings and then `#next_time` and `#previous_time` to compute the next or the previous occurrence respectively.

There is also a `#brute_frequency` method which returns an array `[ shortest delta, longest delta, occurrence count ]` where delta is the time between two occurrences.

```ruby
require 'fugit'

c = Fugit::Cron.parse('0 0 * *  sun')
  # or
c = Fugit::Cron.new('0 0 * *  sun')

p Time.now  # => 2017-01-03 09:53:27 +0900

p c.next_time      # => 2017-01-08 00:00:00 +0900
p c.previous_time  # => 2017-01-01 00:00:00 +0900

p c.brute_frequency  # => [ 604800, 604800, 53 ]
                     #    [ delta min, delta max, occurrence count ]
p c.rough_frequency  # => 7 * 24 * 3600 (7d rough frequency)

p c.match?(Time.parse('2017-08-06'))  # => true
p c.match?(Time.parse('2017-08-07'))  # => false
p c.match?('2017-08-06')              # => true
p c.match?('2017-08-06 12:00')        # => false
```

Example of cron strings understood by fugit:
```ruby
'5 0 * * *'         # 5 minutes after midnight, every day
'15 14 1 * *'       # at 1415 on the 1st of every month
'0 22 * * 1-5'      # at 2200 on weekdays
'0 22 * * mon-fri'  # idem
'23 0-23/2 * * *'   # 23 minutes after 00:00, 02:00, 04:00, ...

'@yearly'    # turns into '0 0 1 1 *'
'@monthly'   # turns into '0 0 1 * *'
'@weekly'    # turns into '0 0 * * 0'
'@daily'     # turns into '0 0 * * *'
'@midnight'  # turns into '0 0 * * *'
'@hourly'    # turns into '0 * * * *'

'0 0 L * *'     # last day of month at 00:00
'0 0 last * *'  # idem
'0 0 -7-L * *'  # from the seventh to last to the last day of month at 00:00

# and more...
```

## `Fugit::Duration`

A class `Fugit::Duration` to parse duration strings (vanilla [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) ones and [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) ones).

Provides duration arithmetic tools.

```ruby
require 'fugit'

d = Fugit::Duration.parse('1y2M1d4h')

p d.to_plain_s  # => "1Y2M1D4h"
p d.to_iso_s    # => "P1Y2M1DT4H" ISO 8601 duration
p d.to_long_s   # => "1 year, 2 months, 1 day, and 4 hours"

d += Fugit::Duration.parse('1y1h')

p d.to_long_s  # => "2 years, 2 months, 1 day, and 5 hours"

d += 3600

p d.to_plain_s  # => "2Y2M1D5h3600s"
```

The `to_*_s` methods are also available as class methods:
```
p Fugit::Duration.to_plain_s('1y2M1d4h')
  # => "1Y2M1D4h"
p Fugit::Duration.to_iso_s('1y2M1d4h')
  # => "P1Y2M1DT4H" ISO 8601 duration
p Fugit::Duration.to_long_s('1y2M1d4h')
  # => "1 year, 2 months, 1 day, and 4 hours"
```

## `Fugit::At`

Points in time are parsed and given back as EtOrbi::EoTime instances.

```ruby
Fugit::At.parse('2017-12-12').to_s
  # ==> "2017-12-12 00:00:00 +0900" (at least here in Hiroshima)

Fugit::At.parse('2017-12-12 12:00:00 America/New_York').to_s
  # ==> "2017-12-12 12:00:00 -0500"
```

Directly with `Fugit.parse_at(s)` is OK too:
```ruby
Fugit.parse_at('2017-12-12 12:00:00 America/New_York').to_s
  # ==> "2017-12-12 12:00:00 -0500"
```

Directly with `Fugit.parse(s)` is OK too:
```ruby
Fugit.parse('2017-12-12 12:00:00 America/New_York').to_s
  # ==> "2017-12-12 12:00:00 -0500"
```

## `Fugit::Nat`

Fugit understand some kind of "natural" language:

For example, those "every" get turned into `Fugit::Cron` instances:
```ruby
Fugit::Nat.parse('every day at five')                         # ==> '0 5 * * *'
Fugit::Nat.parse('every weekday at five')                     # ==> '0 5 * * 1,2,3,4,5'
Fugit::Nat.parse('every day at 5 pm')                         # ==> '0 17 * * *'
Fugit::Nat.parse('every tuesday at 5 pm')                     # ==> '0 17 * * 2'
Fugit::Nat.parse('every wed at 5 pm')                         # ==> '0 17 * * 3'
Fugit::Nat.parse('every day at 16:30')                        # ==> '30 16 * * *'
Fugit::Nat.parse('every day at noon')                         # ==> '0 12 * * *'
Fugit::Nat.parse('every day at midnight')                     # ==> '0 0 * * *'
Fugit::Nat.parse('every tuesday and monday at 5pm')           # ==> '0 17 * * 1,2'
Fugit::Nat.parse('every wed or Monday at 5pm and 11')         # ==> '0 11,17 * * 1,3'
Fugit::Nat.parse('every day at 5 pm on America/Los_Angeles')  # ==> '0 17 * * * America/Los_Angeles'
Fugit::Nat.parse('every day at 6 pm in Asia/Tokyo')           # ==> '0 18 * * * Asia/Tokyo'
Fugit::Nat.parse('every 3 hours')                             # ==> '0 */3 * * *'
Fugit::Nat.parse('every 4 months')                            # ==> '0 0 1 */4 *'
Fugit::Nat.parse('every 5 minutes')                           # ==> '*/5 * * * *'
Fugit::Nat.parse('every 15s')                                 # ==> '*/15 * * * * *'
```

Directly with `Fugit.parse(s)` is OK too:
```ruby
Fugit.parse('every day at five')  # ==> Fugit::Cron instance '0 5 * * *'
```


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

