# frozen_string_literal: true

class DeleteOldFiles < ActiveJob::Base
  include Resque::Plugins::UniqueJob

  @queue = :low

  def perform
    file_system = Shrine.storages[:cache]
    file_system.clear!(older_than: 7.days.ago)
  end
end
