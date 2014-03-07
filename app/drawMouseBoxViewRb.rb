class DrawMouseBoxViewRb < NSView
  attr_accessor :delegate, :mouseDownPoint, :mouseUpPoint, :selectionRect, :_selectionRect, :last_rect


  def mouseDown(event)
    @mouseDownPoint = event.locationInWindow
    puts self.window.firstResponder.inspect
  end  
  
  def mouseUp(event)
    @mouseUpPoint = event.locationInWindow
    @selectionRect = NSMakeRect(
        [@mouseDownPoint.x, @mouseUpPoint.x].min, 
        [@mouseDownPoint.y, @mouseUpPoint.y].min, 
        [@mouseDownPoint.x, @mouseUpPoint.x].max - [@mouseDownPoint.x, @mouseUpPoint.x].min,
        [@mouseDownPoint.y, @mouseUpPoint.y].max - [@mouseDownPoint.y, @mouseUpPoint.y].min)
        
    delegate.drawMouseBoxView(self, didSelectRect:@selectionRect) if valid_size
    
  end  
  
  def mouseDragged(event)
    curPoint = event.locationInWindow
    
    previousSelectionRect = !previousSelectionRect.nil? ? @_selectionRect : NSMakeRect(0,0,0,0)
    @_selectionRect = NSMakeRect(
        [@mouseDownPoint.x, curPoint.x].min, 
        [@mouseDownPoint.y, curPoint.y].min, 
        [@mouseDownPoint.x, curPoint.x].max - [@mouseDownPoint.x, curPoint.x].min,
        [@mouseDownPoint.y, curPoint.y].max - [@mouseDownPoint.y, curPoint.y].min)     
          
    self.setNeedsDisplayInRect(self.frame)  
  end  
  
  def drawRect(dirtyRect)
    NSColor.blackColor.set
    NSRectFill(dirtyRect)
    
    NSColor.whiteColor.set
    @_selectionRect =  NSMakeRect(0,0,0,0) if @_selectionRect.nil?
    NSRectFill(@_selectionRect)
  end 
  
  def valid_size
    return false if @selectionRect.size.width < 10
    return false if @selectionRect.size.height < 10    
    true
  end  
  
  def acceptsFirstResponder
    self.window.makeFirstResponder(self)
    return true
  end   
  
  def keyDown(event)
    puts event
    puts 'ffff'*80
  end  
  
end  