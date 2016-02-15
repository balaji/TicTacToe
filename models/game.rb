# Author    :: Balaji Damodaran  (mailto:damodaran.balaji@gmail.com)
# Copyright :: Copyright (c) 2016
# License   :: Distributes under the same terms as Ruby
#
# This DataMapper class is the ORM model for the table 'games'
# that holds the game state for every game.
class Game
  include DataMapper::Resource

  property :id, String, key: true
  property :game_state, Text
end
