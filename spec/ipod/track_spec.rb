require "spec_helper"
require "ipod/track"

describe Ipod::Track do
  describe "#exists?" do
    it "knows if file exists" do
      track = Ipod::Track.new filename: "/books/chapter1.mp3", ipod_root: "/mount/ipod"

      File.mock_stub :exists?, true, ["/mount/ipod/books/chapter1.mp3"] do
        assert track.exists?
      end
    end

    it "knows if file doesn't exist" do
      track = Ipod::Track.new filename: "/books/chapter1.mp3", ipod_root: "/mount/ipod"

      File.mock_stub :exists?, false, ["/mount/ipod/books/chapter1.mp3"] do
        refute track.exists?
      end
    end
  end

  describe '#finished?' do
    it 'is true if playcount > 0' do
      track = Ipod::Track.new playcount: 1
      assert track.finished?
    end
    it 'is true if progress above threshold' do
      track = Ipod::Track.new playcount: 0, bookmarktime: Ipod::Track.sec_to_ticks(99)
      track.stub :length, 100 do
        assert track.finished?
      end
    end
    it 'is false if progress below threshold' do
      track = Ipod::Track.new playcount: 0, bookmarktime: Ipod::Track.sec_to_ticks(5)
      track.stub :length, 100 do
        refute track.finished?
      end
    end
    it 'is false if progress unknown and playcount is 0' do
      track = Ipod::Track.new playcount: 0
      track.stub :length, 100 do
        refute track.finished?
      end
    end
  end

  describe '#pos' do
    it 'represents bookmarktime in seconds' do
      track = Ipod::Track.new bookmarktime: 1
      assert_in_delta track.pos, Ipod::Track::SecondsPerTick
    end
  end

  describe '#progress' do
    it 'represents progress in track' do
      track = Ipod::Track.new bookmarktime: Ipod::Track.sec_to_ticks(25)
      track.stub :length, 100 do
        assert_in_delta track.progress, 0.25
      end
    end
  end
end
