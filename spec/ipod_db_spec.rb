# encoding: UTF-8
require 'spec_helper'
require 'ipod_db'

describe IpodDB do
  before do
    @expected = eval( File.open( 'test_data.rb' ).read )
  end

  describe IpodDB::PState do
    it 'parses pstate file' do
      file = File.open( 'test_data/iPod_Control/iTunes/iTunesPState' )
      pstate = IpodDB::PState.read(file)
      @expected[:pstate].each do |field,value|
        pstate.send(field).value.must_equal value
      end
    end
  end

  describe IpodDB::Stats do
    it 'parses stats file' do
      file = File.open( 'test_data/iPod_Control/iTunes/iTunesStats' )
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
      file = File.open( 'test_data/iPod_Control/iTunes/iTunesSD' )
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


end
