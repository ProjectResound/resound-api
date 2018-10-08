if Rails.env == 'production'
  Resque.redis = Redis.new(url: ENV['REDIS_URL'])
end
