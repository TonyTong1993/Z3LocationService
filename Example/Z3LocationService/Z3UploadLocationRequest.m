//
//  Z3UploadLocationRequest.m
//  Z3LocationService_Example
//
//  Created by 童万华 on 2019/6/7.
//  Copyright © 2019 Tony Tony. All rights reserved.
//

#import "Z3UploadLocationRequest.h"
#import <AFURLResponseSerialization.h>
@implementation Z3UploadLocationRequest
@synthesize responseSerializer = _responseSerializer;
- (AFHTTPResponseSerializer *)responseSerializer {
    if (!_responseSerializer) {
        _responseSerializer = [[AFJSONResponseSerializer alloc] init];
        _responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    }
    return _responseSerializer;
}
@end
