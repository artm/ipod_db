# encoding: UTF-8
require 'bindata'
require 'bindata/itypes'
require 'bindata/to_hash'
require 'map'

class Hash
  def subset *args
    subset = {}
    args.each do |arg|
      subset[arg] = self[arg] if self.include? arg
    end
    subset
  end
end

class IpodDB
  attr_reader :current_filename, :playback_state
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
    @playback_state = read_records PState, 'PState'
    stats = read_records Stats, 'Stats'
    sd = read_records SD, 'SD'
    @current_filename = sd.records[ @playback_state.trackno ].filename
    @current_pos = @playback_state.trackpos
    @tracks = Map.new
    stats.records.each_with_index do |stat,i|
      h = stat.snapshot.merge( sd.records[i].snapshot )
      h.delete :reclen
      @tracks[ h[:filename].to_s ] = h
    end
  end

  def read_records bindata, file_suffix
    File.open make_filename(file_suffix) do |io|
      bindata.read io
    end
  end

  def include? track ; @tracks.include? track ; end

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
      @tracks[filename] ||= {:filename => filename}
      @tracks[filename].merge! shuffleflag: false, bookmarkflag: true
    end
    new_songs.each do |filename|
      @tracks[filename] ||= {:filename => filename}
      @tracks[filename].merge! shuffleflag: true, bookmarkflag: false
    end
  end

  def save
    unless @tracks.include? @current_filename
      @playback_state.trackno = 0
      @playback_state.trackpos = 0
    end
    stats = Stats.new
    sd = SD.new
    @tracks.each_value do |track|
      stats.records << track.subset(:bookmarktime, :playcount, :skippedcount)
      sd.records << track.subset(:starttime, :stoptime, :volume, :file_type, :filename,
                                  :shuffleflag, :bookmarkflag)
    end
    write_records @playback_state, 'PState'
    write_records stats, 'Stats'
    write_records sd, 'SD'
  end

  def write_records bindata, file_suffix
    File.open( make_filename(file_suffix), 'w' ) do |io|
      bindata.write io
    end
  end

  def each_track
    @tracks.each_value {|track| yield track}
  end

  def [] filename
    @tracks[filename]
  end

  def inspect
    "<IpodDB>"
  end

  def make_filename suffix
    "#{@root_dir}/iPod_Control/iTunes/iTunes#{suffix}"
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
