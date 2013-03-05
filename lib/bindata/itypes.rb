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


