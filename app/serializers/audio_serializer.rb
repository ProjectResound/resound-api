class AudioSerializer < ActiveModel::Serializer
  require 'duration_parser'

  attributes :title, :filename, :duration, :created_at

  def duration
    DurationParser.to_hhmmss(object.duration)
  end
end