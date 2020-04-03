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
@interface Z3LocationManager()<CLLocationManagerDelegate> {
    CLAuthorizationStatus _lastStatus;//上一次的授权状态
    NSLock *_lock;
}
@property (nonatomic,strong) CLLocationManager *manager;
@property (nonatomic,copy) OnLocationDidChangeListener listener;
@property (nonatomic,copy) OnHeadingDidChangeListener headingListener;
@property (nonatomic,copy) OnAuthorizationStatusDidChangeListener statusListener;
@property (nonatomic,strong) Z3LocationDataSource *dataSource;
@property (nonatomic,copy) void (^complication)(CLLocation *location,NSError *error);
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
        _manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _manager.pausesLocationUpdatesAutomatically = NO;
        _lastStatus = [CLLocationManager authorizationStatus];
        _lock = [[NSLock alloc] init];
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

- (void)registerLocationAuthorizationStatusDidChangeListener:(OnAuthorizationStatusDidChangeListener)listener {
    _statusListener = listener;
}

- (void)registerLocationHeadingDidChangeListener:(OnHeadingDidChangeListener)listener {
    _headingListener = listener;
}

- (void)locationDataSouceDidUpdateLocation:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CLLocation *location = userInfo[@"message"];
    _location = [location copy];
    if (self.listener) {
        self.listener(location);
    }
}

- (void)requestLocation:(void (^)(CLLocation *lcoation,NSError *error))complication {
    self.complication = complication;
    if (@available(iOS 9.0, *)) {
        [_manager requestLocation];
    } else {
        // Fallback on earlier versions
       
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [manager requestWhenInUseAuthorization];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            if (self.singleLocation) {
                if (@available(iOS 9.0, *)) {
                    [manager requestLocation];
                } else {
                    // Fallback on earlier versions
                }
            }else {
                [self startUpdatingLocation];
            }
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            if (self.singleLocation) {
                if (@available(iOS 9.0, *)) {
                    [manager requestLocation];
                } else {
                    // Fallback on earlier versions
                }
            }else {
                [self startUpdatingLocation];
            }
        }
            break;
        default:
            break;
    }
    
    if (status != kCLAuthorizationStatusNotDetermined && _lastStatus != status) {
        if (self.statusListener) {
            self.statusListener(_lastStatus, status);
        }
        _lastStatus = status;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    _location = location;
    [self addlocaion:location];
    if (_listener) {
        _listener(location);
    }
    
    if (self.complication) {
        self.complication(location, nil);
        self.complication = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (self.headingListener) {
        self.headingListener(newHeading.trueHeading);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.complication) {
        self.complication(nil, error);
        self.complication = nil;
    }
}

#pragma mark - private
- (void)startUpdatingLocation {
    [self.manager startUpdatingLocation];
    [self.manager startUpdatingHeading];
    _start = YES;
}

- (void)stopUpdatingLocation {
    [self.manager stopUpdatingLocation];
    [self.manager stopUpdatingHeading];
    _start = NO;
}

@synthesize cache = _cache;
- (NSMutableArray *)cache {
    if (!_cache) {
        _cache = [[NSMutableArray alloc] initWithCapacity:5000];
    }
    return _cache;
}

- (void)addlocaion:(CLLocation *)location{
    [_lock lock];
    [_cache addObject:location];
    [_lock unlock];
}

- (void)removeAllCacheLocations {
    [_lock lock];
    [_cache removeAllObjects];
    [_lock unlock];
}

@end

NSString * const Z3LocationManagerUserInfoKey = @"location.manager.key";

