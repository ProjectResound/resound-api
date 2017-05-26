module DurationParser

  module_function

  def to_seconds(str)
    Time.parse(str).seconds_since_midnight
  end
end