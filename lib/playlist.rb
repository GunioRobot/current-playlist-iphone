require 'open-uri'
require 'nokogiri'

class Playlist
  DEFAULT_LIMIT = 15

  @base_uri   = "http://minnesota.publicradio.org/radio/services/"+
                  "the_current";

  @feed_uri   = "#{@base_uri}/songs_played/the_current_playlist_xml.php"

  @detail_uri = "#{@base_uri}/playlist/song_detail.php"

  def self.recent
    feed = Nokogiri::XML(open("#{@feed_uri}?limit=#{DEFAULT_LIMIT}"))
    (feed/"track").map do |x|
      title = (x/"title").text
      song_id = (x/"song-id").text
      {
        :title      => title,
        :creator    => (x/"creator").text,
        :album      => (x/"album").text,
        :song_id    => song_id,
        :detail_uri => "%s?song_id=%s" % [@detail_uri, song_id]
      }
    end
  end
end