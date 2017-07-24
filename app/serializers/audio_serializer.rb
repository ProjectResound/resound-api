class AudioSerializer < ActiveModel::Serializer
  require 'duration_parser'

  attributes :id, :title, :filename, :duration, :created_at, :tags, :contributors, :uploader

  def uploader
    if user = User.find_by_uid(object.uploader_id)
      return user.nickname
    end
  end
end