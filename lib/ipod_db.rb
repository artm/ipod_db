require 'bindata'

class Bool24 < BinData::Primitive
  uint24le :int
  def get;   self.int==0 ? false : true ; end
  def set(v) self.int = v ? 1 : 0 ; end
end

class Bool8 < BinData::Primitive
  uint8 :int
  def get;   self.int==0 ? false : true ; end
  def set(v) self.int = v ? 1 : 0 ; end
end

class EncodedString < BinData::Primitive
  string :str, length: :length
  def get
    self.str.force_encoding('UTF-16LE').encode('UTF-8').sub(/\u0000*$/,'')
  end
  def set(v)
    self.str = v.encode('UTF-16LE')
  end
end

class IpodDB
  attr_reader :playback_state, :tracks
  def initialize root_dir
    @root_dir
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
