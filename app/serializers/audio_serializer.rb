class AudioSerializer < ActiveModel::Serializer
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
  end

  def files
    return unless object.file

    h = {}
    object.file.each_pair do |format, f|
      h[format] = f.url
    end
    h
  end
end