web:    bundle exec rails s -p 3000 -b '0.0.0.0'
worker: bundle exec rake resque:work QUEUE=* & bundle exec rake resque:scheduler