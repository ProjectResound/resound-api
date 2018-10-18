# frozen_string_literal: true

describe do
  it 'returns 200' do
    get '/'

    expect(response).to have_http_status(200)
  end

  it 'returns 404' do
    get '/sometrash'

    expect(response).to have_http_status(404)
  end
end
