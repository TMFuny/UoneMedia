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
    
//    NSArray* urls = @[@"https://qd.myapp.com/myapp/qqteam/AndroidQQ/mobileqq_android.apk",
//                      @"http://sqdd.myapp.com/myapp/qqteam/Androidlite/qqlite_3.4.3.621_android_r108198_GuanWang_537046098_release_10000484.apk",
//                      @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.1.1.dmg",
//                      @"http://pic.mmfile.net/2014/10/09mt05.jpg",
//                      @"https://github.com/iosre/iOSAppReverseEngineering/blob/master/iOSAppReverseEngineering.pdf",
//                      @"http://image58.360doc.com/DownloadImg/2013/01/0800/29455958_1.png"];
    NSArray* urls = @[@"http://mp4.68mtv.com/mp41/56958-%E4%B8%9C%E4%BA%AC%E5%A5%B3%E5%AD%90%E6%B5%81-Neverever[68mtv.com].mp4",
                      @"http://ws.cdn.baidupcs.com/file/5a61aa319fb67eaf2f5cef6929571801?bkt=p3-14005a61aa319fb67eaf2f5cef6929571801dc225bd6000000cfd3d8&xcode=3daf96ad9abfece603b2eaceb35e53defd2795b45dc6f023ae97ca166f54709c&fid=436385950-250528-1103431539532031&time=1466064287&sign=FDTAXGERLBH-DCb740ccc5511e5e8fedcff06b081203-NZhNUYCru%2B9Y7R4dZ5aJi5Nq0y4%3D&to=lc&fm=Nan,B,U,nc&sta_dx=13&sta_cs=55&sta_ft=pdf&sta_ct=6&fm2=Nanjing02,B,U,nc&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=14005a61aa319fb67eaf2f5cef6929571801dc225bd6000000cfd3d8&sl=67829838&expires=8h&rt=pr&r=230195769&mlogid=3888740643505992851&vuk=436385950&vbdid=4168186837&fin=OReilly.Programming.iOS.9.2015.11.pdf&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=3888740643505992851&dp-callid=0.1.1"];
    
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
