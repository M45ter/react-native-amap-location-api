import {NativeModules, DeviceEventEmitter, Platform} from 'react-native';

const {RNAmapLocation} = NativeModules;

const AMapLocation = {
    init: key => RNAmapLocation.init(Platform.select(key)),
    setOptions: options => RNAmapLocation.setOptions(options),
    startLocation: () => RNAmapLocation.startLocation(),
    stopLocation: () => RNAmapLocation.stopLocation(),
    destroyLocation: () => RNAmapLocation.destroyLocation(),
    addListener: listener =>
        DeviceEventEmitter.addListener("AMapLocationChanged", listener)
};

export default AMapLocation;
