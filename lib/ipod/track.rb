require 'ostruct'
require 'taglib'
require 'fileutils'

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
      (playcount and playcount > 0) or progress > FinishedProgress
    end

    def progress
      pos / length
    end

    def pos
      Track.ticks_to_sec(bookmarktime || 0.0)
    end

    def length
      return @length if @length
      # if file is writable TagLib opens it read-write and appears to write something when the file
      # gets closed, or in any case closing a file open read-write is slow on slow media.
      #
      # if file is readonly TagLib still opens it but closing is much faster.
      #
      old_stat = File::Stat.new(absolute_path)
      begin
        FileUtils.chmod('a-w', absolute_path)
        return @length = TagLib::FileRef.open(absolute_path){|file| file.audio_properties.length}
      ensure
        FileUtils.chmod(old_stat.mode, absolute_path)
      end
    end

    def self.sec_to_ticks(sec)
      sec / SecondsPerTick
    end

    def self.ticks_to_sec(ticks)
      ticks * SecondsPerTick
    end
  end
end
