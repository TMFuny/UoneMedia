//
//  WSPXAlertManager.h
//  NetworkHelper
//
//  Created by 吴昕 on 12/18/15.
//  Copyright © 2015 ChinaNetCenter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIAlertView+WSPXUtility.h"

@interface WSPXAlertManager : NSObject

- (instancetype)init;

- (void)push:(UIAlertView*)alertView;

- (void)pop:(UIAlertView*)alertView;

- (void)show;

@end
