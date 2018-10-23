require 'shrine'
require 'shrine/storage/file_system'
require 'shrine/storage/s3'

Shrine.plugin :activerecord
Shrine.plugin :logging, logger: Rails.logger
Shrine.plugin :validation_helpers
Shrine.plugin :dynamic_storage

Shrine.storages = {}

if Rails.env.production? || ENV['UPLOAD_TO_S3']
  shrine_options = {
    access_key_id: Rails.application.secrets.aws_access_key_id,
    secret_access_key: Rails.application.secrets.aws_secret_access_key,
    region: Rails.application.secrets.aws_region,
    upload_options: { acl: 'public-read' }
  }

  shrine_options.merge!(
    { signature_version: Rails.application.secrets.s3_signature_version }
  ) if Rails.application.secrets.s3_signature_version

  shrine_options.merge!(
    { endpoint: Rails.application.secrets.s3_endpoint }
  ) if Rails.application.secrets.s3_endpoint

  if ENV['S3_MULTI_TENANCY']
    Shrine.plugin :default_storage, store: ->(record, name) do
      tenant_name = Apartment::Tenant.current
      :"store_#{tenant_name}"
    end

    Shrine.storage /store_(\w+)/ do |match|
      bucket_name = "#{match[1]}-resound-store"
      Shrine::Storage::S3.new(bucket: bucket_name, **shrine_options)
    end
  else
    Shrine.storages[:store] = Shrine::Storage::S3.new(
      bucket: Rails.application.secrets.aws_bucket,
      **shrine_options
    )
  end
else
  Shrine.storages[:store] = Shrine::Storage::FileSystem.new('public', prefix: 'uploads/store')
end

Shrine.storages[:cache] = Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache')
