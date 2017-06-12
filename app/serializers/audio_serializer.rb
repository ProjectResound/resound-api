class AudioSerializer < ActiveModel::Serializer
  require 'duration_parser'

  attributes :title, :filename, :duration, :created_at, :tags
end