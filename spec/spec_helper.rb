# Author::    Balaji Damodaran  (mailto:damodaran.balaji@gmail.com)
# Copyright:: Copyright (c) 2016
# License::   Distributes under the same terms as Ruby

# This helper program is used to include Rack Test Methods in
# Rspec configuration for testing Sinatra (Rack-based) routes.
require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/game_test.db")
  DataMapper.finalize
  Game.auto_migrate!
end
