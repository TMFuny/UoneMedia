//
//  UOneDownloadViewController.h
//  UOneMedia
//
//  Created by wuxin on 5/26/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "UOneDownloadTableViewCell.h"
@class UoneDownloadToolbar;
@class UOneDownloadViewController;

@protocol UoneDownloadViewControllerDelegate <NSObject>

@required
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController canPreviewItem:(BOOL)canPreviewItem;
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController canPresentOptionsMenu:(BOOL)canPresentOptionsMenu;

@end

@interface UOneDownloadViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UOneDownloadTableViewCellDelegate>

@property (nonnull, nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonnull, nonatomic, strong) IBOutlet UoneDownloadToolbar *fileManagerToolbar;
@property (nonnull, nonatomic, strong) WspxDownloadManager* downloadManager;
@property (nullable, assign) id <UoneDownloadViewControllerDelegate> delegate;
- (void)presentOptionsMenu;
@end
