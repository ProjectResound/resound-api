store_manage_config = Rails.application.config_for(:store_manage)

Rails.application.configure do
  config.store_manage = ActiveSupport::OrderedOptions.new
  config.store_manage.ffmpeg_path = store_manage_config["ffmpeg_path"]
end
