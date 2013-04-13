require 'ostruct'
require 'taglib'

module Ipod
  class Track < OpenStruct
    FinishedProgress = 0.97
    SecondsPerTick = 0.256

    def absolute_path
      File.join ipod_root, filename
    end

    def exists?
      @exists ||= File.exists? absolute_path
    end

    def finished?
      playcount > 0 or progress > FinishedProgress
    end

    def progress
      pos / length
    end

    def pos
      Track.ticks_to_sec(bookmarktime)
    end

    def length
      TagLib::FileRef.open(absolute_path){|file| file.audio_properties.length}
    end

    def self.sec_to_ticks(sec)
      sec / SecondsPerTick
    end

    def self.ticks_to_sec(ticks)
      ticks * SecondsPerTick
    end
  end
end
