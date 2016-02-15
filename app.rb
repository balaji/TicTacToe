# The program handles a game of Tic-Tac-Toe in browser.
#
# Author    :: Balaji Damodaran  (mailto:damodaran.balaji@gmail.com)
# Copyright :: Copyright (c) 2016
# License   :: Distributes under the same terms as Ruby

# This Sinatra Routes file acts as a controller for HTTP requests
# and manages state (game play) changes.

require 'rubygems'
require 'sinatra'
require 'sinatra/respond_with'
require 'json'
require 'data_mapper'
require 'tilt/erb'

require_relative 'models/game'
require_relative 'lib/tic_tac_toe'

DataMapper.setup(:default,
                 ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/game.db")
DataMapper.finalize
Game.auto_upgrade!

# Loads home page.
get '/' do
  erb :index
end

# Responds to both html and json headers.
# if it is a json request, it returns the state of the game.
# else it loads the game page without validation.
get '/:id', provides: [:html, :json] do
  respond_to do |f|
    f.json do
      game = Game.get(params[:id])
      if !game.nil?
        content_type :json
        game.game_state
      else
        status 404
      end
    end

    f.html { erb :game, locals: { game_id: params[:id] } }
  end
end

# Creates a new game redirects to game page.
post '/new_game' do
  id = SecureRandom.uuid

  state = {
    grid: [%w(- - -), %w(- - -), %w(- - -)],
    next_turn: :a,
    game_status: { state: TicTacToe::Game::Status::IN_PROGRESS }
  }.to_json

  game = Game.new(id: id, game_state: state)
  game.save!

  redirect to("/#{id}")
end

# Updates the game state with a new move given by row and column co-ordinates.
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
