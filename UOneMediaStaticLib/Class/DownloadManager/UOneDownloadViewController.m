//
//  UOneDownloadViewController.m
//  UOneMedia
//
//  Created by wuxin on 5/26/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import "WspxDownloadManager.h"
#import "WspxDownloadItem.h"

#import "UOneDownloadViewController.h"
#import "UOneDownloadTableViewCell.h"
#import <QuickLook/QuickLook.h>
#import "NSBundle+WspxUtility.h"
#import "UoneDownloadToolbar.h"

@interface UOneDownloadViewController ()<QLPreviewControllerDataSource,
QLPreviewControllerDelegate,
UIDocumentInteractionControllerDelegate,
UoneDownloadToolbarDelegate,
SWTableViewCellDelegate,
UOneDownloadTableViewCellDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@end

@implementation UOneDownloadViewController
{
    NSBundle* _bundle;
    NSMutableIndexSet* _selectedIndexSet;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"UOneMedia" withExtension:@"bundle"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // Do any additional setup after loading the view from its nib.

    
    self.downloadManager = [WspxDownloadManager shareInstance];
    _selectedIndexSet = [NSMutableIndexSet indexSet];
    if (!self.tableView) {
        NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
        self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        [self.view addSubview:self.tableView];
    }
    if (!self.fileManagerToolbar) {
        self.fileManagerToolbar = [[UoneDownloadToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 47, self.view.frame.size.width, 47)];
        self.fileManagerToolbar.customedDelegate = self;
        [self.view addSubview:self.fileManagerToolbar];
    }
    
    self.tableView.backgroundColor = UIColorFromHex(0xF6F6F6);
    self.tableView.opaque = 0.4;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    [self.tableView reloadData];
    
    [self registerNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    if (self.navigationController) {
        return self.navigationController;
    } else {
        return self;
    }
}
#pragma mark QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {

    return 1;
}
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSURL *fileURL = nil;
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    WspxDownloadItem *item = self.downloadManager.downloadItems[selectedIndexPath.row];
    fileURL = item.localFileURL;
    return fileURL;
}

#pragma mark - WspxDownloadManager Notification

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadDidComplete:) name:wspxDownloadDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProgressDidChange:) name:wspxDownloadProgressChangedNotification object:nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTotalProgressDidChange:) name:wspxTotalDownloadProgressChangedNotification object:nil];
    }
    return;
}

- (void)unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:wspxDownloadDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:wspxDownloadProgressChangedNotification object:nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:wspxTotalDownloadProgressChangedNotification object:nil];
    }
    return;
}

- (void)onDownloadDidComplete:(NSNotification *)aNotification {
    WspxDownloadItem *aDownloadedItem = (WspxDownloadItem *)aNotification.object; ////////
    NSLog(@"onDownloadDidComplete --> %@", aDownloadedItem);
    NSUInteger aFoundDownloadItemIndex = [self.downloadManager.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aItem.downloadIdentifier isEqualToString:aDownloadedItem.downloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:aFoundDownloadItemIndex inSection:0];
         if([[self.tableView indexPathsForVisibleRows] containsObject:anIndexPath]) {
             UOneDownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:anIndexPath];
             [cell resetWithDownloadItem:aDownloadedItem];
        }
    }
    else
    {
        NSLog(@"WARN: Completed download item not found (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}

- (void)onProgressDidChange:(NSNotification *)aNotification {
    WspxDownloadItem *aDownloadedItem = (WspxDownloadItem *)aNotification.object;
    NSLog(@"onProgressDidChange --> %@", aDownloadedItem);
    
    NSUInteger aFoundDownloadItemIndex = [self.downloadManager.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aItem.downloadIdentifier isEqualToString:aDownloadedItem.downloadIdentifier]) {
            return YES;
        }
        return NO;
    }];
    
    if (aFoundDownloadItemIndex != NSNotFound) {
        NSTimeInterval lastChangedUpdateDelta = 10.0;
        if (aDownloadedItem.lastUpdateTime)
        {
            lastChangedUpdateDelta = [[NSDate date] timeIntervalSinceDate:aDownloadedItem.lastUpdateTime];
        }
        if (lastChangedUpdateDelta > 0.25) {
            NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:aFoundDownloadItemIndex inSection:0];
            if([[self.tableView indexPathsForVisibleRows] containsObject:anIndexPath]) {
                UOneDownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:anIndexPath];
                [cell resetWithDownloadItem:aDownloadedItem];
            }
            aDownloadedItem.lastUpdateTime = [NSDate date];
        }
    } else {
        NSLog(@"WARN: Completed download item not found (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}

- (void)onTotalProgressDidChange:(NSNotification *)aNotification {
    NSLog(@"onTotalProgressDidChange -->");
}
#pragma mark - UoneDownloadToolbarDelegate
- (void)uoneDownloadToolbar:(UoneDownloadToolbar *)toolbar didClickedEditButton:(UIButton *)button {
    [_selectedIndexSet removeAllIndexes];
    [self.tableView setEditing:_fileManagerToolbar.isEditing animated:YES];
}

- (void)uoneDownloadToolbar:(UoneDownloadToolbar *)toolbar didClickedSelectAllButton:(UIButton *)button {
    BOOL isSelectedAll = !button.selected;
    NSMutableArray* list = [self.downloadManager downloadItems];
    
    if (isSelectedAll) {
        [_selectedIndexSet addIndexesInRange:NSMakeRange(0, (NSUInteger)[list count])];
    } else {
        [_selectedIndexSet removeAllIndexes];
    }
    [_tableView reloadData];
}

- (void)uoneDownloadToolbar:(UoneDownloadToolbar *)toolbar didClickedDeleteButton:(UIButton *)button {
   
}

- (void)uoneDownloadToolbar:(UoneDownloadToolbar *)toolbar didClickedDoneButton:(UIButton *)button {
    [self.tableView setEditing:_fileManagerToolbar.isEditing animated:YES];
}
#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    //  NSLog(@"editingStyleForRowAtIndexPath:%ld", (long)[indexPath row]);
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WspxDownloadItem* item = _downloadManager.downloadItems[indexPath.row];
    WspxDownloadItemStatus itemStatus = item.status;
   
    switch (itemStatus) {
        case WspxDownloadItemStatusNotStarted:
        case WspxDownloadItemStatusCancelled:
        case WspxDownloadItemStatusInterrupted:
        case WspxDownloadItemStatusError:
        {
            [_downloadManager startDownloadWithItem:item];
        }
            break;
        case WspxDownloadItemStatusStarted:
            break;
        case WspxDownloadItemStatusPaused:
        {
            [_downloadManager resumeDownloadWithItem:item];
        }
            break;
        case WspxDownloadItemStatusCompleted:
        {
            NSURL *fileUrl = [NSURL fileURLWithPath:item.localFileURL.absoluteString isDirectory:YES];
            BOOL isCanPreview = [QLPreviewController canPreviewItem:fileUrl];
            if (isCanPreview) {
                QLPreviewController *previewController = [[QLPreviewController alloc] init];
                previewController.dataSource = self;
                previewController.delegate = self;

                previewController.currentPreviewItemIndex = indexPath.row;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self presentViewController:previewController animated:YES completion:nil];
                });
            } else {
                
                if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:canPreviewItem:)]) {
                    [_delegate downloadViewController:self canPreviewItem:NO];
                } else {
                    [self presentOptionsMenu];
                }
            }
            
            
        }
            break;
    }
    
}

- (void)presentOptionsMenu {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    WspxDownloadItem *item = self.downloadManager.downloadItems[path.row];
    NSURL *fileURL = item.localFileURL;
    [self setupDocumentControllerWithURL:fileURL];
    self.docInteractionController.URL = fileURL;
    
    
    BOOL isCanPresentOtionsMenu = [self.docInteractionController presentOptionsMenuFromRect:self.tableView.frame
                                                                                     inView:self.tableView
                                                                                   animated:YES];

    if (!isCanPresentOtionsMenu) {
        if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:canPresentOptionsMenu:)]) {
            [_delegate downloadViewController:self canPresentOptionsMenu:NO];
        } else {
            [self showAlertView];
        }
    }
}
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadManager.downloadItems.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * identifier = @"kUOneDownloadTableViewCellIdentifier";
    UOneDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        UINib *nib = [UINib nibWithNibName:@"UOneDownloadTableViewCell" bundle:_bundle];
        [tableView registerNib: nib forCellReuseIdentifier:identifier];
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    BOOL isSelected = NO;
    if (_selectedIndexSet != nil && [_selectedIndexSet containsIndex:(NSUInteger)indexPath.row]) {
        isSelected = YES;
    }
    cell.checkButton.selected = isSelected;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.customDelegate = self;

    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[UOneDownloadTableViewCell class]]) {
        
        NSInteger row = indexPath.row;
        WspxDownloadItem* item = _downloadManager.downloadItems[row];
        
        [(UOneDownloadTableViewCell*)cell resetWithDownloadItem:item];
        
    }
}
#pragma mark - UOneDownloadTableViewCellDelegate
- (void)tableViewCell:(nonnull UOneDownloadTableViewCell *)cell didClickedDownloadButton:(nonnull UIButton *)button {
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row;
    if (row < _downloadManager.downloadItems.count) {
        WspxDownloadItem * downloadItem = _downloadManager.downloadItems[row];
        switch (downloadItem.status) {
            case WspxDownloadItemStatusNotStarted:
            case WspxDownloadItemStatusError:
            case WspxDownloadItemStatusInterrupted:
                [_downloadManager startDownloadWithItem:downloadItem];
                break;
            case WspxDownloadItemStatusCompleted:
                if ([downloadItem.downloadErrorMessagesStack count] > 0) {
                    NSLog(@"error stack: %@", downloadItem.downloadErrorMessagesStack);
                }
            case WspxDownloadItemStatusCancelled:
                break;
            case WspxDownloadItemStatusStarted:
                [_downloadManager pauseDownloadWithItem:downloadItem];
                break;
            case WspxDownloadItemStatusPaused:
                [_downloadManager resumeDownloadWithItem:downloadItem];
                break;
        }
    }
    
}

- (void)onSelected:(BOOL)selected tableViewCell:(UOneDownloadTableViewCell*)cell {
    NSLog(@"selected:%d", selected);
    NSMutableArray* list = [self.downloadManager downloadItems];
    
    NSUInteger row = [_tableView indexPathForCell:cell].row;
    WspxDownloadItem *item = [list objectAtIndex:row];
    if (item != nil) {
        if (selected) {
            [_selectedIndexSet addIndex:(NSUInteger)row];
        } else {
            [_selectedIndexSet removeIndex:(NSUInteger)row];
        }
    }
}
#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state {
    if (state == kCellStateCenter) {
        
    }
}
- (void)swipeableTableViewCellDidEndScrolling:(SWTableViewCell *)cell {
    NSLog(@"didEndScrolling: tag:%d",(int)cell.tag);
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSLog(@"didTriggerRightUtilityButtonWithIndex:");
    NSMutableArray* list = [self.downloadManager downloadItems];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (indexPath && indexPath.row < [list count]) {
        WspxDownloadItem* item = [list objectAtIndex:indexPath.row];
       
        [self.downloadManager removeDownloadWithItem:item];
    
        [list removeObject:item];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
//        [_hudManager showSuccessWithMessage:@"移除成功" duration:1];
//        _hudManager.HUD.minSize = CGSizeMake(100,100);
//        _hudManager.HUD.opacity = 0.6;
//        _hudManager.HUD.dimBackground = YES;
    }
}


- (void)showAlertView {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"找不到打开该文件的app"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
        
    }];

    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}
- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

@end
