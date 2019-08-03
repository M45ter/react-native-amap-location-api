# react-native-amap-location-api

## Getting started

`$ npm install react-native-amap-location-api --save`

### Mostly automatic installation

`$ react-native link react-native-amap-location-api`

### iOS手动配置(link完毕之后)
1.手动删除react-native-amap-location-api库link到项目目录文件Libraries下到RNAmapLocation.xcodeproj

2.build setting -> search 'Header Search Path' 删除$(SRCROOT)/../node_modules/react-native-amap-location-api/ios

3.cd 项目目录

4.pod init（只能使用Pod安装）

5.拷贝如下代码

```angular2
platform :ios, '9.0'

# The target name is most likely the name of your project.
target '你的项目名称' do

# Your 'node_modules' directory is probably in the root of your project,
# but if not, adjust the `:path` accordingly
pod 'React', :path => '../node_modules/react-native', :subspecs => [
'Core',
'CxxBridge', # Include this for RN >= 0.47
'DevSupport', # Include this to enable In-App Devmenu if RN >= 0.43
'RCTText',
'RCTNetwork',
'RCTWebSocket', # Needed for debugging
'RCTAnimation', # Needed for FlatList and animations running on native UI thread
# Add any other subspecs you want to use in your project
]
# Explicitly include Yoga if you are using RN >= 0.42.0
pod 'yoga', :path => '../node_modules/react-native/ReactCommon/yoga'

# Third party deps podspec link
pod 'DoubleConversion', :podspec => '../node_modules/react-native/third-party-podspecs/DoubleConversion.podspec'
pod 'glog', :podspec => '../node_modules/react-native/third-party-podspecs/glog.podspec'
pod 'Folly', :podspec => '../node_modules/react-native/third-party-podspecs/Folly.podspec'

pod 'react-native-amap-location-api', path: '../node_modules/react-native-amap-location-api/ios'

end

# 解决问题：[!] [Xcodeproj] Generated duplicate UUIDs
# 链接： https://github.com/CocoaPods/CocoaPods/issues/4370
install! 'cocoapods', :deterministic_uuids => false
```

## Usage

```javascript
import AMapLocation from 'react-native-amap-location-api';

// TODO: What to do with the module?
AMapLocation;
```

[example](https://github.com/M45ter/react-native-amap-location-api/tree/master/examples)

## API

### init(key)

设置高德地图的key，key自行从官网注册，与app绑定

```javascript
AMapLocation.init({
    ios: "your ios key",
    android: "your android key"
});
```

## setOptions(options)

设置全局可配置参数

```javascript
AMapLocation.setOptions({
    once: true,
    needAddress: true,
    interval: 2000
});
type options = {
    once?: boolean, // 是否是单次定位
    needAddress?: boolean, // 是否需要地址信息 
    interval?: number //多次定位时间间隔ms
}
```

## startLocation(options)

开始定位，options不给时使用全局默认参数，有options参数时，会和全局配置参数合并，同名属性以本方法参数覆盖

## stopLocation()

停止定位，连续定位时，需要自行调用来停止定位，单次定位会自行停止

## destroyLocation()

销毁定位，可在不使用定位后调用，销毁定位的资源

## addListener(listener)

增加监听器，获取定位结果信息

```javascript
this.geoListener = AMapLocation.addListener(location => {
        this.locationListener(location);
    }
)
locationListener(location) {
    // todo something
}
// 注意不需要监听定位结果时移除listenner，否则定位销毁前，所有注册过的listener都会收到定位结果
this.geoListener.remove();
```
