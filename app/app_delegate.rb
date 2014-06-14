class ScreenRecorder # USAGE: # @tape = ScreenRecorder.new # # start a recording with # @tape.record
  # # stop it:
  # @tape.stop

  attr_accessor :video_path, :file_name, :delegate, :fullscreen, :app, :device, :timer, :count

  def initialize(video_path="video_recording.mov", app)
    @video_path = NSURL.fileURLWithPath(video_path)
    @app = app
  end

  def record_fullscreen
    display_apple_terms if first_run?
    @fullscreen = true
    setup_video
    setup_recording 
    start_recording
  end  
  
  def record_crop
    setup_video
  end  

  def display_apple_terms
    App::Persistence['first_run'] = true
    msgBox = NSAlert.alloc.init
    msgBox.setMessageText("Hello!\n\nAfter this message we'll begin recording your screen and your microphone. \n \nWhen you are ready click stop and the video will be automatically uploaded to a server. We'll copy the URL to your clipboard and we'll delete the video in 30 days. \n\nOnly people with the link will have access to it. \n\n You agree to this terms by clicking OK. \n\nHappy recording!!!.")
    msgBox.addButtonWithTitle("OK")
    msgBox.runModal
  end

  def first_run?
    App::Persistence['first_run'] == nil
  end

  def start_recording
    @captureMovieFileOutput.startRecordingToOutputFileURL(video_path, recordingDelegate:self)
  end  

  def stop
    @captureMovieFileOutput.stopRecording
  end

  def setup_video
    @session = AVCaptureSession.alloc.init
    @session.sessionPreset = AVCaptureSessionPresetHigh

    @device = AVCaptureScreenInput.alloc.initWithDisplayID(CGMainDisplayID())
    @device.capturesMouseClicks =  true
    
    if @fullscreen
      final_video_setup
    else
      setDisplayAndCropRect  
    end  
   
  end
  
  def final_video_setup
    if @session.canAddInput(@device)
      NSLog("Agrego la pantalla")
      @session.addInput(@device)
    else
      NSLog("Badddd")
    end

    setup_audio
    @session.startRunning()
  end  

  def setup_recording
    @captureMovieFileOutput = AVCaptureMovieFileOutput.alloc.init
    @captureMovieFileOutput.setDelegate(self)
    if @session.canAddOutput(@captureMovieFileOutput)
      @session.addOutput(@captureMovieFileOutput)
    end
  end

  def setup_audio
    audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
    audioInput = AVCaptureDeviceInput.deviceInputWithDevice(audioDevice, error:nil)
    if @session.canAddInput(audioInput)
      @session.addInput(audioInput)
    end
  end

  def captureOutput(captureOutput, didFinishRecordingToOutputFileAtURL:outputFileURL, fromConnections:connections, error:error)
     NSLog("Did finish recording to %@ due to error %@", outputFileURL.description, error.description) if error
     @session.stopRunning
     @session = nil
     @uploader = Uploader.new(delegate)
     @uploader.failure = lambda { |operation, error| NSLog("Upload Failed...") ; NSLog("Error: %@", error)  ; NSLog(" Error: %@", operation)}
     @uploader.delegate = delegate
     
     @uploader.save(file_name)
  end
  
  def drawMouseBoxView(view, didSelectRect:rect)
    @device.cropRect = rect
    final_video_setup
    @app.windows.each{|w| w.close if w.level == NSDockWindowLevel + 1000}
    NSCursor.currentCursor.pop
    setup_recording 
    start_recording
  end
  
  private
  
  def setDisplayAndCropRect
    [@app.windows.first].each do |window|
      window.setBackgroundColor(NSColor.blackColor)
      window.setAlphaValue(0.5)
      window.setLevel(NSDockWindowLevel + 1000)
      window.setReleasedWhenClosed(true)
      
      drawMouseBoxView = DrawMouseBoxViewRb.alloc.initWithFrame(window.frame)
      drawMouseBoxView.delegate = self

      window.setInitialFirstResponder(drawMouseBoxView)
      window.makeFirstResponder(drawMouseBoxView)      
      
      window.setContentView(drawMouseBoxView)

      window.makeKeyAndOrderFront(self)
    end  
    NSCursor.crosshairCursor.push
  end  

end

class ScreenRecorder
end

class AppDelegate
  attr_accessor :status_menu, :windows

  def applicationDidFinishLaunching(notification)

    @windows = []
    NSScreen.screens.each do |screen|
      @windows << NSWindow.alloc.initWithContentRect(screen.frame, styleMask:NSBorderlessWindowMask, backing:NSBackingStoreBuffered, defer:false)
    end
    
    @app_name = NSBundle.mainBundle.infoDictionary['CFBundleDisplayName']

    @status_menu = NSMenu.new
    @status_menu.setAutoenablesItems(true)

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.setHighlightMode(true)

    @status_menu.addItem createMenuItem("About", 'about:')

    change_icon_to_black
    @status_menu.addItem createMenuItem("Quit", 'terminate:', 'q')
    
    @record = createMenuItem("Record", 'record_fullscreen', 'r')
    @status_menu.addItem @record
#    @record_area = createMenuItem("Record Area", 'record_crop', 'R')
#    @status_menu.addItem @record_area   
    
    @stop = createMenuItem("Stop", 'stop', 's')
    setup_mixpanel
  end

  def applicationWillTerminate(notification)
    Mixpanel.sharedInstance.track("App Quit")
  end 

  def setup_mixpanel
    Mixpanel.sharedInstanceWithToken("21055146b12a3f9ae4a2471dd3a856e7")
    mixpanel = Mixpanel.sharedInstance
    mixpanel.identify(Machine.unique_id)
    Mixpanel.sharedInstance.track("App Started")
  end

  def about(sender)
    NSApplication.sharedApplication.activateIgnoringOtherApps(true)
    NSApp.orderFrontStandardAboutPanel(sender)
  end

  def createMenuItem(name, action, key='')
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent:key) 
  end

  def record
    Mixpanel.sharedInstance.track("Recording Started")
    NSLog("Recording Started")
    change_icon_to_red
    @name = NSTemporaryDirectory() + time_stamp_name
    NSLog @name
    @tape = ScreenRecorder.new(@name, self)
    @tape.file_name = @name
    @tape.delegate = self
    @status_menu.addItem(@stop)
    @status_menu.removeItem(@record)
    @tape
  end
  
  def user_video_folder
    "#{NSHomeDirectory()}/Movies/"
  end 
  
  def record_crop
    record.record_crop
  end  
  
  def record_fullscreen
    record.record_fullscreen
  end  

  def stop
    NSLog("Loction Stop")
    @status_menu.removeItem(@stop)
    @status_menu.addItem @record
    change_icon_to_black
    @tape.stop
    change_icon_to_green
  end

  def change_icon_to_green
    icon = NSImage.imageNamed("NSAgent1_green.png")
    @status_item.setImage(icon)
  end

  def change_icon_to_red
    icon = NSImage.imageNamed("NSAgent1_red.png")
    @status_item.setImage(icon)
  end

  def change_icon_to_black
    icon = NSImage.imageNamed("NSAgent1_black.png")
    @status_item.setImage(icon)
  end

  def set_status_bar_to(s)
    @status_item.image= nil
    @status_item.title = s
  end

  def time_stamp_name
    time_stamp + ".mov"
  end

  def time_stamp
    Time.now.to_s.split(" ").join("-")
  end

  def uploaded_succesfull(file_url)
    puts "Ok: #{file_url}"
    NSLog(file_url)
    copy_to_clipboard(file_url)
    play_sound
    delete_file(@name)
    display_notification
    change_icon_to_black
    @status_item.title = nil
  end

  def full_url
    url + @name
  end

  def delete_file(file)
    NSFileManager.defaultManager.removeItemAtPath(file, error:nil)
  end

  def play_sound
    sound = NSSound.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("sound",ofType:"mp3"), byReference:false)
    sound.play
  end

  def copy_to_clipboard(text)
    NSPasteboard.generalPasteboard.clearContents
    NSPasteboard.generalPasteboard.setString(text, forType:NSStringPboardType)
  end

  def display_notification
    notification = NSUserNotification.alloc.init
    notification.title = "Video Uploaded"
    notification.informativeText = "The video link has been copied to your clipboard"
    center = NSUserNotificationCenter.defaultUserNotificationCenter
    center.scheduleNotification(notification)
  end

  def url
    URL.new.host
  end
end

class Persistance

  def initialize(key="videos")
    @key = key
    @p= App::Persistence

    if @p[@key].class != Array
      @p[@key] = []
    end
  end

  def add(url)
    @p[@key] = @p[@key].dup << url
  end

  def values
    @p[@key]
  end

  def remove(url)
    v = values.dup
    v.delete(url)
    @p[@key] = v
  end

end

class Uploader
  attr_accessor :success, :failure, :delegate

  def initialize(delegate)
    @delegate = WeakRef.new(delegate)
  end
  
  def save(file_name)
    BW::HTTP.post(upload_url, { upload_progress: upload_progress, payload: {file: [NSData.dataWithContentsOfFile(file_name)].pack("m0"), file_name: file_name}} ) do |response|
      if response.ok?
        responseString = response.body.to_str
        obj = BW::JSON.parse(responseString)
        delegate.uploaded_succesfull(obj[:file_url])
      else
        failure
      end  
    end  
  end    

  def upload_progress
    lambda do |sending, written, expected|
      p = written * 100 / expected
      delegate.set_status_bar_to("#{p}%")
    end
  end
  
  private
  
  def host
    URL.new.host
  end  
  
  def upload_url
    host + "/upload"
  end  
end  

class URL
  def host
    "http://chalbaud.softwarecriollo.com"
  end
end

class Machine
  def self.unique_id
    u = UniqueIdentifier.new
    u.uniqueIdentifier
  end
end
