# frozen_string_literal: true

class AudioSerializer < ActiveModel::Serializer
  CDN_HOST = ENV['RESOUND_API_CDN'].present? ? ENV['RESOUND_API_CDN'] : false
  attributes :id,
             :title,
             :filename,
             :duration,
             :created_at,
             :tags,
             :contributors,
             :uploader,
             :files

  def uploader
    user = User.find_by_uid(object.uploader_id)
    return user.nickname if user

    'deleted user'
  end

  def files
    return unless object.file

    h = {}
    object.file.each_pair do |format, f|
      h[format] = if CDN_HOST
                    f.url(host: CDN_HOST)
                  else
                    f.url
                  end
    end
    h
  end
end
