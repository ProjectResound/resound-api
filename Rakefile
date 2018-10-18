# frozen_string_literal: true

require_relative 'config/application'
require 'resque/tasks'

Rails.application.load_tasks

task 'resque:setup' => :environment
