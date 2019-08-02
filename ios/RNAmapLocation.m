
#import "RNAmapLocation.h"
#import <React/RCTEventEmitter.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <React/RCTBridge.h>
#import <Foundation/Foundation.h>

@interface RNAmapLocation()<AMapLocationManagerDelegate>
    
    @property (nonatomic, strong) AMapLocationManager *locationManager;
    @property (nonatomic, strong) NSDictionary *mOptions;
    
    @end

@implementation RNAmapLocation
    
    RCT_EXPORT_MODULE(RNAmapLocation); //导出桥接类的名称
    
- (dispatch_queue_t)methodQueue
    {
        return dispatch_get_main_queue();
    }
    
    //设置高德地图的可选参数
    RCT_EXPORT_METHOD(setOptions:(NSDictionary *)options) {
        self.mOptions = options;
    }
    
    RCT_EXPORT_METHOD(init:(NSString *)key) {
        [AMapServices sharedServices].apiKey = key;
    }
    
- (void)initLocationManager {
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
}
    
    RCT_EXPORT_METHOD(startLocation:(NSDictionary *)options) {
        if (self.locationManager == nil) {
            [self initLocationManager];
        }
        if (options == nil) {
            options = self.mOptions;
        }
        NSLog(@"locationParams:%@", options);
        //    NSError *jsonError = nil;
        //    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:[locationParams dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&jsonError];
        //逆地理信息默认不开启
        BOOL isReGeocode = NO;
        if (options[@"needAddress"]) {
            isReGeocode = [options[@"needAddress"] boolValue];
        }
        if (options[@"interval"]) {
            self.locationManager.locationTimeout = [options[@"interval"] doubleValue];
        }
        // 带逆地理信息的一次定位（返回坐标和地址信息）
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //   定位超时时间，最低2s，此处设置为10s
        self.locationManager.locationTimeout = 2;
        //   逆地理请求超时时间，最低2s，此处设置为10s
        self.locationManager.reGeocodeTimeout = 2;
        //    self.locationManager.allowsBackgroundLocationUpdates = YES;
        //是否单次定位
        if ([[options objectForKey:@"once"] boolValue]) {
            
            __weak typeof(self) weakSelf = self;
            //调用 AMapLocationManager 的 requestLocationWithReGeocode:completionBlock: 方法，请求一次定位。
            //您可以选择在一次定位时是否返回地址信息（需要联网）。以下是请求带逆地理信息的一次定位，代码如下：
            [self.locationManager requestLocationWithReGeocode:isReGeocode completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                if (error)
                {
                    NSLog(@"error =>%@",error);
                    NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
                    id json = @{
                                
                                @"code": @(error.code),
                                @"errorInfo": error.localizedDescription?error.localizedDescription:@"",
                                };
                    [self sendEventWithName:@"AMapLocationChanged" body: json];
                }
                id json = [self json:location reGeocode:regeocode];
                [weakSelf sendEventWithName:@"AMapLocationChanged" body: json];
                [NSUserDefaults.standardUserDefaults setObject:json forKey:RNAmapLocation.storeKey];
            }];
        } else {
            //如果需要持续定位返回逆地理编码信息，（自 V2.2.0版本起支持）需要做如下设置：
            //SDK中该方法默认为NO。
            [self.locationManager setLocatingWithReGeocode:isReGeocode];
            [self.locationManager stopUpdatingLocation];
            [self.locationManager startUpdatingLocation];
        }
    }
    
    RCT_EXPORT_METHOD(stopLocation) {
        [self.locationManager stopUpdatingLocation];
    }
    
    RCT_EXPORT_METHOD(destroyLocation)
    {
        NSLog(@"destroyLocation");
        if (self.locationManager) {
            self.locationManager.delegate = nil;
            self.locationManager = nil;
        }
    }
    
    //连续定位回调函数.注意：如果实现了本方法，则定位信息不会通过amapLocationManager:didUpdateLocation:方法回调。
    //高德地图的接口，异步获取经纬度和逆地理信息，需要多次定位才能获取逆地理信息
- (void)amapLocationManager:(AMapLocationManager *)manager
          didUpdateLocation:(CLLocation *)location
                  reGeocode:(AMapLocationReGeocode *)reGeocode {
    id json = [self json:location reGeocode:reGeocode];
    [self sendEventWithName:@"AMapLocationChanged" body: json];
    [NSUserDefaults.standardUserDefaults setObject:json forKey:RNAmapLocation.storeKey];
}
    
    //{formattedAddress:浙江省嘉兴市平湖市乍王线虹霓段靠近重型机械厂; country:中国;province:浙江省; city:嘉兴市; district:平湖市; citycode:0573; adcode:330482; street:乍王线虹霓段; number:187号; POIName:重型机械厂; AOIName:(null);}
    //error:(NSError *)error
- (id)json:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode {
    if (reGeocode && reGeocode.formattedAddress.length) {
        return @{
                 @"callbackTime": [self getFormatTime:[NSDate date]],
                 @"code": @(0),
                 @"accuracy": @(location.horizontalAccuracy),
                 @"latitude": @(location.coordinate.latitude),
                 @"longitude": @(location.coordinate.longitude),
                 @"altitude": @(location.altitude),
                 @"speed": @(location.speed),
                 @"direction": @(location.course),
                 @"timestamp": @(location.timestamp.timeIntervalSince1970 * 1000),
                 @"address": reGeocode.formattedAddress?reGeocode.formattedAddress:@"",
                 @"poiName": reGeocode.POIName?reGeocode.POIName:@"",
                 @"country": reGeocode.country?reGeocode.country:@"",
                 @"province": reGeocode.province?reGeocode.province:@"",
                 @"city": reGeocode.city?reGeocode.city:@"",
                 @"cityCode": reGeocode.citycode?reGeocode.citycode:@"",
                 @"district": reGeocode.district?reGeocode.district:@"",
                 @"street": reGeocode.street?reGeocode.street:@"",
                 @"streetNum": reGeocode.number?reGeocode.number:@"", //streetNum
                 @"adCode": reGeocode.adcode?reGeocode.adcode:@"",
                 @"aoiName": reGeocode.AOIName?reGeocode.AOIName:@"",
                 };
    } else {//不返回逆地理信息
        return @{
                 @"callbackTime": [self getFormatTime:[NSDate date]],
                 @"code": @(0),
                 @"latitude": @(location.coordinate.latitude),
                 @"longitude": @(location.coordinate.longitude),
                 @"locTime": [self getFormatTime:location.timestamp],
                 //                 @"accuracy": @(location.horizontalAccuracy),
                 //                 @"altitude": @(location.altitude),
                 //                 @"speed": @(location.speed),
                 //                 @"direction": @(location.course),
                 };
    }
}
    
    //通知名称
- (NSArray<NSString *> *)supportedEvents {
    return @[@"AMapLocationChanged"];
}
    
+ (NSString *)storeKey {
    return @"AMapGeolocation";
}
    
#pragma mark - Delegate
    //持续定位失败
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError:%@", error);
    if (error)
    {
        
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
        id json = @{
                    
                    @"code": @(error.code),
                    @"errorInfo": error.localizedDescription?error.localizedDescription:@"",
                    };
        [self sendEventWithName:@"AMapLocationChanged" body: json];
    }
}
    
    //自 V2.2.0 版本起amapLocationManager:didUpdateLocation:reGeocode:方法可以在回调位置的同时回调逆地理编码信息。请注意，如果实现了amapLocationManager:didUpdateLocation:reGeocode: 回调，将不会再回调amapLocationManager:didUpdateLocation: 方法。
    //持续定位没有reGeocode信息的情况
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
    NSLog(@"didUpdateLocation:%@", location);
    id json = @{
                @"callbackTime": [self getFormatTime:[NSDate date]],
                @"code": @(0),
                @"latitude": @(location.coordinate.latitude),
                @"longitude": @(location.coordinate.longitude),
                @"locTime": [self getFormatTime:location.timestamp],
                };
    
    [self sendEventWithName:@"locationChanged" body:json];
}
    
- (void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"didChangeAuthorizationStatus:%d", status);
}
    
- (NSString *)getFormatTime:(NSDate*)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}
    @end
