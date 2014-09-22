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

  def numberOfRowsInTableView(table_view)
    data_videos.size
  end

  def tableView(table_view, objectValueForTableColumn:tableColumn, row:row)
    case tableColumn.identifier.to_sym
    when :link_video
      data_videos[row].url
    when :delete
      "delete"
    end
  end
 ## TABLEVIEW DELEGATE
  #########

  def data_videos
    @data_videos ||= Video.all
  end

  def tableView(table_view, heightOfRow:row)
    30
  end

  def tableView(tableView, didClickTableColumn: column)
    puts "CLick"
    puts "column = #{column}"
  end
  def tableView(tableView, viewForTableColumn:tableColumn, row:row)
    cell_identifier = "#{tableColumn}, #{row}"
    result = tableView.makeViewWithIdentifier(cell_identifier,owner:self)
    if result.nil? 
      result = NSTextField.alloc.initWithFrame([[0,0],[50,50]])
      result.setBordered(false)
      result.setBezeled(false)
      result.setEditable(false)
      result.setSelectable(false)
      result.identifier = cell_identifier
    end
    result
  end
end
class CustomURL < NSURL
  attr_accessor :identifier
end