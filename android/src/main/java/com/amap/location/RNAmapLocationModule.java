
package com.amap.location;

import android.text.TextUtils;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.text.SimpleDateFormat;
import java.util.Locale;

public class RNAmapLocationModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    private ReadableMap mOptions;

    private AMapLocationClient mLocationClient = null;

    DeviceEventManagerModule.RCTDeviceEventEmitter eventEmitter = null;

    public RNAmapLocationModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNAmapLocation";
    }

    @ReactMethod
    public void init(String key) {
        AMapLocationClient.setApiKey(key);
    }

    @ReactMethod
    public void setOptions(ReadableMap options) {
        mOptions = options;
    }

    @ReactMethod
    public void startLocation(ReadableMap options) {
        if (options == null) {
            options = mOptions;
        }
        if(null == eventEmitter){
            eventEmitter = getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class);
        }
        AMapLocationClientOption locationOption = new AMapLocationClientOption();
        //默认是连续定位
        final boolean once = (options.hasKey("once") && (options.getBoolean("once")));
        if (once) {
            //获取一次定位结果：
            //该方法默认为false。
            locationOption.setOnceLocation(true);

            //获取最近3s内精度最高的一次定位结果：
            //设置setOnceLocationLatest(boolean b)接口为true，启动定位时SDK会返回最近3s内精度最高的一次定位结果。如果设置其为true，setOnceLocation(boolean b)接口也会被设置为true，反之不会，默认为false。
            locationOption.setOnceLocationLatest(true);
        } else {
            //设置定位间隔,单位毫秒,默认为2000ms，最低1000ms。
            if (options.hasKey("interval")) {
                locationOption.setInterval(options.getInt("interval"));
            }
        }
        if (options.hasKey("needAddress")) {
            locationOption.setNeedAddress(options.getBoolean("needAddress"));
        }
        if (mLocationClient == null) {
            mLocationClient = new AMapLocationClient(reactContext);
        }
        mLocationClient.setLocationOption(locationOption);
        mLocationClient.setLocationListener(mLocationListener);
        mLocationClient.startLocation();
    }

    @ReactMethod
    public void stopLocation() {
        if (null != mLocationClient) {
            mLocationClient.stopLocation();
        }
    }

    /**
     * 销毁
     */
    @ReactMethod
    public void destroyLocation() {
        if (null != mLocationClient) {
            mLocationClient.stopLocation();
            mLocationClient.unRegisterLocationListener(mLocationListener);
            mLocationClient.onDestroy();
        }
        mLocationClient = null;
    }

    private AMapLocationListener mLocationListener = new AMapLocationListener() {
        @Override
        public void onLocationChanged(AMapLocation location) {
            if (null != location) {
                if(null != eventEmitter){
                    /**
                     * 发送事件到JavaScript
                     * 使用此种方式回调可以持续回调
                     */
                    eventEmitter.emit("AMapLocationChanged", locationToMap(location));
                }
            }
        }
    };

    private ReadableMap locationToMap(AMapLocation location) {
        if (location == null) {
            return null;
        }
        int errorCode = location.getErrorCode();
        WritableMap resultMap = Arguments.createMap();
        resultMap.putString("callbackTime", formatUTC(System.currentTimeMillis(), null));
        if (errorCode == AMapLocation.LOCATION_SUCCESS) {
            resultMap.putInt("code", 0);
            resultMap.putDouble("latitude", location.getLatitude());
            resultMap.putDouble("longitude",location.getLongitude());
            resultMap.putString("locTime", formatUTC(location.getTime(), null));
            if (location.getAddress() != null) {
                resultMap.putString("address", location.getAddress());
            }
            if (location.getCountry() != null) {
                resultMap.putString("country", location.getCountry());
            }
            if (location.getProvince() != null) {
                resultMap.putString("province", location.getProvince());
            }
            if (location.getCity() != null) {
                resultMap.putString("city", location.getCity());
            }
            if (location.getCityCode() != null) {
                resultMap.putString("cityCode", location.getCityCode());
            }
            if (location.getDistrict() != null) {
                resultMap.putString("district", location.getDistrict());
            }
            if (location.getStreet() != null) {
                resultMap.putString("street", location.getStreet());
            }
            if (location.getStreetNum() != null) {
                resultMap.putString("streetNum", location.getStreetNum());
            }
            if (location.getCityCode() != null) {
                resultMap.putString("cityCode", location.getCityCode());
            }
            if (location.getAdCode() != null) {
                resultMap.putString("adCode", location.getAdCode());
            }
            if (location.getPoiName() != null) {
                resultMap.putString("poiName", location.getPoiName());
            }
            if (location.getAoiName() != null) {
                resultMap.putString("aoiName", location.getAoiName());
            }
            if (location.getDescription() != null) {
                resultMap.putString("description", location.getDescription());
            }
        } else {
            resultMap.putInt("code", location.getErrorCode());
            if (location.getErrorInfo() != null) {
                resultMap.putString("errorInfo", location.getErrorInfo());
            }
            if (location.getLocationDetail() != null) {
                resultMap.putString("errorDetail", location.getLocationDetail());
            }
        }
        return resultMap;
    }

    private String formatUTC(long l, String strPattern) {
        if (TextUtils.isEmpty(strPattern)) {
            strPattern = "yyyy-MM-dd HH:mm:ss";
        }
        SimpleDateFormat sdf = new SimpleDateFormat(strPattern, Locale.CHINA);
        return sdf == null ? "NULL" : sdf.format(l);
    }
}
