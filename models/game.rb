class Game
  include DataMapper::Resource

  property :id, String, key: true
  property :game_state, Text
end