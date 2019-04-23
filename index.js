import {NativeModules, DeviceEventEmitter, Platform} from 'react-native';

const {RNAmapLocation} = NativeModules;

let gOptions = null;

const AMapLocation = {
    init: key => RNAmapLocation.init(Platform.select(key)),
    setOptions: options => {
        gOptions = options;
        RNAmapLocation.setOptions(options)
    },
    startLocation: (options) => RNAmapLocation.startLocation(Object.assign({}, gOptions, options)),
    stopLocation: () => RNAmapLocation.stopLocation(),
    destroyLocation: () => RNAmapLocation.destroyLocation(),
    addListener: listener =>
        DeviceEventEmitter.addListener("AMapLocationChanged", listener)
};

export default AMapLocation;
