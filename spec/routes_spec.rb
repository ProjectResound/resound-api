require 'rails_helper'

RSpec.describe 'Routes', type: :routing do
  it 'routes audio searches' do
    expect(get: "/api/v1/audios/search?q=some-searchquery").to route_to(
                                                                     :controller => "api/v1/audios",
                                                                     :action => "search",
                                                                     :q => "some-searchquery")
  end
end
