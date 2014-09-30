class DateFormatter
  def initialize
    @dateFormatter = NSDateFormatter.alloc.init
    @dateFormatter.setDateStyle(NSDateFormatterMediumStyle)
    @dateFormatter.setTimeStyle(NSDateFormatterMediumStyle)
    @dateFormatter.setLocale(NSLocale.currentLocale)
  end
  
  def convert_time(time)
    @dateFormatter.stringFromDate(time)    
  end

end