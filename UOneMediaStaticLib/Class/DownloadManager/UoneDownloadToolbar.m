//
//  UoneDownloadToolbar.m
//  UOneMedia
//
//  Created by MrChens on 16/6/6.
//  Copyright © 2016年 chiannetcenter. All rights reserved.
//

#import "UoneDownloadToolbar.h"
#import "WspxDownloadManager.h"
@implementation UoneDownloadToolbar
@synthesize isEditing;
@synthesize deleteButton;
@synthesize selectAllButton;
@synthesize doneButton;
@synthesize editButton;
@synthesize diskUsageAndStorageLabel;

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        
        self.backgroundColor = UIColorFromHex(0xffffff);
        self.isEditing = NO;
        self.isLabelMode = YES;
        //全选 按钮
        selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectAllButton.backgroundColor = [UIColor clearColor];
        selectAllButton.showsTouchWhenHighlighted = YES;
        selectAllButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [selectAllButton setTitle:@"全选" forState:UIControlStateNormal];
        [selectAllButton setTitle:@"取消全选" forState:UIControlStateSelected];
        //   [selectAllButton setTitleEdgeInsets:UIEdgeInsetsMake(0,0,0,0)];
        selectAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [selectAllButton setTitleColor:UIColorFromHex(0x333333) forState:UIControlStateNormal];
        [selectAllButton setTitleColor:UIColorFromHex(0xbdbdbd) forState:UIControlStateDisabled];
        [selectAllButton addTarget:self action:@selector(onSelectAll:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:selectAllButton];
        
        //删除 按钮
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.backgroundColor = [UIColor clearColor];
        deleteButton.showsTouchWhenHighlighted = YES;
        deleteButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [deleteButton setTitleColor:UIColorFromHex(0x333333) forState:UIControlStateNormal];
        [deleteButton setTitleColor:UIColorFromHex(0xbdbdbd) forState:UIControlStateDisabled];
        deleteButton.enabled = NO;
        [deleteButton addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteButton];
        
        //完成 按钮
        doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.backgroundColor = [UIColor clearColor];
        doneButton.showsTouchWhenHighlighted = YES;
        doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [doneButton setTitleColor:UIColorFromHex(0x333333) forState:UIControlStateNormal];
        [doneButton setTitleColor:UIColorFromHex(0xbdbdbd) forState:UIControlStateDisabled];
        [doneButton addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        
        //编辑 按钮
        editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editButton.backgroundColor = [UIColor clearColor];
        editButton.showsTouchWhenHighlighted = YES;
        editButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [editButton setTitle:@"编辑" forState:UIControlStateNormal];
        editButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [editButton setTitleColor:UIColorFromHex(0x333333) forState:UIControlStateNormal];
        [editButton setTitleColor:UIColorFromHex(0xbdbdbd) forState:UIControlStateDisabled];
        [editButton addTarget:self action:@selector(onEdit:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:editButton];
        
        //可用 剩余内存
        diskUsageAndStorageLabel = [[UILabel alloc] init];
        diskUsageAndStorageLabel.backgroundColor = [UIColor clearColor];
        diskUsageAndStorageLabel.font = [UIFont systemFontOfSize:15];
        diskUsageAndStorageLabel.textAlignment = NSTextAlignmentCenter;
        diskUsageAndStorageLabel.textColor = UIColorFromHex(0xbdbdbd);
        diskUsageAndStorageLabel.text = [[WspxDownloadManager shareInstance] getDiskUsageAndStorageString];
        [self addSubview:diskUsageAndStorageLabel];
        
        [self layout];
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    
    CGRect rc = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1.0);
    
    //设置颜色
    CGContextSetRGBStrokeColor(context, CGFloatFromHex(0xe0), CGFloatFromHex(0xe0), CGFloatFromHex(0xe0), 1.0);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rc.size.width, 0);
    //连接上面定义的坐标点
    CGContextStrokePath(context);
}
- (void)layoutSubviews {
    [self layout];
}
-(void)layout {
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGFloat btnHeight = height;
    CGFloat btnWidth  = 50;
    
    if(selectAllButton.selected){
        selectAllButton.frame   = CGRectMake(20, 0, 80, btnHeight);
    }else{
        selectAllButton.frame   = CGRectMake(20, 0, btnWidth, btnHeight);
    }
    
    deleteButton.frame   = CGRectMake(CGRectGetMaxX(selectAllButton.frame) + 15, 0, 80, btnHeight);
    diskUsageAndStorageLabel.frame = CGRectMake(btnWidth, 0, width - 2*btnWidth, btnHeight);
    doneButton.frame   = CGRectMake(width - btnWidth - 20, 0, btnWidth, btnHeight);
    editButton.frame   = CGRectMake(width - btnWidth - 20, 0, btnWidth, btnHeight);
    if (self.isEditing) {
        selectAllButton.hidden = NO;
        doneButton.hidden = NO;
        deleteButton.hidden = NO;
        diskUsageAndStorageLabel.hidden = YES;
        editButton.hidden = YES;
    } else {
        if (_isLabelMode) {
            editButton.hidden = YES;
        } else {
            editButton.hidden = NO;
        }
        selectAllButton.hidden = YES;
        deleteButton.hidden = YES;
        doneButton.hidden = YES;
        diskUsageAndStorageLabel.hidden = NO;
        
    }
}

- (void)setIsLabelMode:(BOOL)isLabelMode {
    _isLabelMode = isLabelMode;
    [self layout];
}

- (void)setDeleteTitle:(nullable NSString *)deleteTitle {
    if (!deleteTitle && deleteTitle.length == 0) {
        deleteTitle = @"删除";
    }
    [deleteButton setTitle:deleteTitle forState:UIControlStateNormal];
}
#pragma mark - UIButton Event

- (void)onEdit:(UIButton*)button {
    self.isEditing = YES;
    if (self.customedDelegate && [self.customedDelegate respondsToSelector:@selector(uoneDownloadToolbar:didClickedEditButton:)]) {
        [self.customedDelegate uoneDownloadToolbar:self didClickedEditButton:button];
    }
    [self layout];
}

- (void)onDone:(UIButton*)button {
    self.isEditing = NO;
    if (self.customedDelegate && [self.customedDelegate respondsToSelector:@selector(uoneDownloadToolbar:didClickedDoneButton:)]) {
        [self.customedDelegate uoneDownloadToolbar:self didClickedDoneButton:button];
    }
    [self layout];
}

- (void)onDelete:(UIButton*)button {
    if (self.customedDelegate && [self.customedDelegate respondsToSelector:@selector(uoneDownloadToolbar:didClickedDeleteButton:)]) {
        [self.customedDelegate uoneDownloadToolbar:self didClickedDeleteButton:button];
    }
}

- (void)onSelectAll:(UIButton*)button {
    if (self.customedDelegate && [self.customedDelegate respondsToSelector:@selector(uoneDownloadToolbar:didClickedSelectAllButton:)]) {
        [self.customedDelegate uoneDownloadToolbar:self didClickedSelectAllButton:button];
    }
}
@end
