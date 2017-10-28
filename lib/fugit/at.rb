
module Fugit

  module At

    def self.parse(s)

      ::EtOrbi.make_time(s) rescue nil
    end

    def self.do_parse(s)

      ::EtOrbi.make_time(s)
    end
  end
end

