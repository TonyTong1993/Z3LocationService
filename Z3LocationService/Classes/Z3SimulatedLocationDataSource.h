//
//  Z3SimulatedLocationDataSource.h
//  Z3LocationService_Example
//
//  Created by 童万华 on 2019/7/6.
//  Copyright © 2019 Tony Tony. All rights reserved.
//

#import "Z3LocationDataSource.h"

NS_ASSUME_NONNULL_BEGIN
@class CLLocation;
@interface Z3SimulatedLocationDataSource : Z3LocationDataSource
@property (nullable, nonatomic, copy) NSArray<CLLocation*> *locations;
@end

NS_ASSUME_NONNULL_END
