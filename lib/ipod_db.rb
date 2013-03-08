require 'bindata'
require 'bindata/itypes'
require 'bindata/to_hash'
require 'map'

class IpodDB
  attr_reader :current_filename
  class NotAnIpod < RuntimeError
    def initialize path
      super "#{path} doesn't appear to be an iPod"
    end
  end

  def initialize root_dir
    @root_dir = root_dir
    begin
      read
    rescue Errno::ENOENT
      raise NotAnIpod.new @root_dir
    end
  end

  def read
    playback_state = PState.read control_file('PState')
    stats = Stats.read control_file('Stats')
    sd = SD.read control_file('SD')
    @current_filename = sd.records[ playback_state.trackno ].filename
    @tracks = Map.new
    stats.records.each_with_index do |stat,i|
      h = stat.to_hash.merge( sd.records[i].to_hash )
      h.delete :reclen
      @tracks.set h[:filename], h
    end
  end

  def include? track ; @tracks.keys.include? track ; end

  def update *args
    opts = Map.options(args)
    new_books = opts.getopt :books, default: []
    new_songs = opts.getopt :songs, default: []
    new_tracks = new_books + new_songs

    old_tracks = @tracks.keys.clone # clone because otherwise it'll change during iteration
    old_tracks.each do |filename|
      @tracks.delete filename unless new_tracks.include? filename
    end
    new_books.each do |filename|
      @tracks.set filename, :filename, filename
      @tracks[filename].update shuffleflag: false, bookmarkflag: true
    end
    new_songs.each do |filename|
      @tracks.set filename, :filename, filename
      @tracks[filename].update shuffleflag: true, bookmarkflag: false
    end
  end

  def [] filename
    @tracks[filename]
  end

  def inspect
    "<IpodDB>"
  end

  def control_file suffix
    File.open "#{@root_dir}/iPod_Control/iTunes/iTunes#{suffix}"
  end

  class PState < BinData::Record
    endian :little
    uint8 :volume, initial_value: 29
    uint24 :shufflepos
    uint24 :trackno
    bool24 :shuffleflag
    uint24 :trackpos
    string length: 19
  end

  class Stats < BinData::Record
    endian :little
    uint24 :record_count, value: lambda { records.count }
    uint24
    array :records, initial_length: :record_count do
      uint24 :reclen, value: lambda { num_bytes }
      int24 :bookmarktime, initial_value: -1
      string length: 6
      uint24 :playcount
      uint24 :skippedcount
    end
  end

  class SD < BinData::Record
    endian :big
    uint24 :record_count, value: lambda { records.count }
    uint24 :const, value: 0x10800
    uint24 :reclen, value: lambda { num_bytes }
    string length: 9
    array :records, initial_length: :record_count do
      uint24 :reclen, value: lambda { num_bytes }
      string length: 3
      uint24 :starttime
      string length: 6
      uint24 :stoptime
      string length: 6
      uint24 :volume, initial_value: 100
      uint24 :file_type
      string length: 3
      encoded_string :filename, length: 522
      bool8 :shuffleflag
      bool8 :bookmarkflag
      string length: 1
    end
  end
end
