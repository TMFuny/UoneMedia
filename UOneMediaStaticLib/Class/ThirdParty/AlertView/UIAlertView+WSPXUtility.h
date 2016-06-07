//
//  UIAlertView+WSPXUtility.h
//  NetworkHelper
//
//  Created by 吴昕 on 12/18/15.
//  Copyright © 2015 ChinaNetCenter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef BOOL (^WSPXAlertDidClickedButtonHandler) (UIAlertView* alertView, NSInteger buttonIndex);

@interface UIAlertView(WSPXUtility)

@property (nonatomic, strong) NSDictionary* userInfo;
@property (nonatomic, strong) WSPXAlertDidClickedButtonHandler didClickedButtonHandler;
@property (nonatomic, strong) void(^completion)();

@end
