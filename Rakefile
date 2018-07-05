# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'resque/tasks'
require 'resque/scheduler/tasks'

Rails.application.load_tasks

task 'resque:setup' => :environment

namespace :resque do
  task :setup_schedule => :setup do
    require 'resque-scheduler'
    Resque.schedule = YAML.load_file('config/resque_schedule.yml')
  end

  task :scheduler => :setup_schedule
end
