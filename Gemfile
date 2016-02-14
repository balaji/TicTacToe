source 'http://rubygems.org'

ruby '2.3.0'
gem 'sinatra'
gem 'data_mapper'

group :development, :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'dm-sqlite-adapter'
end

# Postgres for Heroku, as it does not allow sqlite in production.
group :production do
  gem 'dm-postgres-adapter'
end
