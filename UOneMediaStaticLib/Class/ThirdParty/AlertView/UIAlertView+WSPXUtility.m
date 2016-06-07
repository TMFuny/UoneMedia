//
//  UIAlertView+WSPXUtility.m
//  NetworkHelper
//
//  Created by 吴昕 on 12/18/15.
//  Copyright © 2015 ChinaNetCenter. All rights reserved.
//

#import "UIAlertView+WSPXUtility.h"

#import "objc/runtime.h"

static char sUserInfoKey;
static char sDidClickedButtonHandlerKey;
static char sCompletion;

@implementation UIAlertView(WSPXUtility)

@dynamic userInfo;
@dynamic didClickedButtonHandler;
@dynamic completion;

- (NSDictionary*)userInfo {
    NSDictionary* dict = objc_getAssociatedObject(self, &sUserInfoKey);
    return dict;
}

- (void)setUserInfo:(NSDictionary *)userInfo {
    objc_setAssociatedObject(self, &sUserInfoKey, userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WSPXAlertDidClickedButtonHandler)didClickedButtonHandler {
    WSPXAlertDidClickedButtonHandler handler = objc_getAssociatedObject(self, &sDidClickedButtonHandlerKey);
    return handler;
}

- (void)setDidClickedButtonHandler:(WSPXAlertDidClickedButtonHandler)handler {
    objc_setAssociatedObject(self, &sDidClickedButtonHandlerKey, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCompletion:(void (^)())completion{
    objc_setAssociatedObject(self, &sCompletion, completion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void (^)())completion{
    return objc_getAssociatedObject(self, &sCompletion);
}

@end
