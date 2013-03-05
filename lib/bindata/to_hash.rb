require 'bindata'

class BinData::Struct
  def to_hash
    h = {}
    each_pair do |key,val|
      h[key] = val
    end
    h
  end
end

