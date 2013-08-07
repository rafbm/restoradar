Foursquare.default_params v: '20130108',
  client_id: ENV['FOURSQUARE_ID'],
  client_secret: ENV['FOURSQUARE_SECRET']

helpers do
  def stylus(filename = nil)
    if filename
      str = File.read("./assets/#{filename}.styl")
    else
      str = yield
    end
    Stylus.compile(str, :compress => true).gsub("\n", '')
  end

  def stylus_tag(filename = nil, &block)
    "<style>#{stylus(filename, &block)}</style>"
  end

  def coffee_script(filename = nil)
    if filename
      str = File.read("./assets/#{filename}.coffee")
    else
      str = yield
    end
    CoffeeScript.compile(str)
  end

  def coffee_script_tag(filename = nil, &block)
    "<script>#{coffee_script(filename, &block)}</script>"
  end

  def data_uri(filename)
    require 'base64'

    filename = "./assets/#{filename}"
    base64 = Base64.encode64(File.read(filename)).gsub("\n",'')

    output = `file --mime #{filename}`
    mime = output.match( /: (.*)$/ )[1].downcase.gsub(/\s/,'')

    "data:#{mime};base64,#{base64}"
  end
end

# Cache
LAST_RESTART = Time.now

# Routes
get '/' do
  last_modified LAST_RESTART
  expires 600, :public

  erb :index
end

get '/restos' do
  expires 60, :private

  opts = {
    ll: params[:location],
    limit: 50,
    intent: 'browse',
    radius: 1000,
    categoryId: Foursquare::Categories::Food,
  }
  opts[:locale] = 'fr' if request.env["HTTP_ACCEPT_LANGUAGE"].start_with? 'fr'

  @restos = Foursquare.search_venues(opts)

  erb :restos, layout: false
end
