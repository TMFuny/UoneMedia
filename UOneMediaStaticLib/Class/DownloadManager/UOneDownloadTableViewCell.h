//
//  UOneDownloadTableViewCell.h
//  UOneMedia
//
//  Created by wuxin on 5/26/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WspxDownloadItem.h"
#import "PKDownloadButton.h"
#import "SWTableViewCell.h"

@class UOneDownloadTableViewCell;

@protocol UOneDownloadTableViewCellDelegate <NSObject>

@required

- (void)tableViewCell:(nonnull UOneDownloadTableViewCell *)cell didClickedDownloadButton:(nonnull UIButton *)button;
- (void)onSelected:(BOOL)selected tableViewCell:(nonnull UOneDownloadTableViewCell*)cell;
@end

@interface UOneDownloadTableViewCell : SWTableViewCell

@property (nullable, nonatomic, weak) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (nullable, nonatomic, weak) IBOutlet UILabel * fileLabel;
@property (nullable, nonatomic, weak) IBOutlet UILabel * sizeLabel;
@property (nullable, nonatomic, weak) IBOutlet UIImageView * iconImage;
@property (nullable, nonatomic, weak) IBOutlet UIView * progressView;
@property (nullable, nonatomic, weak) IBOutlet UIButton *checkButton;
@property (nullable, nonatomic, strong) PKDownloadButton *downloadButton;
@property (nullable, assign) id <UOneDownloadTableViewCellDelegate> customDelegate;

- (void)resetWithDownloadItem : (nonnull WspxDownloadItem *)aDownloadItem;


/* * * * * * * * * 
 
 this function is useless, but it must be invoked by App explicit. 
 see InitUOneMediaFramework
 
 * * * * * * * * * * * */
+ (void)forceLinkerLoad;
@end
