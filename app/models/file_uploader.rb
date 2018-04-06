class FileUploader < Shrine
  plugin :versions
  plugin :parallelize
  plugin :default_url_options, store: {public: true}

  def generate_location(io, context)
    version = context[:version].to_s
    if context[:record].file_attacher.stored? || context[:record].file_attacher.cached?
      file_data_version = JSON.parse(context[:record].file_data)[version]
      if file_data_version && url = file_data_version["id"]
        return url
      end
    end
    super
  end
end
