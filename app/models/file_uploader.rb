class FileUploader < Shrine
  plugin :determine_mime_type

  Attacher.validate do
    validate_mime_type_inclusion ['audio/flac', 'audio/x-flac']
  end
end