//
//  ViewController.m
//  UOneMediaApp
//
//  Created by wuxin on 5/26/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import "ViewController.h"
#import "UOneMedia.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) onReset:(UIButton *)button {
    [self.deleteButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    NSArray* urls = @[@"https://qd.myapp.com/myapp/qqteam/AndroidQQ/mobileqq_android.apk",
                      @"http://sqdd.myapp.com/myapp/qqteam/Androidlite/qqlite_3.4.3.621_android_r108198_GuanWang_537046098_release_10000484.apk",
                      @"http://rpcs.myapp.com/myapp/rcps/d/10000848/qqreader_5.11.0.888_android_r235278_20160614162009_common-release_10000848_160617115936a.apk",
                      @"http://123.103.23.204:8000/staticresource/static/downloadtest/test.rmvb",
                      @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.1.1.dmg",
                      @"http://pic.mmfile.net/2014/10/09mt05.jpg",
                      @"http://mp4.68mtv.com/mp46/%E6%9B%BE%E6%98%A5%E5%B9%B4-%E5%8F%AB%E4%BD%A0%E4%B8%80%E5%A3%B0%E8%80%81%E5%A9%86dj[68mtv.com].mp4",
                      @"http://123.103.23.204:8000/staticresource/static/downloadtest/test.txt"];

    
    [urls enumerateObjectsUsingBlock: ^(NSString* obj, NSUInteger idx, BOOL *stop) {
        NSURL* url = [NSURL URLWithString:obj];
        NSString* identifier = [NSString stringWithFormat:@"DownloadItem_%lu", (unsigned long)idx];
        WspxDownloadItem* item = [[WspxDownloadItem alloc ]initWithDownloadIdentifier:identifier
                                                                            remoteURL: url];
        [[WspxDownloadManager shareInstance].downloadItems addObject:item];
  //    [_downloadManager startDownloadWithItem:item];
    }];

}

- (IBAction) onDelete:(UIButton *)button {
    
    [[WspxDownloadManager shareInstance] cancelAllDownloadItems];
    
    [[WspxDownloadManager shareInstance] removeAllDownloadItems];
}

- (IBAction) onNavigate:(UIButton *)button {
    
    UOneDownloadViewController* controller = [UOneDownloadViewController new];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (IBAction)onDownloadAllItem:(UIButton *)sender {
    [self onDelete:nil];
    [self onReset:nil];
    if ([[WspxDownloadManager shareInstance] downloadItems] && [[[WspxDownloadManager shareInstance] downloadItems] count] != 0) {
        for (WspxDownloadItem *item in [[WspxDownloadManager shareInstance] downloadItems]) {
            [[WspxDownloadManager shareInstance] startDownloadWithItem:item];
        }
        [self onNavigate:nil];
    }
}
@end
