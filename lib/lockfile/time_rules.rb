module LockFile
  module TimeRules

    MINUTES_IN_HOUR = 60
    SECONDS_IN_MINUTE = 60

    def calc_expire_date creation_date, rule
      minutes = parse_time rule
      Time.at(SECONDS_IN_MINUTE * minutes + creation_date.to_i)
    end

    def parse_time rule
      hours = minutes = 0

      hours = /(\d+) hour/.match(rule)[0].to_i if rule =~ /hour/
      minutes = /(\d+) minute/.match(rule)[0].to_i if rule =~ /minute/

      hours * MINUTES_IN_HOUR + minutes
    end
  end
end