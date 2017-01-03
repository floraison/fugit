
require 'fugit'

d = Fugit::Duration.parse('1y2M1d4h')

p d.to_plain_s  # => "1Y2M1D4h"
p d.to_iso_s    # => "P1Y2M1DT4H" ISO 8601 duration
p d.to_long_s   # => "1 year, 2 months, 1 day, and 4 hours"

d += Fugit::Duration.parse('1y1h')

p d.to_long_s  # => "2 years, 2 months, 1 day, and 5 hours"

d += 3600

p d.to_plain_s  # => "2Y2M1D5h3600s"

