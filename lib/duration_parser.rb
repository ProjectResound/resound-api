module DurationParser

  module_function

  def to_seconds(str)
    Time.parse(str).seconds_since_midnight
  end

  def to_hhmmss(decimal)
    if decimal
      Time.at(decimal).utc.strftime("%H:%M:%S")
    else
      nil
    end
  end
end