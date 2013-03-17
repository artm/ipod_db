# encoding: UTF-8
require 'spec_helper'
require 'ipod_db'
require 'fileutils'

describe IpodDB do
  before do
    @expected = Map.new eval( File.open( "test_data.rb" ).read )
    @ipod_root = 'mock_root'
    @itunes_prefix = "#{@ipod_root}/iPod_Control/iTunes/iTunes"
    # just in case
    FileUtils::rm_rf(@ipod_root)
    FileUtils::cp_r 'test_data', @ipod_root, remove_destination: true
    FileUtils::chmod_R "u=rwX", @ipod_root
  end

  after { FileUtils::rm_rf(@ipod_root) }

  def read_struct struct_name, suffix=''
    File.open "#{@itunes_prefix}#{struct_name}#{suffix}" do |io|
      IpodDB.const_get(struct_name).read(io)
    end
  end
  def write_struct struct_name, struct, suffix=''
    File.open "#{@itunes_prefix}#{struct_name}#{suffix}", 'w' do |io|
      struct.write(io)
    end
  end

  describe IpodDB::PState do
    it 'parses pstate file' do
      read_struct(:PState).snapshot.must_be :==, @expected[:pstate]
    end
    it 'writes pstate file' do
      pstate = read_struct :PState
      write_struct :PState, pstate, '_test'
      pstate_test = read_struct :PState, '_test'
      pstate_test.must_equal pstate
    end
  end

  describe IpodDB::Stats do
    it 'parses stats file' do
      stats = read_struct :Stats
      stats.record_count.must_equal @expected[:tracks].count
      stats.records.count.must_equal @expected[:tracks].count
      stats.records.must_have_records_like @expected[:tracks]
    end
    it 'writes stats file' do
      stats = read_struct :Stats
      write_struct :Stats, stats, '_test'
      stats_test = read_struct :Stats, '_test'
      stats_test.must_equal stats
    end
  end

  describe IpodDB::SD do
    it 'parses tracks file' do
      sd = read_struct :SD
      sd.record_count.must_equal @expected[:tracks].count
      sd.records.count.must_equal @expected[:tracks].count
      sd.records.must_have_records_like @expected[:tracks]
    end
    it 'writes sd file' do
      sd = read_struct :SD
      write_struct :SD, sd, '_test'
      sd_test = read_struct :SD, '_test'
      sd_test.must_equal sd
    end
  end

  it 'loads the whole structure' do
    ipod_db = IpodDB.new @ipod_root
    current_index = @expected[:pstate][:trackno]
    current_filename = @expected[:tracks][ current_index ][:filename]

    ipod_db.must_include_each_of @expected[:tracks].map{|t|t[:filename]}
    ipod_db.current_filename.must_equal current_filename
  end

  describe 'update' do
    before do
      # Given ...
      old_filenames = @expected[:tracks].map{|t| t[:filename]}
      @expected_hash = Hash[old_filenames.zip @expected[:tracks]]
      one_third = old_filenames.count / 3
      @new_books = old_filenames[0...one_third]
      @removed = old_filenames[one_third...2*one_third]
      @new_songs = old_filenames[2*one_third..-1]
      @new_books << '/another_book.mp3'
      @new_songs << '/another_song.mp3'
    end
    it 'updates tracklist in memory given new tracks' do
      # When I ...
      ipod_db = IpodDB.new @ipod_root
      ipod_db.update books: @new_books, songs: @new_songs

      # Then ...
      ipod_db.must_include_none_of @removed
      @new_books.each do |filename|
        actual = ipod_db[filename]
        assert !actual[:shuffleflag]
        assert actual[:bookmarkflag]
        if @expected_hash.include? filename
          rest = @expected_hash[filename].clone
          rest.delete :shuffleflag
          rest.delete :bookmarkflag
          rest.must_be_subset_of actual
        end
      end
      @new_songs.each do |filename|
        actual = ipod_db[filename]
        assert actual[:shuffleflag]
        assert !actual[:bookmarkflag]
        if @expected_hash.include? filename
          rest = @expected_hash[filename].clone
          rest.delete :shuffleflag
          rest.delete :bookmarkflag
          rest.must_be_subset_of actual
        end
      end
    end
    it 'keeps the current track if still present' do
      current_filename = @expected[:tracks][ @expected[:pstate][:trackno] ][:filename]
      ipod_db = IpodDB.new @ipod_root
      ipod_db.update books: @new_books, songs: @new_songs
      ipod_db.must_include current_filename
      ipod_db.current_filename.must_equal current_filename
    end
    it 'writes the whole db' do
      # When I ...
      ipod_db = IpodDB.new @ipod_root
      ipod_db.update books: @new_books, songs: @new_songs
      ipod_db.save

      test_db = IpodDB.new @ipod_root
      test_db.each_track do |track|
        ipod_db[track[:filename]].must_be_subset_of track
      end
      ipod_db.each_track do |track|
        track.must_be_subset_of test_db[track[:filename]]
      end
      ipod_db.playback_state.must_equal test_db.playback_state
    end
    it 'updates the track order' do
      # When I ...
      ipod_db = IpodDB.new @ipod_root
      @new_books.shuffle!
      ipod_db.update books: @new_books, songs: @new_songs

      # Then ...
      book_order = []
      ipod_db.each_track do |t|
        book_order << t[:filename] if @new_books.include? t[:filename]
      end
      book_order.must_equal @new_books
    end
  end
end
