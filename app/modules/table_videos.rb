module TableVideos
  def create_table
    @table_view = NSTableView.alloc.init
    @table_view.delegate =self
    @table_view.dataSource =self

    columnOne = NSTableColumn.alloc.initWithIdentifier "link_video"
    columnOne.setWidth 200
    columnOne.identifier = :link_video
    @table_view.addTableColumn columnOne

    columnTwo = NSTableColumn.alloc.initWithIdentifier "delete"
    columnTwo.setWidth 200
    columnTwo.identifier = :delete
    @table_view.addTableColumn columnTwo
  end

  def table_view
    @table_view
  end

  def numberOfRowsInTableView(tableView)
    data_videos.size
  end

  def tableView(tableView, objectValueForTableColumn:tableColumn, row:row)
    case tableColumn.identifier.to_sym
    when :link_video
      date_formatter.convert_time( data_videos[row].date )
    when :delete
      "delete".__
    end
  end
 ## TABLEVIEW DELEGATE
  #########

  def data_videos
    @data_videos ||= Video.all
  end

  def tableView(tableView, heightOfRow:row)
    30
  end

  def tableView(tableView, viewForTableColumn:tableColumn, row:row)
    cell_identifier = "#{tableColumn}, #{row}"
    result = tableView.makeViewWithIdentifier(cell_identifier,owner:self)
    if result.nil? 
      result = CustomButton.alloc.initWithFrame([[0,0],[50,50]])
      result.setTarget(self)
      result.setVideo(data_videos[row])
      message = tableView(tableView, objectValueForTableColumn:tableColumn, row:row)
      result.setAction( message.eql?("delete".__) ? "delete:" : "visit:")
      result.setTitle( message )
      result.identifier = cell_identifier
    end
    result
  end

  def delete(sender)
    video_detroyer = VideoDestroyer.new(sender.video)
    video_detroyer.destroy do
      @data_videos = nil
      table_view.reloadData
      openPanel
    end
  end

  def visit(sender)
    url = NSURL.URLWithString(sender.video.url)
    unless NSWorkspace.sharedWorkspace.openURL(url)
      NSLog("Failed to open url: #{url.description}")
    end
  end

  def date_formatter
    @date_formatter ||= DateFormatter.new
  end
end

class CustomButton < NSButton
  attr_accessor :item,:video

  def setVideo(video)
    @video = video
    setBordered(false)
  end
end