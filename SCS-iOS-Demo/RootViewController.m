//
//  RootViewController.m
//  SCS-iOS-Demo
//
//  Created by Littlebox222 on 14-8-14.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "MBProgressHUD.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

#ifdef __IPHONE_7_0
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [ASIS3Request setSharedSecretAccessKey:kSecretKey];
    [ASIS3Request setSharedAccessKey:kAccessKey];
    
    self.globleNetWorkQueue = [ASINetworkQueue queue];
    [self.globleNetWorkQueue setDelegate:self];
    [self.globleNetWorkQueue setRequestDidFinishSelector:@selector(requestDidFinished:)];
    [self.globleNetWorkQueue setRequestDidFailSelector:@selector(requestDidFailed:)];
    [self.globleNetWorkQueue setRequestDidReceiveResponseHeadersSelector:@selector(requestDidReceivedResponseHeaders:)];
    [self.globleNetWorkQueue setRequestDidStartSelector:@selector(requestDidStarted:)];
    [self.globleNetWorkQueue setRequestWillRedirectSelector:@selector(requestWillRedirect:)];
    [self.globleNetWorkQueue setShouldCancelAllRequestsOnFailure:NO];
    
    [self.globleNetWorkQueue go];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    [self.globleNetWorkQueue cancelAllOperations];
    self.globleNetWorkQueue.delegate = nil;
    [self.globleNetWorkQueue release];
    
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        cell.backgroundColor = self.tableView.backgroundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Create Bucket";
        }else if (indexPath.row == 1) {
            cell.textLabel.text = @"Delete Bucket";
        }else if (indexPath.row == 2) {
            cell.textLabel.text = @"List Buckets";
        }else if (indexPath.row == 3) {
            cell.textLabel.text = @"GET Bucket ACL";
        }else if (indexPath.row == 4) {
            cell.textLabel.text = @"PUT Bucket ACL";
        }else if (indexPath.row == 5) {
            cell.textLabel.text = @"GET Bucket Meta";
        }else if (indexPath.row == 6) {
            cell.textLabel.text = @"List Objects";
        }else if (indexPath.row == 7) {
            cell.textLabel.text = @"Upload Object";
        }else if (indexPath.row == 8) {
            cell.textLabel.text = @"Download Object";
        }else if (indexPath.row == 9) {
            cell.textLabel.text = @"Copy Object";
        }else if (indexPath.row == 10) {
            cell.textLabel.text = @"Delete Object";
        }else if (indexPath.row == 11) {
            cell.textLabel.text = @"GET Object ACL";
        }else if (indexPath.row == 12) {
            cell.textLabel.text = @"PUT Object ACL";
        }else if (indexPath.row == 13) {
            cell.textLabel.text = @"GET Object Meta";
        }else if (indexPath.row == 14) {
            cell.textLabel.text = @"PUT Object Meta";
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    if (indexPath.row == 0) {
        
        ASIS3BucketRequest *request = [ASIS3BucketRequest PUTRequestWithBucket:kUserTestBucketCreate];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"Create Bucket" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 1) {
        
        ASIS3BucketRequest *request = [ASIS3BucketRequest DELETERequestWithBucket:kUserTestBucketCreate];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"Delete Bucket" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 2) {
        
        ASIS3ServiceRequest *request = [ASIS3ServiceRequest serviceRequest];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"List Buckets" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 3) {
        
        ASIS3BucketRequest *request = [ASIS3BucketRequest requestForAclWithBucket:kUserTestBucketCreate];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"GET Bucket ACL" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 4) {
        
        ASIS3BucketRequest *request = [ASIS3BucketRequest PUTRequestWithBucket:kUserTestBucketCreate acl:@{@"SINA0000000123456789":@[@"read", @"read_acp" , @"write", @"write_acp" ]}];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"PUT Bucket ACL" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 5) {
        
        ASIS3BucketRequest *request = [ASIS3BucketRequest requestForMetaWithBucket:kUserTestBucketCreate];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"GET Bucket Meta" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 6) {
        
        ASIS3BucketRequest *request = [ASIS3BucketRequest requestWithBucket:kUserTestBucketCreate];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"List Objects" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 7) {
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
        ASIS3ObjectRequest *request = [ASIS3ObjectRequest PUTRequestForFile:filePath
                                                                 withBucket:kUserTestBucketCreate
                                                                        key:[filePath lastPathComponent]];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"Upload Object" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 8) {
        
        ASIS3ObjectRequest *request = [ASIS3ObjectRequest requestWithBucket:kUserTestBucketCreate key:@"test.png"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *downloadPath = [NSString stringWithFormat:@"%@/test.png", documentsDirectory];
        [request setDownloadDestinationPath:downloadPath];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"Download Object" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 9) {
        
        ASIS3ObjectRequest *request = [ASIS3ObjectRequest COPYRequestFromBucket:kUserTestBucketCreate
                                                                            key:@"test.png"
                                                                       toBucket:kUserTestBucketCreate
                                                                            key:@"test_copy.png"];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"Copy Object" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 10) {
        
        ASIS3ObjectRequest *request = [ASIS3ObjectRequest DELETERequestWithBucket:kUserTestBucketCreate key:@"test.png"];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"Delete Object" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 11) {
        
        ASIS3ObjectRequest *request = [ASIS3ObjectRequest requestForAclWithBucket:kUserTestBucketCreate key:@"test.png"];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"GET Object ACL" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 12) {
        
        ASIS3ObjectRequest *request = [ASIS3ObjectRequest PUTRequestWithBucket:kUserTestBucketCreate key:@"test.png" acl:@{@"SINA0000000123456789":@[@"read", @"read_acp" , @"write", @"write_acp" ]}];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"PUT Object ACL" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 13) {
        
        ASIS3ObjectRequest *request = [ASIS3ObjectRequest requestForMetaWithBucket:kUserTestBucketCreate key:@"test.png"];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"GET Object Meta" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }else if (indexPath.row == 14) {
        
        ASIS3ObjectRequest *request = [ASIS3ObjectRequest PUTRequestWithBucket:kUserTestBucketCreate key:@"test.png" meta:@{@"testMetaKey":@"testMetaValue"}];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"PUT Object Meta" forKey:@"requestKind"]];
        [self.globleNetWorkQueue addOperation:request];
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma - ASINetworkQueueDelegate

- (void)requestDidFinished:(ASIS3Request *)request {
    
    NSString *requestKind = [[request userInfo] valueForKey:@"requestKind"];
    
    if ([requestKind isEqualToString:@"Create Bucket"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"创建成功" duration:1.5];
        NSLog(@"%@ created", [(ASIS3BucketRequest *)request bucket]);
    }
    
    if ([requestKind isEqualToString:@"Delete Bucket"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"删除成功" duration:1.5];
        NSLog(@"%@ deleted", [(ASIS3BucketRequest *)request bucket]);
    }
    
    if ([requestKind isEqualToString:@"List Buckets"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"列取成功" duration:1.5];
        
        NSArray *buckets = [(ASIS3ServiceRequest *)request buckets];
        NSLog(@"%@", buckets);
    }
    
    if ([requestKind isEqualToString:@"GET Bucket ACL"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"列取成功" duration:1.5];
        NSLog(@"%@", [(ASIS3BucketRequest *)request responseDictionary]);
    }
    
    if ([requestKind isEqualToString:@"PUT Bucket ACL"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"设置成功" duration:1.5];
    }
    
    if ([requestKind isEqualToString:@"GET Bucket Meta"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"列取成功" duration:1.5];
        NSLog(@"%@", [(ASIS3BucketRequest *)request responseDictionary]);
    }
    
    if ([requestKind isEqualToString:@"List Objects"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"列取成功" duration:1.5];
        
        NSArray *objects = [(ASIS3BucketRequest *)request objects];
        NSLog(@"%@", objects);
    }
    
    if ([requestKind isEqualToString:@"Upload Object"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"上传成功" duration:1.5];
        NSLog(@"%@ uploaded", [(ASIS3ObjectRequest *)request key]);
    }
    
    if ([requestKind isEqualToString:@"Download Object"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"下载成功" duration:1.5];
        NSLog(@"%@ downloaded", [(ASIS3ObjectRequest *)request key]);
        NSLog(@"%@", [(ASIS3ObjectRequest *)request downloadDestinationPath]);
    }
    
    if ([requestKind isEqualToString:@"Copy Object"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"拷贝成功" duration:1.5];
        NSLog(@"%@ copied to %@", [(ASIS3ObjectRequest *)request sourceKey], [(ASIS3ObjectRequest *)request key]);
    }
    
    if ([requestKind isEqualToString:@"Delete Object"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"删除成功" duration:1.5];
        NSLog(@"%@ deleted", [(ASIS3ObjectRequest *)request key]);
    }
    
    if ([requestKind isEqualToString:@"GET Object ACL"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"列取成功" duration:1.5];
        NSLog(@"%@", [(ASIS3ObjectRequest *)request responseDictionary]);
    }
    
    if ([requestKind isEqualToString:@"PUT Object ACL"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"设置成功" duration:1.5];
    }
    
    if ([requestKind isEqualToString:@"GET Object Meta"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"列取成功" duration:1.5];
        NSLog(@"%@", [(ASIS3ObjectRequest *)request responseDictionary]);
    }
    
    if ([requestKind isEqualToString:@"PUT Object Meta"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"设置成功" duration:1.5];
    }
    
    NSLog(@"===== <%@>  finished", requestKind);
}

- (void)requestDidFailed:(ASIS3Request *)request {
    
    NSString *requestKind = [[request userInfo] valueForKey:@"requestKind"];
    
    if ([requestKind isEqualToString:@"Create Bucket"]) {
        
        [MBProgressHUD showErrorHUDAddedTo:self.navigationController.view text:@"创建失败" duration:1.5];
        NSLog(@"%@", [(ASIS3BucketRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"Delete Bucket"]) {
        
        [MBProgressHUD showErrorHUDAddedTo:self.navigationController.view text:@"删除失败" duration:1.5];
        NSLog(@"%@", [(ASIS3BucketRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"List Buckets"]) {
        
        [MBProgressHUD showErrorHUDAddedTo:self.navigationController.view text:@"列取失败" duration:1.5];
        NSLog(@"%@", [(ASIS3ServiceRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"GET Bucket ACL"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"列取失败" duration:1.5];
        NSLog(@"%@", [(ASIS3BucketRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"PUT Bucket ACL"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"设置失败" duration:1.5];
        NSLog(@"%@", [(ASIS3BucketRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"GET Bucket Meta"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"列取失败" duration:1.5];
        NSLog(@"%@", [(ASIS3BucketRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"List Objects"]) {
        
        [MBProgressHUD showErrorHUDAddedTo:self.navigationController.view text:@"列取失败" duration:1.5];
        NSLog(@"%@", [(ASIS3BucketRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"Upload Object"]) {
        
        [MBProgressHUD showErrorHUDAddedTo:self.navigationController.view text:@"上传失败" duration:1.5];
        NSLog(@"%@", [(ASIS3ObjectRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"Download Object"]) {
        
        [MBProgressHUD showErrorHUDAddedTo:self.navigationController.view text:@"下载失败" duration:1.5];
        NSLog(@"%@", [(ASIS3ObjectRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"Copy Object"]) {
        
        [MBProgressHUD showErrorHUDAddedTo:self.navigationController.view text:@"拷贝失败" duration:1.5];
        NSLog(@"%@", [(ASIS3ObjectRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"Delete Object"]) {
        
        [MBProgressHUD showErrorHUDAddedTo:self.navigationController.view text:@"删除失败" duration:1.5];
        NSLog(@"%@", [(ASIS3ObjectRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"GET Object ACL"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"列取失败" duration:1.5];
        NSLog(@"%@", [(ASIS3ObjectRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"PUT Object ACL"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"设置失败" duration:1.5];
        NSLog(@"%@", [(ASIS3ObjectRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"GET Object Meta"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"列取失败" duration:1.5];
        NSLog(@"%@", [(ASIS3ObjectRequest *)request error]);
    }
    
    if ([requestKind isEqualToString:@"PUT Object Meta"]) {
        
        [MBProgressHUD showSuccessHUDAddedTo:self.navigationController.view text:@"设置失败" duration:1.5];
        NSLog(@"%@", [(ASIS3ObjectRequest *)request error]);
    }
    
    NSLog(@"===== <%@>  failed", requestKind);
}

- (void)requestDidReceivedResponseHeaders:(ASIS3Request *)request {
    
}

- (void)requestDidStarted:(ASIS3Request *)request {
    
    NSString *requestKind = [[request userInfo] valueForKey:@"requestKind"];
    NSLog(@"===== <%@>  started", requestKind);
}

- (void)requestWillRedirect:(ASIS3Request *)request {
    
}

@end
