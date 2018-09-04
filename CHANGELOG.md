
# CHANGELOG.md


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

