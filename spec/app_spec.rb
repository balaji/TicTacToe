require File.expand_path '../spec_helper.rb', __FILE__

def create_new_game
  post '/new_game'
  follow_redirect!
  last_request.url.split('/').last
end

describe 'The Tic-Tac-Toe App' do
  it 'should load the home page' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'should create a new game' do
    post '/new_game'
    follow_redirect!

    expect(last_request.url).to match(/http:\/\/example.org\/(\w{8}(-\w{4}){3}-\w{12}?)/)
    expect(last_response).to be_ok
  end

  it 'should allow a valid block to be marked.' do
    game_id = create_new_game

    post "/#{game_id}/mark.json", row: 0, column: 0

    expect(last_response).to be_ok
    actual_response = JSON.parse(last_response.body)

    expect(actual_response['grid']).to eq([%w(X - -), %w(- - -), %w(- - -)])
  end

  it 'should fail when marking the same block cannot be marked twice' do
    game_id = create_new_game

    post "/#{game_id}/mark.json", row: 0, column: 0
    post "/#{game_id}/mark.json", row: 0, column: 0

    expect(last_response.status).to eq(500)
  end

  it 'should win the game diagonally' do
    game_id = create_new_game

    post "/#{game_id}/mark.json", row: 0, column: 0 # player 1
    post "/#{game_id}/mark.json", row: 0, column: 1 # player 2
    post "/#{game_id}/mark.json", row: 1, column: 1 # player 1
    post "/#{game_id}/mark.json", row: 1, column: 0 # player 2
    post "/#{game_id}/mark.json", row: 2, column: 2 # player 1

    expect(last_response).to be_ok
    actual_response = JSON.parse(last_response.body)

    expect(actual_response['grid']).to eq([%w(X O -), %w(O X -), %w(- - X)])
    expect(actual_response['game_status']).to eq('won')
  end

  it 'should win the game horizontally' do
    game_id = create_new_game

    post "/#{game_id}/mark.json", row: 0, column: 0 # player 1
    post "/#{game_id}/mark.json", row: 1, column: 0 # player 2
    post "/#{game_id}/mark.json", row: 0, column: 1 # player 1
    post "/#{game_id}/mark.json", row: 1, column: 1 # player 2
    post "/#{game_id}/mark.json", row: 0, column: 2 # player 1

    expect(last_response).to be_ok
    actual_response = JSON.parse(last_response.body)

    expect(actual_response['grid']).to eq([%w(X X X), %w(O O -), %w(- - -)])
    expect(actual_response['game_status']).to eq('won')
  end

  it 'should win the game vertically' do
    game_id = create_new_game

    post "/#{game_id}/mark.json", row: 0, column: 0 # player 1
    post "/#{game_id}/mark.json", row: 0, column: 1 # player 2
    post "/#{game_id}/mark.json", row: 1, column: 0 # player 1
    post "/#{game_id}/mark.json", row: 1, column: 1 # player 2
    post "/#{game_id}/mark.json", row: 2, column: 0 # player 1

    expect(last_response).to be_ok
    actual_response = JSON.parse(last_response.body)

    expect(actual_response['grid']).to eq([%w(X O -), %w(X O -), %w(X - -)])
    expect(actual_response['game_status']).to eq('won')
  end

  it 'should fail when a move is attempted after a win' do
    game_id = create_new_game

    post "/#{game_id}/mark.json", row: 0, column: 0 # player 1
    post "/#{game_id}/mark.json", row: 0, column: 1 # player 2
    post "/#{game_id}/mark.json", row: 1, column: 0 # player 1
    post "/#{game_id}/mark.json", row: 1, column: 1 # player 2
    post "/#{game_id}/mark.json", row: 2, column: 0 # player 1 wins here...
    post "/#{game_id}/mark.json", row: 2, column: 1 # invalid attempt.

    expect(last_response.status).to eq(500)
  end

  it 'should draw the match when the grid is full' do
    game_id = create_new_game
    post "/#{game_id}/mark.json", row: 0, column: 0 # player 1
    post "/#{game_id}/mark.json", row: 0, column: 1 # player 2
    post "/#{game_id}/mark.json", row: 0, column: 2 # player 1
    post "/#{game_id}/mark.json", row: 1, column: 0 # player 2
    post "/#{game_id}/mark.json", row: 1, column: 2 # player 1
    post "/#{game_id}/mark.json", row: 1, column: 1 # player 2
    post "/#{game_id}/mark.json", row: 2, column: 1 # player 1
    post "/#{game_id}/mark.json", row: 2, column: 2 # player 2
    actual_response = JSON.parse(last_response.body)
    expect(actual_response['game_status']).to eq('in_progress') # game still in progress.

    post "/#{game_id}/mark.json", row: 2, column: 0 # player 1. last move, this draws the game.

    expect(last_response).to be_ok
    actual_response = JSON.parse(last_response.body)

    expect(actual_response['grid']).to eq([%w(X O X), %w(O O X), %w(X X O)])
    expect(actual_response['game_status']).to eq('draw')
  end

end