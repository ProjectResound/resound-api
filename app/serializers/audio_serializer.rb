class AudioSerializer < ActiveModel::Serializer
  require 'duration_parser'

  attributes :id, :title, :filename, :duration, :created_at, :tags, :contributors
end