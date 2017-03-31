class Audio < Sequel::Model
  include FileUploader[:file]
  include ActiveModel::ForbiddenAttributesProtection

  plugin :validation_helpers

  def validate
    super
    validates_presence [:title]
    validates_min_length 4, :title
  end

  def self.by_filename(filename)
    where(filename: filename)
  end
end

Audio.finder :by_filename
Audio.set_allowed_columns :title, :filename