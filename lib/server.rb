require 'rack'
require 'sinatra'
require 'haml'
require 'sass'

require 'lib/playlist'

helpers do
  # via: http://textplain.blogspot.com/2007/06/widontrb.html
  def widont(text)
    text.gsub(/([^\s])\s+([^\s]+)$/, '\1&nbsp;\2')
  end

  # via: http://openmonkey.com/articles/2009/02/caching-and-expring-stylesheets-and-javascripts-in-sinatra
  def versioned_stylesheet(stylesheet)
    "/stylesheets/#{stylesheet}.css?" +
      File.mtime(File.join(Sinatra::Application.views, "stylesheets", "#{stylesheet}.sass")).to_i.to_s
  end
end

get '/' do
  response['Cache-Control'] = 'public, max-age=10' # cache for 10 seconds
  @tracks = Playlist.recent
  haml :index
end

get '/stylesheets/application.css' do
  content_type 'text/css'
  response["Cache-Control"] = "public, max-age=2592000" # via: sassacache.rb
  response['Expires'] = (Time.now + 60 * 60 * 24 * 356 *3).httpdate
  sass :"stylesheets/application"
end