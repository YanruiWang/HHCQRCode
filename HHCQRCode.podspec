Pod::Spec.new do |s|
      s.name         = 'HHCQRCode'
      s.version      = '0.4.1'
      s.summary      = '扫描二维码'
      s.homepage     = ''
      s.authors      = { 'wangyanrui' => 'tieunit@gmail.com'}
      s.license      = { :type => "MIT", :file => "LICENSE" }
      s.platform     = :ios, '9.0'
      s.ios.deployment_target = '9.0'
      s.source       = { :git => '', :tag => '0.1'}
      s.source_files = 'HHCQRCode/lib/*.{swift}','HHCQRCode/lib/Media.xcassets/*.png'
      s.requires_arc = true
    end