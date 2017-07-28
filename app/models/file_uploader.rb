class FileUploader < Shrine
  plugin :versions
  plugin :parallelize
  plugin :default_url_options, store: {public: true}
end