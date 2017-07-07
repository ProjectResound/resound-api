source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'active_model_serializers', '~> 0.10.0'


gem 'pg', '~> 0.19.0'

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
gem 'sinatra', github: 'sinatra/sinatra', branch: 'master'
gem 'resque', '~> 1.27.0'
gem 'resque_solo', '~> 0.3.0'
gem 'scenic', '~> 1.4.0'
gem 'textacular', '~> 4.0.1'
gem 'jwt', '~> 1.5.6'
gem 'acts_as_paranoid', git: 'git@github.com:shanebonham/acts_as_paranoid.git'
gem 'kaminari', '~> 0.14.1'

# Use ~> 2.0 because after 2.0, the constant is named AWS, not Aws. Shrine wants Aws.
gem 'aws-sdk', '~> 2.1'
# file uploading
gem 'shrine', '~> 2.5.0'

gem 'foreman', '~> 0.84.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_girl_rails', '~> 4.8.0'
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

