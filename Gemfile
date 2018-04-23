source 'https://rubygems.org'

ruby '~> 2.4.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
gem 'active_model_serializers', '~> 0.10.0'


gem 'pg', '~> 0.19.0'
# Uncomment the 'scenic' gem below if you're using postgresql
gem 'scenic', '~> 1.4.0'

# use mysql as the db
gem 'mysql2', '~> 0.4.10'

# Use Puma as the app server
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
gem 'redis-rails'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

gem 'responders', '~> 2.3.0'
gem 'sinatra', git: 'https://github.com/sinatra/sinatra', branch: 'master'
gem 'resque', '~> 1.27.0'
gem 'resque_solo', '~> 0.3.0'
gem 'textacular', '~> 4.0.1'
gem 'jwt', '~> 1.5.6'
gem 'acts_as_paranoid', git: 'https://github.com/shanebonham/acts_as_paranoid', branch: 'master'
gem 'kaminari', '~> 0.14.1'
gem 'shrine', '~> 2.11.0'

# Use ~> 2.0 because after 2.0, the constant is named AWS, not Aws. Shrine wants Aws.
gem 'aws-sdk', '~> 2.1'
gem 'streamio-ffmpeg', '~> 3.0'
gem 'honeybadger', '~> 3.1'
gem 'shrine-ftp'
gem 'rb-readline'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.5'
  gem "factory_bot_rails"
  gem 'dotenv-rails'
end

group :test do
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', require: false
end


group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rails-erd', '~> 1.5.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Multi-tenancy
gem 'apartment'
