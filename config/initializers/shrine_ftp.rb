require 'shrine'
require 'shrine/storage/file_system'
require 'shrine/storage/ftp'

Shrine.plugin :activerecord
Shrine.plugin :logging, logger: Rails.logger
Shrine.plugin :validation_helpers

storage_location = Shrine::Storage::Ftp.new(
    host: ENV['RESOUND_FTP_HOST'],
    user: ENV['RESOUND_FTP_USER'],
    password: ENV['RESOUND_FTP_PASSWD'],
    dir: ENV['RESOUND_FTP_DIR'],
    prefix: ENV['RESOUND_FTP_PREFIX']
)

Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
    store: storage_location
}