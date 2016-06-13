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
    NSArray* urls = @[@"http://111.202.98.149/vlive.qqvideo.tc.qq.com/b0020svmj5l.p203.1.mp4?vkey=12B6138BA33FA0D60204548B1927302C3127439FC2A6D4E76B8DD14BE0C9983FC21243F95418B750AD0289F7167C3A035703E98008D18F03267B1BE8A88A55D819F24BBD2BB238A4F9A28753DE190FC27E3C35A3E944253F",
                      @"http://111.202.98.149/vlive.qqvideo.tc.qq.com/b0020svmj5l.p203.1.mp4",
                      @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.1.1.dmg",
                      @"http://pic.mmfile.net/2014/10/09mt05.jpg",
                      @"https://github.com/iosre/iOSAppReverseEngineering/blob/master/iOSAppReverseEngineering.pdf",
                      @"http://image58.360doc.com/DownloadImg/2013/01/0800/29455958_1.png"];
    
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
