require 'spec_helper'
require 'ipod_db'

describe IpodDB do
  it 'parses database' do
    expected = eval( File.open( 'test_data.rb' ).read )
    db = IpodDB.new 'test_data'
    db.playback_state.must_equal expected[:pstate]
    db.tracks.must_equal expected[:tracks]
  end
end
