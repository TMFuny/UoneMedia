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
                      @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.1.1.dmg",
                      @"http://pic.mmfile.net/2014/10/09mt05.jpg",
                      @"https://github.com/iosre/iOSAppReverseEngineering/blob/master/iOSAppReverseEngineering.pdf",
                      @"http://image58.360doc.com/DownloadImg/2013/01/0800/29455958_1.png",
                      @"http://ws.cdn.baidupcs.com/file/b6d125278e59aedd1977995289049061?bkt=p2-nb-515&xcode=ba73353336162bc5a903dd7fccd1f55a0fad082d53ef39bd7f42c5f191c19e11&fid=436385950-250528-383597722136457&time=1466127279&sign=FDTAXGERLBH-DCb740ccc5511e5e8fedcff06b081203-4qKgO%2B3z%2FOcgLDCFaGy4RJ%2BnGaY%3D&to=lc&fm=Nin,B,U,nc&sta_dx=5&sta_cs=43&sta_ft=epub&sta_ct=6&fm2=Ningbo,B,U,nc&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=1400b6d125278e59aedd1977995289049061a12a3b7b00000053473b&sl=82968655&expires=8h&rt=pr&r=648155670&mlogid=3905649790134642953&vuk=436385950&vbdid=700017651&fin=OReilly.Programming.iOS.9.2015.11.epub&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=3905649790134642953&dp-callid=0.1.1"];

    
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
