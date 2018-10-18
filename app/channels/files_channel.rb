# frozen_string_literal: true

class FilesChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'FilesChannel'
  end
end
