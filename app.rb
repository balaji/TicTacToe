require 'rubygems'
require 'sinatra'
require 'json'
require 'data_mapper'

require_relative 'models/game'
require_relative 'lib/tic_tac_toe'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/game.db")
DataMapper.finalize
Game.auto_upgrade!

get '/' do
  erb :index
end

get '/:id' do
  game = Game.get(params[:id])
  if game != nil
    erb :game, locals: JSON.parse(game.game_state)
  else
    status 404
  end
end

post '/new_game' do
  id = SecureRandom.uuid

  state = {
      grid: [%w(- - -), %w(- - -), %w(- - -)],
      next_turn: :a
  }.to_json

  game = Game.new(id: id, game_state: state)
  game.save!

  redirect to("/#{id}")
end

not_found do
  erb :missing
end