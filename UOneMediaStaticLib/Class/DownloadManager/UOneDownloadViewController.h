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

-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController failedToPreviewItem:(nonnull WspxDownloadItem *)aDownloadItem;
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController failedToPresentOptionsMenu:(nonnull WspxDownloadItem *)aDownloadItem;

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

-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController dealWithNetworkNotReachableWhenResumeDownloadItem:(nonnull WspxDownloadItem *)aDownloadItem;
-(void)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController dealWithNetworkNotReachableWhenStartDownloadItem:(nonnull WspxDownloadItem *)aDownloadItem;
@end

@protocol UoneDownloadViewControllerDataSource <NSObject>

@required
- (BOOL)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController shouldPreviewForDownloadItem:(nonnull WspxDownloadItem *)aDownloadItem; //是否需要支持app内预览
- (BOOL)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController shouldOpenOptionsMenuForDownloadItem:(nonnull WspxDownloadItem *)aDownloadItem;//是否显示使用其他应用的
@optional
// -downloadViewController:shouldPauseForDownloadItem: is called when a pause touch comes down on a downloadItem.
// Returning NO to do nothing
//          YES to pause current downloadItem.
- (BOOL)downloadViewController:(nonnull UOneDownloadViewController *)downloadViewController shouldPauseForDownloadItem:(nonnull WspxDownloadItem *)aDownloadItem; //是否需要暂停

//-downloadViewControllerShouldAutoChangeUserInterfaceWithReachabilityStatusChange: is called when device network Reachability Status Changed.
// returning NO to do nothing.
//           YES to auto dealwith netowork reachability status changed.
// if you return NO, maby you want use those method to dealwith network status changed.
//      - (void)disableUserInterfaceWithNetworkNotReachable;
//      - (void)enableUserInterfaceWithNetworkReachable;
- (BOOL)downloadViewControllerShouldAutoChangeUserInterfaceWithReachabilityStatusChange:(nonnull UOneDownloadViewController *)downloadViewController;

//-downloadViewControllerShouldDownloadingWithReachabilityReachable: is called when user touch item for start/resum download.
// return NO to custom the behaviour after user touched.
//        YES will start/resum downloading item after user touched.
// default start/resum downloading item after user touched.
- (BOOL)downloadViewControllerShouldDownloadingWithReachabilityReachable:(nonnull UOneDownloadViewController *)downloadViewController;
@end

@interface UOneDownloadViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UOneDownloadTableViewCellDelegate>

@property (nonatomic, assign, readonly) BOOL isUserInterfaceEnable;
@property (nonnull, nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonnull, nonatomic, strong) IBOutlet UoneDownloadToolbar *fileManagerToolbar;
@property (nonnull, nonatomic, strong) WspxDownloadManager* downloadManager;
@property (nullable, assign) id <UoneDownloadViewControllerDelegate> delegate;
@property (nullable, assign) id <UoneDownloadViewControllerDataSource> dataSource;

- (void)presentOptionsMenu;
- (void)disableUserInterfaceWithNetworkNotReachable;
- (void)enableUserInterfaceWithNetworkReachable;

- (void)showAlertViewWithTitle:(nullable NSString*)title
                       message:(nullable NSString*)message
                   cancelTitle:(nullable NSString*)cancelTitle
                  cancelAction:(void(^ __nullable)())cancelBlock
                  confirmTitle:(nullable NSString*)confirmTitle
                 confirmAction:(void(^ __nullable)()) confirmBlock
            systemDefaultStyle:(BOOL)issystemDefaultStyle;
@end
