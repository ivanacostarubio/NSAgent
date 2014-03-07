# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Chalbaud'
  app.info_plist['LSUIElement'] = true
  app.frameworks += ["AVFoundation"]
  app.icon = "chalboud512.icns"
  app.deployment_target = "10.9"
  app.copyright = "Copyright © 2013 SoftwareCriollo.com."

  app.identifier = "softwarecriollo.chalbaud"

  app.archs['MacOSX'] = ['x86_64']
  app.info_plist['LSUIElement'] = true

  app.entitlements['com.apple.security.app-sandbox'] = true
  app.entitlements['com.apple.security.network.client'] = true
  app.entitlements['com.apple.security.device.microphone'] = true

  app.frameworks += ['IOKit']

  app.vendor_project('vendor/UniqueIdentifier', :static, :cflags => '-fobjc-arc')


  app.release do
    app.codesign_certificate = '3rd Party Mac Developer Application: Bellatrix Martinez (XF3FB883VW)'
  end

  app.pods do |pod|
     pod "Mixpanel-OSX-Community", :git => "https://github.com/orta/mixpanel-osx-unofficial.git"
  end
end
