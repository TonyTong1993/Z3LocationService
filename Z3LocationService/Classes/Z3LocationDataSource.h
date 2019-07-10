//
//  Z3LocationDataSource.h
//  Z3LocationService_Example
//
//  Created by 童万华 on 2019/7/6.
//  Copyright © 2019 Tony Tony. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Z3LocationDataSource : NSObject
@property (nonatomic, assign, readonly) BOOL started;
@property (nullable, nonatomic, strong, readonly) NSError *error;
-(void)startWithCompletion:(nullable void(^)(NSError *__nullable error))completion;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
