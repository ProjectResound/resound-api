# frozen_string_literal: true

Resque.inline = ENV['RAILS_ENV'] == 'development'
