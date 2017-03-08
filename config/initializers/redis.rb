if Rails.env == 'production'
  Resque.redis = Redis.new( host: 'redis', port: 6379)
end