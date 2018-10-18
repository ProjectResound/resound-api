# frozen_string_literal: true

Resque.redis = Redis.new(host: 'redis', port: 6379) if Rails.env == 'production'
