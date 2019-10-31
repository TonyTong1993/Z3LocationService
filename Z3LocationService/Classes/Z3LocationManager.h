//
//  Z3LocationManager.h
//  Z3LocationService_Example
//
//  Created by 童万华 on 2019/6/6.
//  Copyright © 2019 Tony Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN
@class Z3LocationDataSource;
typedef void(^OnLocationDidChangeListener)(CLLocation *location);
typedef void(^OnAuthorizationStatusDidChangeListener)(CLAuthorizationStatus fromStatus,CLAuthorizationStatus toStatus);
typedef void(^OnHeadingDidChangeListener)(double heading);

@interface Z3LocationManager : NSObject
/**
 当前位置更新的状态,start:YES时,说明已经开启,NO,说明未开启
 */
@property (nonatomic,readonly,assign) BOOL start;

/**
 开启位置更新失败的error
 */
@property (nonatomic,readonly,strong) NSError *error;

/**
 最近一次更新的位置
 */
@property (nonatomic,strong,readonly) CLLocation *location;

@property (nonatomic,strong,readonly) NSMutableArray *cache;

+ (instancetype)manager;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)removeAllCacheLocations;

/**
 注册位置更新的监听器

 @param listener 监听器
 */
-(void)registerLocationDidChangeListener:(OnLocationDidChangeListener _Nullable)listener;
-(void)registerLocationHeadingDidChangeListener:(OnHeadingDidChangeListener _Nullable)listener;
-(void)registerLocationAuthorizationStatusDidChangeListener:(OnAuthorizationStatusDidChangeListener _Nullable)listener;
- (void)setLocationDataSource:(Z3LocationDataSource  * _Nullable )locationDataSource;

/**
 停止位置更新，并保存为同步的位置数据
 */
- (void)stop;
- (void)startUpdatingLocation;
@end
extern NSString * const Z3LocationManagerUserInfoKey;

NS_ASSUME_NONNULL_END

