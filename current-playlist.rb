require 'open-uri'
require 'sinatra'
require 'hpricot'
require 'haml'
require 'sass'

class Feed
  FEED_URI  = "http://minnesota.publicradio.org/radio/services/"+
                "the_current/songs_played/the_current_playlist_xml.php"
  REFRESH_RATE_IN_SECONDS = 10
  LIMIT = 15
  def self.all
    @cached_tracks = fetch(FEED_URI, LIMIT) if should_reload?
    @cached_tracks
  end
  def self.fetch(uri, limit)
    @last_update = Time.now
    playlist = Hpricot(open("#{uri}?limit=#{limit}").read)
    @cached_tracks = (playlist/"track").map { |x|
                      { :title    => (x/"title").text, 
                        :creator  => (x/"creator").text, 
                        :album    => (x/"album").text }}    
  end
  def self.should_reload?
    @cached_tracks.nil? || expired?
  end
  def self.expired?
    @last_update.nil? || ((Time.now - @last_update) > REFRESH_RATE_IN_SECONDS)
  end
end
  
get '/' do
  @tracks = Feed.all
  haml :index
end

get '/stylesheets/application.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :application_stylesheet
end

__END__

@@ layout
!!!
%html{html_attrs}
  %head
    %title 89.3 The Current Playlist for iPhone
    %link{ :rel => "stylesheet", :type => "text/css", :href => "/stylesheets/application.css"}
    %meta{ :name => "viewport", :content=> "width=320" }
  %body
    =yield

@@ index
%h1 89.3 The Current Playlist for iPhone
%ul#tracks
  - for track in @tracks
    %li
      %h3.title== &ldquo;#{track[:title]}&rdquo;
      %h4.creator
        %span.by by
        %cite= track[:creator]
      %h5.album=track[:album]

@@ application_stylesheet
body, ul, li
  padding: 0
  margin: 0  
body
  font-family: Helvetica, Arial, sans
  font-size: 16px
  line-height: 1.4
  width: 320px
ul
  list-style: none
h1
  font-size: 18px
  margin: 1em auto
  background: transparent url(http://minnesota.publicradio.org/radio/services/the_current/images/hdr_title_radio_cur.gif) no-repeat 0 0
  width: 224px
  height: 131px
  text-indent: -9999em
  overflow: hidden
h3, h4, h5
  margin: 0
  font-weight: normal

ul#tracks li
  padding: 1em
  color: #333
  width: 280px

  .title
    color: #922
    font-weight: bold
    letter-spacing: -1px
  .creator
    font-family: Georgia
    font-style: italic
    color: #888
    margin-left: 1em
    overflow: hidden
    .by
      display: block
      width: 1.45em
      float: left
      position: relative
      top: -0.1em
    cite
      font-family: Helvetica, Arial, sans
      font-style: normal
      color: #333
      float: left
      max-width: 230px
  .album
    color: #999
    margin-left: 2em

ul#tracks li:first-child
  font-size: 1.25em
  background-color: #eee