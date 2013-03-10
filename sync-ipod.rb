#!/usr/bin/env ruby

Main {
  version '0.1.0'

  description <<-__
  Update iPod Shuffle (2nd gen) database. Given directories of bookmarkable
  and non-bookmarkable media #{program} will find all supported tracks and
  add them to the iPod database so the device is aware of their existance.

  It is perfectly possible to have other directories full of tracks in device's
  subconscious - e.g. when time-sharing the device among members of a poor
  family. Just make sure you update the database using your directories when
  receiving it from a relation.

  iPod remembers playback position on bookmarkable media and the #{program} goes
  out of its way to preserve the bookmarks. It also removes bookmarkable files
  from shuffle list.
  __

  author 'artm <femistofel@gmail.com>'

  argument('ipod_root') {
    default "/media/#{ENV['USER']}/IPOD"
    validate {|path| IpodDB.looks_like_ipod? path}
    description 'path where ipod is mounted'
  }
  option('books','b') {
    argument_required
    default 'books'
    description 'subdirectory of ipod with bookmarkable media'
  }
  option('songs','s') {
    argument_required
    default 'songs'
    description 'subdirectory of ipod with non-bookmarkable media'
  }

  def run
    ipod_root = params['ipod_root'].value
    ipod_db = IpodDB.new ipod_root
    books_path = File.join ipod_root, params['books'].value
    songs_path = File.join ipod_root, params['songs'].value
    books = collect_tracks(books_path, ipod_root)
    songs = collect_tracks(songs_path, ipod_root)
    ipod_db.update books: books, songs: songs
    ipod_db.save
    exit_success!
  end

  mode('ls') {
    description 'produce a colorful listing of the tracks in the ipod database'
    def run
      @ipod_root = params['ipod_root'].value
      @ipod_db = IpodDB.new @ipod_root
      @ipod_db.each_track_with_index {|track,i| list_track i, track}
    end

    def track_info track
      info = Map.new
      info['played'] = track.playcount if track.playcount > 0
      info['skipped'] = track.skippedcount if track.skippedcount > 0
      if track.bookmarkflag && track.bookmarktime > 0
        pos = track.bookmarktime * 0.256 # ipod keeps time in 256 ms increments
        abs_path = File.join @ipod_root, track.filename
        total_time = track_length(abs_path)
        if pos / total_time >= 0.05
          info['pos'] = Pretty.seconds pos
          info['total'] = Pretty.seconds total_time
        end
      end
      info
    end

    def list_track i, track
      abs_path = File.join @ipod_root, track.filename
      track_color = File.exists?(abs_path) ? :green : :red

      listing_entry = "%2d: %s" % [i,track.filename.apply_format( color: track_color )]
      listing_entry = listing_entry.bold if @ipod_db.playback_state.trackno == i
      puts listing_entry

      info = track_info(track)
      if info.count > 0
        puts "  " + info.map{|label,value| "#{label}: #{value.to_s.yellow}"}.join(" ")
      end
    end
  }

  def collect_tracks path, root
    begin
      tracks = []
      Find.find(path) do |filepath|
        tracks << ipod_path(filepath,root) if track? filepath
      end
      tracks
    rescue Errno::ENOENT
      []
    end
  end

  def ipod_path path, root
    '/' + Pathname.new(path).relative_path_from(Pathname.new root).to_s
  end

  def track? path
    IpodDB::ExtToFileType.include? File.extname(path)
  end

  def track_length( path )
    TagLib::FileRef.open(path){|file| file.audio_properties.length}
  end
}

BEGIN {
  require 'rubygems'
  require 'bundler/setup'

  require 'main'
  require 'find'
  require 'pathname'
  require 'smart_colored/extend'
  require 'map'
  require 'taglib'

  $LOAD_PATH << File.dirname(__FILE__) + '/lib'
  require 'ipod_db'
  require 'pretty'

}
