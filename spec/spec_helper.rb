
#
# Specifying fugit
#
# Sun Jan  1 12:09:21 JST 2017  Ishinomaki
#

require 'pp'
#require 'ostruct'

require 'fugit'


#def jruby?
#
#  !! RUBY_PLATFORM.match(/java/)
#end


def in_zone(zone_name, &block)

  prev_tz = ENV['TZ']
  ENV['TZ'] = zone_name if zone_name

  block.call

ensure

  ENV['TZ'] = prev_tz
end

