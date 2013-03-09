#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'main'
require 'find'
require 'pathname'

$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'ipod_db'

Main {
  argument('ipod_root') { default "/media/#{ENV['USER']}/IPOD" }
  option('books') { default 'books' }
  option('songs') { default 'songs' }

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
