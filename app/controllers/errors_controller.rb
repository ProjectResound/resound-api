# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    render status: 404
  rescue ActionController::UnknownFormat
    render status: 404, text: 'uh oh, not found'
  end
end
