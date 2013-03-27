require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])

use Rack::Deflater
use Rack::Cache

map '/assets' do
  assets = Sprockets::Environment.new
  assets.append_path 'assets'
  Stylus.setup(assets)
  run assets
end

map '/' do
  require './lib/foursquare'
  require './app'

  run Sinatra::Application
end

# New Relic
if ENV['RACK_ENV'] == 'production'
  # See http://support.newrelic.com/kb/troubleshooting/unicorn-no-data
  ::NewRelic::Agent.after_fork(:force_reconnect => true) if defined? Unicorn
end
