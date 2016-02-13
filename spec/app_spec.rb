require File.expand_path '../spec_helper.rb', __FILE__

describe 'The Tic-Tac-Toe App' do
  it 'loads the home page' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'creates a new game' do
    post '/new_game'
    follow_redirect!

    expect(last_request.url).to match(/http:\/\/example.org\/(\w{8}(-\w{4}){3}-\w{12}?)/)
    expect(last_response).to be_ok
  end
end