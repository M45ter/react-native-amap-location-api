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

[example]: https://github.com/M45ter/react-native-amap-location-api/tree/master/examples

## API

### <a name="init">init(key)</a>

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