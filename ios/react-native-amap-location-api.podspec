Pod::Spec.new do |s|
  s.name         = "react-native-amap-location-api"
  s.version      = "1.0.0"
  s.summary      = "React Native geolocation module for Android + iOS"
  s.license      = { :type => "MIT"}
  s.homepage     = "git+https://github.com/M45ter/react-native-amap-location-api.git"
  s.author       = { "inkcrazy" => "1264140955@qq.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "git+https://github.com/M45ter/react-native-amap-location-api.git" }
# s.source_files  = "RNAmapLocation/**/*.{h,m}"
  s.source_files = '**/*.{h,m}'
  s.dependency 'React'
# 第三方依赖库
  s.dependency 'AMapLocation'

end
