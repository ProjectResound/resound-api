class FilesChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'files'
  end
end