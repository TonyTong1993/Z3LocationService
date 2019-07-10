//
//  Z3ViewController.m
//  Z3LocationService
//
//  Created by Tony Tony on 05/10/2019.
//  Copyright (c) 2019 Tony Tony. All rights reserved.
//

#import "Z3ViewController.h"
#import <Z3LocationService/Z3LocationService.h>
#import <Z3DBService/Z3DBService.h>
#import <Z3Network/Z3BaseResponse.h>
#import "Z3UploadLocationRequest.h"
#import "Z3UploadLocationRequest.h"
@interface Z3ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation Z3ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.19930313
    self.tableView.rowHeight = 60.0f;
    
    [[Z3LocationManager manager] registerLocationDidChangeListener:^(CLLocation * _Nonnull location) {
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    NSString *title = [NSString stringWithFormat:@"test ------ %ld",(long)indexPath.row];
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)startReportTimer {
    dispatch_queue_t queue =dispatch_queue_create("com.zzht.report.location.queue", NULL);
    dispatch_async(queue, ^{
        __weak typeof(self) weakSelf = self;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf reportLocations];
        }];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)reportLocations {
    NSArray *caches = nil;
    Z3LocationBeanFactory *factory = [Z3LocationBeanFactory factory];
//    if (self.producer) {
//        @synchronized (self) {
//            caches = [self.producer.locationCache copy];
//            [self.producer.locationCache removeAllObjects];
//        }
//    }else {
//        [[Z3LocationManager manager].lock lock];
//        caches = [[Z3LocationManager manager].locationCaches copy];
//        [[Z3LocationManager manager].locationCaches removeAllObjects];
//        [[Z3LocationManager manager].lock unlock];
//       
//    }
//    if (caches.count > 0) {
//        NSArray *beans = [factory buildLocationBeansWithCLLocations:caches];
//        [[Z3DBManager manager] saveLocationBeans:beans];
//        NSString *json = [factory convert2JSONWithLocationBeans:beans];
//        [self uploadLocation2Server:json data:beans];
//    
//    }
    
}

- (void)uploadLocation2Server:(NSString *)json data:(NSArray *)data {
    NSDictionary *param = @{@"pospackage":json,@"userID":@(2)};
    Z3UploadLocationRequest *request = [[Z3UploadLocationRequest alloc] initWithRelativeToURL:@"rest/patrolService/reportPosition" method:POST parameter:param success:^(__kindof Z3BaseResponse * _Nonnull response) {
        NSDictionary *jsonDic = response.responseJSONObject;
        BOOL success = [jsonDic[@"isSuccess"] boolValue];
        if (success) {
            [data setValue:@(1) forKey:@"status"];
            [[Z3DBManager manager] updateSyncLocationBeans:data];
        }
        
    } failure:^(__kindof Z3BaseResponse * _Nonnull response) {
            //TODO: 处理上传失败
        NSString *error = [response.error localizedDescription];
        NSLog(@"error = %@",error);
    }];
    
    [request start];
}

@end

