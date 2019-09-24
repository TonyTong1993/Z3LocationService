//
//  Z3LocationManager.h
//  Z3LocationService_Example
//
//  Created by 童万华 on 2019/6/6.
//  Copyright © 2019 Tony Tony. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CLLocation,Z3LocationDataSource;
typedef void(^OnLocationDidChangeListener)(CLLocation *location);
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

+ (instancetype)manager;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
-(void)registerLocationDidChangeListener:(OnLocationDidChangeListener)listener;
- (void)setLocationDataSource:(Z3LocationDataSource  * _Nullable )locationDataSource;

/**
 停止位置更新，并保存为同步的位置数据
 */
- (void)stop;
@end
extern NSNotificationName Z3LocationManagerChangeAuthorizationStatusNotificationName;
extern NSString * const Z3LocationManagerUserInfoKey;

NS_ASSUME_NONNULL_END

