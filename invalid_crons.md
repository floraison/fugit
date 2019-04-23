
## invalid_crons.md

* gh-20 @nulian `"* * 31 11 *"` aka "every 31th of November"

The easy way out would be to run `#next_time` right after instantiation to determine if the cron is valid. But that has a cost (around 0.2s for those worst cases).

`#parse_and_validate('* * 31 11 *')` maybe?

Another way would be to have some smart validation. But that's almost like duplicating `#next_time`.

Note that https://crontab.gury does consider `"* * 31 11 *"`. Crond probably never schedules it, silently. (Up to the tools that use fugit then).

