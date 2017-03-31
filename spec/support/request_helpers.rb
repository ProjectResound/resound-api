module Requests
  module JsonHelpers
    def json
      return if !response.body
      JSON.parse(response.body)
    end
  end
end