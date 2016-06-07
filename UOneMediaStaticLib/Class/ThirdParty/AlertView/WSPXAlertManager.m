//
//  WSPXAlertManager.m
//  NetworkHelper
//
//  Created by 吴昕 on 12/18/15.
//  Copyright © 2015 ChinaNetCenter. All rights reserved.
//

#import "WSPXAlertManager.h"

@interface WSPXAlertManager () <UIAlertViewDelegate>

@end

@implementation WSPXAlertManager {
    NSMutableArray* _alertList;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _alertList = [NSMutableArray new];
    }
    return self;
}


- (void)push:(UIAlertView*)alertView {
    [_alertList addObject:alertView];
    if ([_alertList count] == 1) {
        [self show];
    }
}

- (void)pop:(UIAlertView *)alertView {
    [_alertList removeObject:alertView];
}

- (void)show {
    if ([_alertList count] <= 0) {
        return;
    }
    UIAlertView* alert = [_alertList objectAtIndex:0];
    [_alertList removeObjectAtIndex:0];
    alert.delegate = self;
    [alert show];
}

#pragma mark - UIAlertViewDelegate 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL fResult = NO;
    WSPXAlertDidClickedButtonHandler handler = alertView.didClickedButtonHandler;
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];  //防止有时点击按钮需要跳转时，会崩溃的问题。 v2.1.7 by zsx
    if (handler) {
        fResult = handler(alertView, buttonIndex);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self show];
}
- (void)alertViewCancel:(UIAlertView *)alertView {
    [self show];
}
@end
