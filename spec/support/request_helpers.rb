# frozen_string_literal: true

module Requests
  module JsonHelpers
    def json
      return unless response.body

      JSON.parse(response.body)
    end
  end
end
