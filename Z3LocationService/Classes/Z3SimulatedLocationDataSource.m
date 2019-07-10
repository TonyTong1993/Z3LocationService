//
//  Z3SimulatedLocationDataSource.m
//  Z3LocationService_Example
//
//  Created by 童万华 on 2019/7/6.
//  Copyright © 2019 Tony Tony. All rights reserved.
//

#import "Z3SimulatedLocationDataSource.h"
#import "Z3LocationPrivate.h"
@implementation Z3SimulatedLocationDataSource
@synthesize started = _started;
- (void)startWithCompletion:(void (^)(NSError * _Nullable))completion {
    if (!self.locations.count) {
        NSAssert(false, @"模拟数据为空");
        return;
    }
    _started = YES;
    __block NSUInteger index = 0;
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (!self->_started) {
            [timer invalidate];
            timer = nil;
            return;
        }
        NSUInteger count = self.locations.count;
        if (index == count-1) {
            index = 0;
        }else {
            index ++;
        }
        CLLocation *location = self.locations[index];
        [self post:Z3LocationDataSouceDidUpdateLocationNotificationName message:location];
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)stop {
    _started = NO;
}

- (void)post:(NSNotificationName)notificationName message:(id)message {
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"message":message}];
}
@end
