class IpodDB
  attr_reader :playback_state, :tracks
  def initialize root_dir
    @root_dir
  end
end
