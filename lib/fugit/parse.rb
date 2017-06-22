
module Fugit

  def self.parse_at(s)

    ::EtOrbi.make_time(s) rescue nil
  end

  def self.do_parse_at(s)

    ::EtOrbi.make_time(s)
  end

  def self.parse_cron(s); ::Fugit::Cron.parse(s); end
  def self.parse_duration(s); ::Fugit::Duration.parse(s); end
  def self.parse_in(s); parse_duration(s); end
  def self.parse_nat(s); ::Fugit::Nat.parse(s); end

  def self.do_parse_cron(s); ::Fugit::Cron.do_parse(s); end
  def self.do_parse_duration(s); ::Fugit::Duration.do_parse(s); end
  def self.do_parse_in(s); do_parse_duration(s); end
  def self.do_parse_nat(s); ::Fugit::Nat.do_parse(s); end

  def self.parse(s, opts={})

    opts[:at] = opts[:in] if opts.has_key?(:in)

    (opts[:cron] != false && parse_cron(s)) ||
    (opts[:duration] != false && parse_duration(s)) ||
    (opts[:at] != false && parse_at(s)) ||
    (opts[:nat] != false && parse_nat(s)) ||
    nil
  end

  def self.do_parse(s, opts={})

    parse(s, opts) ||
    fail(ArgumentError.new("found no time information in #{s.inspect}"))
  end

  def self.determine_type(s)

    case self.parse(s)
    when ::Fugit::Cron then 'cron'
    when ::Fugit::Duration then 'in'
    when ::Time, ::EtOrbi::EoTime then 'at'
    else nil
    end
  end
end

