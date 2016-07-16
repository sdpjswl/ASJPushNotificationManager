Pod::Spec.new do |s|
  s.name          = 'ASJPushNotificationManager'
  s.version       = '1.0'
  s.platform      = :ios, '7.0'
  s.license       = { :type => 'MIT' }
  s.homepage      = 'https://github.com/sudeepjaiswal/ASJPushNotificationManager'
  s.authors       = { 'Sudeep Jaiswal' => 'sudeepjaiswal87@gmail.com' }
  s.summary       = 'Super easy setup for push notifications in your iOS app'
  s.source        = { :git => 'https://github.com/sudeepjaiswal/ASJPushNotificationManager.git', :tag => s.version }
  s.source_files  = 'ASJPushNotificationManager/*.{h,m}'
  s.requires_arc  = true
end