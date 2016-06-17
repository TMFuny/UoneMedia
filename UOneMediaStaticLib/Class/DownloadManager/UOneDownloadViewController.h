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

@optional
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController isComfirmToDeleteDownloads:(BOOL)isConfirmToDelete;

-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController didClickToolBarForEdit:(nonnull UoneDownloadToolbar *)toolBar;//编辑按钮
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController DidClickToolBarForDone:(nonnull UoneDownloadToolbar *)toolBar;//完成按钮
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController DidClickToolBarForSelectAll:(nonnull UoneDownloadToolbar *)toolBar;//全选按钮
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController DidClickToolBarForDelete:(nonnull UoneDownloadToolbar *)toolBar;//删除按钮

-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController didClickCellForDelete:(nonnull NSIndexPath *)aIndexPath;//删除
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController didClickCellForPreview:(nonnull NSIndexPath *)aIndexPath;//预览


-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController didClickDownloadItemForPause:(nonnull WspxDownloadItem *)aDownloadItem;//暂停下载
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController didClickDownloadItemForStart:(nonnull WspxDownloadItem *)aDownloadItem;//开始下载
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController didClickDownloadItemForResume:(nonnull WspxDownloadItem *)aDownloadItem;//继续下载

@end

@protocol UoneDownloadViewControllerDataSource <NSObject>

@optional
// -downloadViewController:shouldPauseForDownloadItem: is called when a pause touch comes down on a downloadItem.
// Returning NO to do nothing
//          YES to pause current downloadItem.
- (BOOL)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController shouldPauseForDownloadItem:(nonnull WspxDownloadItem *)aDownloadItem; //是否需要暂停

@end

@interface UOneDownloadViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UOneDownloadTableViewCellDelegate>

@property (nonnull, nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonnull, nonatomic, strong) IBOutlet UoneDownloadToolbar *fileManagerToolbar;
@property (nonnull, nonatomic, strong) WspxDownloadManager* downloadManager;
@property (nullable, assign) id <UoneDownloadViewControllerDelegate> delegate;
@property (nullable, assign) id <UoneDownloadViewControllerDataSource> dataSource;
- (void)presentOptionsMenu;
- (void)showAlertViewWithTitle:(nullable NSString*)title
                       message:(nullable NSString*)message
                   cancelTitle:(nullable NSString*)cancelTitle
                  cancelAction:(void(^ __nullable)())cancelBlock
                  confirmTitle:(nullable NSString*)confirmTitle
                 confirmAction:(void(^ __nullable)()) confirmBlock;
@end
