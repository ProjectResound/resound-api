# frozen_string_literal: true

class FileUploader < Shrine
  plugin :versions
  plugin :parallelize
  plugin :default_url_options, store: { public: true }
  plugin :determine_mime_type

  require 'securerandom'

  def generate_location(io, context)
    version = context[:version].to_s
    if context[:record].file_attacher.stored? ||
       context[:record].file_attacher.cached?
      file_data_version = JSON.parse(context[:record].file_data)[version]
      if file_data_version && (url = file_data_version['id'])
        return url
      end
    end
    if (filename = context[:metadata]) && context[:metadata]['filename']
      return "#{SecureRandom.hex(2)}_#{filename}"
    end

    super
  end
end
