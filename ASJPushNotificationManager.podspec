Pod::Spec.new do |s|
  s.name          = 'ASJPushNotificationManager'
  s.version       = '1.2'
  s.platform      = :ios, '10.0'
  s.license       = { :type => 'MIT' }
  s.homepage      = 'https://github.com/sdpjswl/ASJPushNotificationManager'
  s.authors       = { 'Sudeep' => 'sdpjswl1@gmail.com' }
  s.summary       = 'Super easy setup for push notifications in your iOS app'
  s.source        = { :git => 'https://github.com/sdpjswl/ASJPushNotificationManager.git', :tag => s.version }
  s.source_files  = 'ASJPushNotificationManager/*.{h,m}'
  s.requires_arc  = true
end