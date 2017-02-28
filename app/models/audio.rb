class Audio < Sequel::Model
  include FileUploader[:file]
  include ActiveModel::ForbiddenAttributesProtection

  plugin :validation_helpers

  def validate
    super
    validates_presence [:title]
    validates_min_length 4, :title
  end
end
