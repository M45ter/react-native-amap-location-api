// import {NativeModules, DeviceEventEmitter, Platform} from 'react-native';
// const {RNAmapLocation} = NativeModules;

import { NativeModules, NativeEventEmitter, Platform } from "react-native"
const { RNAmapLocation } = NativeModules
const eventEmitter = new NativeEventEmitter(RNAmapLocation)

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
        eventEmitter.addListener("AMapLocationChanged", listener)
};

export default AMapLocation;
