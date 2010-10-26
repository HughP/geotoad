# This is where code specific to the user interface display gets put.
#
# $HeadURL$
# $Id$

module Messages
  def enableDebug
    $debugMode = 1
  end

  def disableDebug
    $debugMode = 0
  end

  def debug(text)
    if $debugMode == 1
      puts "D: #{text}"
    end
  end

  # Text that's just fluff that can be ignored.
  def displayInfo(text)
    puts "( - ) #{text}"
  end
    
  # often worth displaying
  def displayTitleMessage(text)
    puts "( = ) #{text}"
  end
    
  # often worth displaying
  def displayMessage(text)
    puts "( o ) #{text}"
  end
    
  # mindless warnings
  def displayWarning(text)
    puts " ***  #{text}"
  end
    
  # fatal errors
  def displayError(text)
    puts " *!*  ERROR: #{text}"
    sleep(1)
  end
end
