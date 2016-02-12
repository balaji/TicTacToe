require File.expand_path '../spec_helper.rb', __FILE__

describe 'The Tic-Tac-Toe App' do
  it 'loads the home page' do
    get '/'
    expect(last_response).to be_ok
  end
end