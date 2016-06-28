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
                      @"http://127.0.0.1:8123/218.60.109.38/ws.cdn.baidupcs.com/file/9f98d5487d7ae04c6b77904a45d509d7?bkt=p2-nj-609&xcode=81c20016744eb6f48af9fa09a99015dd2de3377e2b47984bae97ca166f54709c&fid=436385950-250528-326578814307837&time=1466478005&sign=FDTAXGERLBH-DCb740ccc5511e5e8fedcff06b081203-cXIuFf7r0y2pAjcu7Sc78%2Fbjdg8%3D&to=hc&fm=Nan,B,U,nc&sta_dx=1199&sta_cs=23008&sta_ft=dmg&sta_ct=7&fm2=Nanjing02,B,U,nc&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=14009f98d5487d7ae04c6b77904a45d509d7d1393e5800004aea55ab&sl=69926990&expires=8h&rt=pr&r=197878273&mlogid=3999797028248987998&vuk=436385950&vbdid=700017651&fin=OfficeMac2011sp3.dmg&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=3999797028248987998&dp-callid=0.1.1&wshc_tag=0&wsts_tag=5768adbc&wsid_tag=3a14c18d&wsiphost=ipdbm",
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
