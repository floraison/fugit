
#
# Specifying fugit
#
# Sun Jan  1 12:09:21 JST 2017  Ishinomaki
#

require 'pp'
require 'ostruct'

require 'chronic'
::Khronic = ::Chronic
Object.send(:remove_const, :Chronic)

require 'fugit'


module Helpers

  def jruby?; !! RUBY_PLATFORM.match(/java/); end
  def windows?; Gem.win_platform?; end


  def in_zone(zone_name, &block)

    prev_tz = ENV['TZ']
    ENV['TZ'] = zone_name if zone_name

    block.call

  ensure

    ENV['TZ'] = prev_tz
  end

  def in_active_support_zone(zone_name, &block)

    prev_tz = ENV['TZ']
    ENV['TZ'] = nil # else it takes over

    Time._zone = zone_name
    Time.module_eval do
      class << self
        def zone; @zone; end
      end
    end

    block.call

  ensure

    Time._zone = nil
    Time.module_eval do
      class << self
        undef_method :zone
      end
    end

    ENV['TZ'] = prev_tz
  end

  def require_chronic

    Object.const_set(:Chronic, Khronic)
  end

  def unrequire_chronic

    Object.send(:remove_const, :Chronic)
  end
end # Helpers

RSpec.configure do |c|

  c.alias_example_to(:they)
  c.alias_example_to(:so)
  c.include(Helpers)
end


  # A _bad_inc that doesn't progress, to test #next_time and
  # #previous_time loop breakers...
  #
class Fugit::Cron::TimeCursor
  def _bad_inc(i)
    @t = @t + 0
    self
  end
  alias _original_inc inc
end


  # Simulating ActiveSupport Time.zone
  #
class Time

  class << self

    # .zone itself is defined/undefined in the #in_active_support_zone
    # spec helper defined above

    attr_reader :_zone

    def _zone=(name)

      @zone =
        if name
          OpenStruct.new(tzinfo: ::TZInfo::Timezone.get(name))
        else
          nil
        end
    end
  end
end

