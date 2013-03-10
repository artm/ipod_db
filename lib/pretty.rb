module Pretty
  def Pretty.seconds seconds
    if seconds < 60
      "#{seconds} sec"
    else
      minutes = (seconds / 60).floor
      if minutes < 60
        seconds -= 60*minutes
        "%02d:%02d" % [minutes, seconds]
      else
        hours = (minutes / 60).floor
        minutes -= 60*hours
        "%d:%02d:%02d" % [ hours, minutes, seconds ]
      end
    end
  end
end
