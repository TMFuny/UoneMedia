//
//  UOneDownloadViewController.h
//  UOneMedia
//
//  Created by wuxin on 5/26/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "UOneDownloadTableViewCell.h"
#import "UoneDownloadToolbar.h"
@class UOneDownloadViewController;

@protocol UoneDownloadViewControllerDelegate <NSObject>

@required
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController canPreviewItem:(BOOL)canPreviewItem;
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController canPresentOptionsMenu:(BOOL)canPresentOptionsMenu;
-(void)downladViewController:(nonnull UOneDownloadViewController *)downloadViewController didClickDeleteButtonWithAlertView:(BOOL)isClickDeleteButton;
@end

@interface UOneDownloadViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UOneDownloadTableViewCellDelegate>

@property (nonnull, nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonnull, nonatomic, strong) IBOutlet UoneDownloadToolbar *fileManagerToolbar;
@property (nonnull, nonatomic, strong) WspxDownloadManager* downloadManager;
@property (nullable, assign) id <UoneDownloadViewControllerDelegate> delegate;
- (void)presentOptionsMenu;
- (void)showAlertViewWithTitle:(nullable NSString*)title
                       message:(nullable NSString*)message
                   cancelTitle:(nullable NSString*)cancelTitle
                  cancelAction:(void(^ __nullable)())cancelBlock
                  confirmTitle:(nullable NSString*)confirmTitle
                 confirmAction:(void(^ __nullable)()) confirmBlock;
@end
