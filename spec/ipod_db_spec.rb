# encoding: UTF-8
require 'spec_helper'
require 'ipod_db'

require 'fileutils'

describe IpodDB do
  before do
    @expected = eval( File.open( "test_data.rb" ).read )
    @ipod_root = 'mock_root'
    # just in case
    FileUtils::rm_rf(@ipod_root)
    FileUtils::cp_r 'test_data', @ipod_root, remove_destination: true
  end

  after do
    FileUtils::rm_rf(@ipod_root)
  end

  describe IpodDB::PState do
    it 'parses pstate file' do
      File.open( "#{@ipod_root}/iPod_Control/iTunes/iTunesPState" ) do |file|
        pstate = IpodDB::PState.read(file)
        pstate.to_hash.must_be :==, @expected[:pstate]
      end
    end
    it 'writes pstate file' do
      pstate = File.open( "#{@ipod_root}/iPod_Control/iTunes/iTunesPState" ) do |file|
        IpodDB::PState.read(file)
      end
      File.open( "#{@ipod_root}/iPod_Control/iTunes/iTunesPState_test", 'w' ) do |file|
        pstate.write(file)
      end
      test_pstate = File.open( "#{@ipod_root}/iPod_Control/iTunes/iTunesPState_test" ) do |file|
        IpodDB::PState.read(file)
      end
      test_pstate.must_equal pstate
    end
  end

  describe IpodDB::Stats do
    it 'parses stats file' do
      file = File.open( "#{@ipod_root}/iPod_Control/iTunes/iTunesStats" )
      stats = IpodDB::Stats.read(file)
      stats.record_count.must_equal @expected[:tracks].count
      stats.records.count.must_equal @expected[:tracks].count
      @expected[:tracks].each_with_index do |track,i|
        [:bookmarktime, :playcount, :skippedcount].each do |field|
          stats.records[i].send(field).value.must_equal track[field]
        end
      end
    end
  end

  describe IpodDB::SD do
    it 'parses tracks file' do
      file = File.open( "#{@ipod_root}/iPod_Control/iTunes/iTunesSD" )
      tracks = IpodDB::SD.read(file)
      tracks.record_count.must_equal @expected[:tracks].count
      tracks.records.count.must_equal @expected[:tracks].count
      @expected[:tracks].each_with_index do |track,i|
        [:starttime,:stoptime,:volume,:file_type,:shuffleflag,
         :bookmarkflag, :filename].each do |field|
          tracks.records[i].send(field).value.must_equal track[field]
        end
      end
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
      @new_songs = old_filenames[one_third...2*one_third]
      @removed = old_filenames[2*one_third..-1]
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

    it 'writes db down properly' do
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
  end
end
