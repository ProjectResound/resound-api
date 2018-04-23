# frozen_string_literal: true

Resque.redis = Redis.new(url: ENV['REDIS_URL']) if Rails.env == 'production'
