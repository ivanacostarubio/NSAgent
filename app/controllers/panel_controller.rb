class PanelController < NSWindowController

  include TableVideos
  attr_accessor :backgroundView

  def initWithDelegate(delegate,ns_status_item)
    self.initWithWindow(create_window)
    if self != nil
      @ns_status_item = ns_status_item._window
      @delegate = delegate
    end
    openPanel
    self
  end

  def create_window
    videos_view = NSWindow.alloc.initWithContentRect([[0,0],[600,200]], styleMask:NSBorderlessWindowMask, backing:NSBackingStoreBuffered, defer:false)
    videos_view.setReleasedWhenClosed(false)
    videos_view.setHasShadow(true)
    videos_view.setAnimationBehavior(NSWindowAnimationBehaviorDocumentWindow)
    superview = videos_view.contentView
    superview.addSubview(create_table)

    videos_view
  end

  def awakeFromNib
    super.awakeFromNib
    panel = self.window
    panel.setAcceptsMouseMovedEvents(true)
    panel.setLevel(NSPopUpMenuWindowLevel)
    panel.setOpaque(false)
    panel.setBackgroundColor(NSColor.clearColor)
  end

  def hasActivePanel
    @hasActivePanel
  end

  def setHasActivePanel(flag)
    if @hasActivePanel == flag
      return
    end
    @hasActivePanel = flag
    @hasActivePanel ? self.openPanel : self.closePanel
  end

  def windowWillClose(notification)
    @hasActivePanel = false
  end

  def windowDidResignKey(notification)
    if (self.window.isVisible)
      @hasActivePanel = false
    end
  end

  def windowDidResize(notification)
    panel = self.window
    statusRect = self.statusRectForWindow(panel)
    panelRect = panel.frame
      
    statusX = (NSMidX(statusRect)).round
    panelX = statusX - NSMinX(panelRect)
    
#    self.backgroundView.arrowX = panelX
  end

  def cancelOperation(sender)
    @hasActivePanel = false
  end

  def statusRectForWindow(window)
    screenRect = NSScreen.screens.objectAtIndex(0).frame
    statusRect = NSZeroRect
    
    statusItemView = nil
    if @delegate.respondsToSelector("statusItemViewForPanelController:")
      statusItemView = @delegate.statusItemViewForPanelController(self)
    end
    if statusItemView
      statusRect = statusItemView.globalRect
      statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect)
    else
      statusRect.size = NSMakeSize(status_item_view_width, NSStatusBar.systemStatusBar.thickness)
      statusRect.origin.x = ((NSWidth(screenRect) - NSWidth(statusRect)) / 2).round
      statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2
    end
    return statusRect
  end

  def openPanel
    panel = self.window
    
    item_origin = @ns_status_item.frame.origin
    screenRect = NSScreen.screens.objectAtIndex(0).frame
    statusRect = self.statusRectForWindow(panel)

    panelRect = panel.frame
    panelRect.size.width = panel_width
    panelRect.size.height = popup_height

    panelRect.origin.x = (item_origin.x).round
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect)
    

    if NSMaxX(panelRect) > (NSMaxX(screenRect) - arrow_height)
     panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - arrow_height)
    end

    NSApp.activateIgnoringOtherApps(false)
    panel.setAlphaValue(0)
    panel.setFrame(statusRect, display:true)
    panel.makeKeyAndOrderFront(nil)
    
    openDuration = open_duration
    
    currentEvent = NSApp.currentEvent
    if currentEvent.type == NSLeftMouseDown
      clearFlags = (currentEvent.modifierFlags & NSDeviceIndependentModifierFlagsMask)
      shiftPressed = (clearFlags == NSShiftKeyMask)
      shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask))
      if shiftPressed || shiftOptionPressed
        openDuration *= 10
        if (shiftOptionPressed)
          NSLog("Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@", NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect))
        end
      end
    end    
    NSAnimationContext.beginGrouping
    NSAnimationContext.currentContext.setDuration(openDuration)
    panel.animator.setFrame(panelRect, display:true)
    panel.animator.setAlphaValue(1)
    NSAnimationContext.endGrouping
    panel.orderFrontRegardless
  end

  def closePanel
    NSAnimationContext.beginGrouping
    NSAnimationContext.currentContext.setDuration(close_duration)
    self.window.animator.setAlphaValue(0)
    NSAnimationContext.endGrouping
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ->{
      self.window.orderOut(nil)
    })
  end

  def arrow_width
    12
  end

  def arrow_height 
    8
  end
  #define arrow_height 8


  def status_item_view_width
    24
  end

  def open_duration 
    0.15
  end

  def close_duration
    0.1
  end

  def search_inset
    17
  end

  def popup_height
    max_items * 33
  end

  def max_items
    videos_items = Video.size 
    videos_items > 5 ? 5 : videos_items
  end

  def panel_width
    280
  end

  def menu_animation_duration 
    0.1
  end
end