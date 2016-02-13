# spec/spec_helper.rb
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
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/game_test.db")
  DataMapper.finalize
  Game.auto_migrate!
end