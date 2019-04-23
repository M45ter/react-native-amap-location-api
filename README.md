# 开发中，未发布...

# react-native-amap-location-api

## Getting started

`$ npm install react-native-amap-location-api --save`

### Mostly automatic installation

`$ react-native link react-native-amap-location-api`


## Usage

```javascript
import AMapLocation from 'react-native-amap-location-api';

// TODO: What to do with the module?
AMapLocation;
```
调用<a href="#init">init</a>

## API

### <a name="init">init(key)</a>

设置高德地图的key，key自行从官网注册，与app绑定

```javascript
AMapLocation.init({
    ios: "044a3fc11ceee93e3c539c303eff8394",
    android: "428caa9eaeb37090d2320b48d760c142"
});
```

