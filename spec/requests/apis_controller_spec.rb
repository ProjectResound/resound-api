describe Api do
  it 'returns 200' do
    get '/api'
    expect(response).to have_http_status(200)
  end
end