require 'bindata'
require 'bindata/itypes'
require 'bindata/to_hash'

class IpodDB
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
    @playback_state = playback_state.to_hash
    @tracks = {}
    stats.records.each_with_index do |stat,i|
      h = stat.to_hash.merge( sd.records[i].to_hash )
      h.delete :reclen
      if playback_state.trackno == i
        h[:current] = true
        h[:current_pos] = playback_state.trackpos
      end
      @tracks[ h[:filename] ] = h
    end
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
