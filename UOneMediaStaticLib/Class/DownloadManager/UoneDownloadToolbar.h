//
//  UoneDownloadToolbar.h
//  UOneMedia
//
//  Created by MrChens on 16/6/6.
//  Copyright © 2016年 chiannetcenter. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UoneDownloadToolbar;
@protocol UoneDownloadToolbarDelegate <NSObject>

- (void)uoneDownloadToolbar:(UoneDownloadToolbar*)toolbar didClickedEditButton:(UIButton*)button;
- (void)uoneDownloadToolbar:(UoneDownloadToolbar*)toolbar didClickedDoneButton:(UIButton*)button;
- (void)uoneDownloadToolbar:(UoneDownloadToolbar*)toolbar didClickedSelectAllButton:(UIButton*)button;
- (void)uoneDownloadToolbar:(UoneDownloadToolbar*)toolbar didClickedDeleteButton:(UIButton*)button;

@end

@interface UoneDownloadToolbar : UIToolbar
@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) BOOL isLabelMode;
@property (strong, nonatomic) UIButton *selectAllButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UILabel *diskUsageAndStorageLabel;
@property (weak, nonatomic) id<UoneDownloadToolbarDelegate> customedDelegate;

-(void)layout;
-(void)setDeleteTitle:(NSString*)deleteTitle;
@end
