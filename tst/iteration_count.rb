
require 'fugit'

# For gh-15
#
# Conjuring up "worst-case" crons and determining how many iteration
# to compute #previous_time / #next_time to get an idea
# for a max iteration count that is minimal and does not prevent
# computing the worst-case crons.

# min hou dom mon dow
# sec min hou dom mon dow

c = Fugit.parse('0 9 29 feb *')
p c.next_time(Time.parse('2016-03-01')).iso8601
  # 167 iterations are necessary

c = Fugit.parse('*/10 0 9 29 feb *')
p c.next_time(Time.parse('2016-03-01')).iso8601
  # 167 iterations are necessary


#c = Fugit.parse('0 9 29 feb sun')
#c.next_time
  #
  # is tempting, but
  #
  # > Note: The day of a command's execution can be specified by two fields --
  # > day of month, and day of week.  If both fields are restricted (ie,
  # > are not *), the command will be run when either field matches the
  # > current time.  For example, ``30 4 1,15 * 5'' would cause a command to
  # > be run at 4:30 am on the 1st and 15th of each month, plus every Friday.
  #
  # it's thus no "next time the 29th of February falls on a Sunday",
  # it's "next 29th of February or next Sunday of February"


# 167 iterations? Let's put the breaker at 1024 :-)

