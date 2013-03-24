require 'bindata'

class IntBool < BinData::Primitive
  def get;   self.int==0 ? false : true ; end
  def set(v) self.int = v ? 1 : 0 ; end
end

class Bool24 < IntBool
  uint24le :int
end

class Bool8 < IntBool
  uint8 :int
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


