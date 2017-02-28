require 'shrine'
require 'shrine/storage/file_system'
require 'shrine/storage/s3'

Shrine.plugin :sequel
Shrine.plugin :logging, logger: Rails.logger
Shrine.plugin :validation_helpers

storage_location = if Rails.env.production?
                     Shrine::Storage::S3.new(
                         access_key_id: Rails.application.secrets.aws_access_key_id,
                         secret_access_key: Rails.application.secrets.aws_secret_access_key,
                         region: Rails.application.secrets.aws_region,
                         bucket: Rails.application.secrets.aws_bucket
                     )
                   else
                     Shrine::Storage::FileSystem.new('public', prefix: 'uploads/store')
                   end

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
  store: storage_location
}