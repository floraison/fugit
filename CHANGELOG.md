
# CHANGELOG.md


## fugit 1.3.3 released 2019-08-29

* Fix Cron#match?(t) with respect to the cron's timezone, gh-31


## fugit 1.3.2 released 2019-08-14

* Allow for "* 0-24 * * *", gh-30


## fugit 1.3.1 released 2019-07-27

* Fix nat parsing for 'every day at 18:00 and 18:15', gh-29
*   and for 'every day at 18:00, 18:15, 20:00, and 20:15', gh-29
* Ensure multi: :fail doesn't force into multi, gh-28
* Fix nat parsing for 'every Fri-Sun at 18:00', gh-27


## fugit 1.3.0 released 2019-07-21

* Introduce Fugit.parse_nat('every day at 18:00 and 19:15', multi: true)
* Rework AM/PM parsing


## fugit 1.2.3 released 2019-07-16

* Allow for "from Monday to Friday at 19:22", gh-25
* Allow for "every Monday to Friday at 18:20", gh-25
* Allow for "every day at 18:00 and 20:00", gh-24


## fugit 1.2.2 released 2019-06-21

* Fix Fugit.parse vs "every 15 minutes", gh-22


## fugit 1.2.1 released 2019-05-04

* Return nil when parsing a cron with February 30 and friend, gh-21


## fugit 1.2.0 released 2019-04-22

* Accept "/15 * * * *" et al, gh-19 and resque/resque-scheduler#649
* Stop fooling around and stick to https://semver.org


## fugit 1.1.10 released 2019-04-12

* Implement `"0 9 * * sun%2+1"`
* Simplify cron parser


## fugit 1.1.9  released 2019-03-26

* Fix cron `"0 9 29 feb *"` endless loop, gh-18
* Fix cron endless loop when #previous_time(t) and t matches, gh-15
* Simplify Cron #next_time / #previous_time breaker system, gh-15
  Thanks @godfat and @conet


## fugit 1.1.8  released 2019-01-17

* Ensure Cron#next_time happens in cron's time zone, gh-12


## fugit 1.1.7  released 2019-01-15

* Add breaker to Cron #next_time / #previous_time, gh-13
* Prevent 0 as a month in crons, gh-10
* Prevent 0 as a day of month in crons, gh-10


## fugit 1.1.6  released 2018-09-05

* Ensure `Etc/GMT-11` and all Olson timezone names are recognized
  in cron and nat strings, gh-9


## fugit 1.1.5  released 2018-07-30

* Add Fugit::Cron#rough_frequency (for https://github.com/jmettraux/rufus-scheduler/pull/276)


## fugit 1.1.4  released 2018-07-20

* Add duration support for Fugit::Nat (@cristianbica gh-7)
* Fix Duration not correctly parsing minutes and seconds long format (@cristianbica gh-7)
* Add timezone support for Fugit::Nat (@cristianbica gh-7)
* Use timezone name when converting a Fugit::Cron to cron string (@cristianbica gh-7)


## fugit 1.1.3  released 2018-06-21

* Silenced Ruby warnings (Utilum in gh-4)


## fugit 1.1.2  released 2018-06-20

* Added Fugit::Cron#seconds (Tero Marttila in gh-3)


## fugit 1.1.1  released 2018-05-04

* Depend on et-orbi 1.1.1 and better


## fugit 1.1.0  released 2018-03-27

* Travel in Cron zone in #next_time and #previous_time, return from zone
* Parse and store timezone in Fugit::Cron
* Introduce Fugit::Duration#deflate month: d / year: d
* Introduce Fugit::Duration#drop_seconds
* Alias Fugit::Duration#to_h to Fugit::Duration#h
* Introduce to_rufus_s (1y2M3d) vs to_plain_s (1Y2M3D)
* Ensure Duration#deflate preserves at least `{ sec: 0 }`
* Stringify 0 seconds as "0s"
* Ignore "-5" and "-5.", only accept "-5s" and "-5.s"
* Introduce "signed durations", "-1Y+2Y-3m"
* Ensure `1.0d1.0w1.0d` gets parsed correctly
* Ensure Fugit::Cron.next_time returns plain seconds (.0, not .1234...)
* Introduce Fugit::Frequency for cron


## fugit 1.0.0  released 2017-06-23

* Introduce et-orbi dependency (1.0.5 or better)
* Wire #deflate into Duration.to_long_s / .to_iso_s / .to_plain_s


## fugit 0.9.6  released 2017-05-24

* Provide Duration.to_long_s / .to_iso_s / .to_plain_s at class level


## fugit 0.9.5  released 2017-01-07

* Implement Fugit.determine_type(s)
* Rename core.rb to parse.rb


## fugit 0.9.4  released 2017-01-06

* Accept cron strings with seconds


## fugit 0.9.3  released 2017-01-05

* First version of Fugit::Nat


## fugit 0.9.2  released 2017-01-04

* Accept decimal places for duration seconds
* Alias Fugit .parse_in to .parse_duration


## fugit 0.9.1  released 2017-01-03

* Implement Fugit::Duration #inflate and #deflate
* Bring in Fugit::Duration
* Implement Fugit .parse, .parse_at and .parse_cron


## fugit 0.9.0  released 2017-01-03

* Initial release

