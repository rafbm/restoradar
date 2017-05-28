require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])

use Rack::Deflater
use Rack::Cache

map '/assets' do
  assets = Sprockets::Environment.new
  assets.append_path 'assets'
  run assets
end

map '/' do
  require './lib/foursquare'
  require './app'

  run Sinatra::Application
end
