require 'rubygems'
require 'sinatra'
require 'json'
require 'data_mapper'

require_relative 'models/game'
require_relative 'lib/tic_tac_toe'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/game.db")
DataMapper.finalize
Game.auto_upgrade!

get '/' do
  erb :index
end

get '/:id' do
  game = Game.get(params[:id])
  if game != nil
    erb :game, locals: {game_state: JSON.parse(game.game_state)}
  else
    status 404
  end
end

post '/new_game' do
  id = SecureRandom.uuid

  state = {
      grid: [%w(- - -), %w(- - -), %w(- - -)],
      next_turn: :a,
      game_status: TicTacToe::Game::Status::IN_PROGRESS
  }.to_json

  game = Game.new(id: id, game_state: state)
  game.save!

  redirect to("/#{id}")
end

post '/:game_id/mark.json' do
  begin
    content_type :json

    row = params[:row].to_i
    column = params[:column].to_i
    game = Game.get(params[:game_id])

    new_state = TicTacToe::Game.mark(row, column, JSON.parse(game.game_state))
    game.update!(game_state: new_state.to_json)
    new_state.to_json
  rescue
    status 500
  end
end

not_found do
  erb :missing
end