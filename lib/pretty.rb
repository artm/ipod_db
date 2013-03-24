module Pretty
  def Pretty.seconds seconds
    seconds = seconds.to_i
    if seconds < 60
      "#{seconds} sec"
    else
      minutes = (seconds / 60).floor
      seconds -= 60*minutes
      if minutes < 60
        "%02d:%02d" % [minutes, seconds]
      else
        hours = (minutes / 60).floor
        minutes -= 60*hours
        "%d:%02d:%02d" % [ hours, minutes, seconds ]
      end
    end
  end
end
