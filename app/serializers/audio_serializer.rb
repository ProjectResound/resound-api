class AudioSerializer < ActiveModel::Serializer
  CDN_HOST = ENV["RESOUND_API_CDN"].present? || false
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
    if user = User.find_by_uid(object.uploader_id)
      return user.nickname
    end
    return 'deleted user'
  end

  def files
    return unless object.file

    h = {}
    object.file.each_pair do |format, f|
      if CDN_HOST
        h[format] = f.url(host: CDN_HOST)
      else
        h[format] = f.url
      end
    end
    h
  end
end