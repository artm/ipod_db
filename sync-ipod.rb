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
}

BEGIN {
  require 'rubygems'
  require 'bundler/setup'

  require 'main'
  require 'find'
  require 'pathname'

  $LOAD_PATH << File.dirname(__FILE__) + '/lib'
  require 'ipod_db'

}
