//
//  Z3LocationManager.m
//  Z3LocationService_Example
//
//  Created by 童万华 on 2019/6/6.
//  Copyright © 2019 Tony Tony. All rights reserved.
//

#import "Z3LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "Z3SimulatedLocationDataSource.h"
#import "Z3LocationPrivate.h"
@interface Z3LocationManager()<CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *manager;
@property (nonatomic,copy) OnLocationDidChangeListener listener;
@property (nonatomic,strong) Z3LocationDataSource *dataSource;
@end
@implementation Z3LocationManager
+ (instancetype)manager {
    static Z3LocationManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

static double const defaultDistanceFilter = 5.0f;
- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        _manager.distanceFilter = defaultDistanceFilter;
        _manager.allowsBackgroundLocationUpdates = YES;
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
        _manager.pausesLocationUpdatesAutomatically = NO;
        
    }
    return self;
}
#pragma mark - public
- (void)setLocationDataSource:(Z3LocationDataSource *)locationDataSource {
    if ([locationDataSource isKindOfClass:[Z3SimulatedLocationDataSource class]]) {
        [locationDataSource startWithCompletion:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDataSouceDidUpdateLocation:) name:Z3LocationDataSouceDidUpdateLocationNotificationName object:nil];
        [self stopUpdatingLocation];
    }else {
        [self startUpdatingLocation];
        [self.manager startUpdatingHeading];
        [self stop];
    }
     _dataSource = locationDataSource;
}



- (void)stop {
    if ([self.dataSource isKindOfClass:[Z3SimulatedLocationDataSource class]]) {
        [self.dataSource stop];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:Z3LocationDataSouceDidUpdateLocationNotificationName object:nil];
    }else {
      [self stopUpdatingLocation];
    }
    
}

- (void)registerLocationDidChangeListener:(OnLocationDidChangeListener)listener {
    _listener = listener;
}

- (void)locationDataSouceDidUpdateLocation:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CLLocation *location = userInfo[@"message"];
    _location = [location copy];
    if (self.listener) {
        self.listener(location);
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied:
            [self postMessage:@"GPS已被禁用"];
            break;
        case kCLAuthorizationStatusRestricted:
            [self postMessage:@"GPS使用受限制"];
            break;
        case kCLAuthorizationStatusNotDetermined:
            [manager requestWhenInUseAuthorization];
            break;
        default:
            [self startUpdatingLocation];
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    //TODO:数据精度的筛选
     _location = [location copy];
    if (_listener) {
        _listener(location);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
}

#pragma mark - private
- (void)startUpdatingLocation {
    [self.manager startUpdatingLocation];
    [self.manager startUpdatingHeading];
}

- (void)stopUpdatingLocation {
    [self.manager stopUpdatingLocation];
    [self.manager stopUpdatingHeading];
}

- (void)postMessage:(NSString * _Nonnull)message {
    [[NSNotificationCenter defaultCenter] postNotificationName:Z3LocationManagerChangeAuthorizationStatusNotificationName object:nil userInfo:@{Z3LocationManagerUserInfoKey:message}];
}

@end
NSNotificationName Z3LocationManagerChangeAuthorizationStatusNotificationName = @"com.zzht.change.authorization.status";
NSString * const Z3LocationManagerUserInfoKey = @"location.manager.key";

