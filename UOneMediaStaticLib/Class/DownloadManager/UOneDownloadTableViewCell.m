//
//  UOneDownloadTableViewCell.m
//  UOneMedia
//
//  Created by wuxin on 5/26/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import "UOneDownloadTableViewCell.h"
#import "WspxDownloadManager.h"

@implementation UOneDownloadTableViewCell
{
    NSBundle * _bundle;
    UITapGestureRecognizer* _tapRecognizer;
    WspxDownloadItem* _downloadItem;
}

@synthesize fileLabel;

+ (void)forceLinkerLoad {
    // DO NOTHING
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"UOneMedia" withExtension:@"bundle"]];
    _downloadItem = nil;
    [self initFileExtImageMap];
    // Initialization code
    [self.fileLabel setFont:[UIFont systemFontOfSize:15]];
    [self.sizeLabel setFont:[UIFont systemFontOfSize:13]];
    
    [self.fileLabel setTextColor:UIColorFromHex(0x565656)];
    [self.sizeLabel setTextColor:UIColorFromHex(0xbdbdbd)];
    [self initDownloadButton];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    _tapRecognizer.numberOfTapsRequired = 1;
    [self.progressView addGestureRecognizer:_tapRecognizer];
    [self.progressView setBackgroundColor:[UIColor clearColor]];
    
    NSMutableArray* rightButtons = [[NSMutableArray alloc] initWithCapacity:1];

    [rightButtons sw_addUtilityButtonWithColor:UIColorFromHex(0xFE5443)
                                          icon:[UIImage imageNamed:@"history_item_delete" inBundle:_bundle compatibleWithTraitCollection:nil]];
    
    [self  setRightUtilityButtons:rightButtons WithButtonWidth:58.0f];
    
//    [self.iconImage setImage:[UIImage imageNamed:@"默认图标" inBundle:_bundle compatibleWithTraitCollection:nil]];
}

- (void)initDownloadButton {
    self.downloadButton = [[PKDownloadButton alloc] init];
    [self.progressView addSubview:self.downloadButton];
    self.downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.downloadButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.progressView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1
                                                                          constant:0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.downloadButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.progressView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.downloadButton
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.progressView
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.downloadButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.progressView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1
                                                                         constant:0];
    
    
    [self.progressView addConstraints:@[centerXConstraint, centerYConstraint, widthConstraint, heightConstraint]];
    self.downloadButton.progressColor = UIColorFromHex(0xbdbdbd);
    self.downloadButton.progressTrackColor = UIColorFromHex(0xffb72c);
    self.downloadButton.progressPendingColor = UIColorFromHex(0xbdbdbd);
    self.downloadButton.tintColor = UIColorFromHex(0xbdbdbd);
    
    self.downloadButton.startDownloadTitle = @"下载";
    self.downloadButton.openDownloadedTitle = @"打开";
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (self.downloadButton.pendingView.isSpinning) {
        [self.downloadButton.pendingView startSpin];
    }
}

- (void)resetWithDownloadItem : ( WspxDownloadItem * _Nonnull )aDownloadItem {
    self.fileLabel.text = [self splitFilenameFromUrl:aDownloadItem.remoteURL.absoluteString];
    
   NSMutableString *sizeString = [[self jointWithExpectedSize: _downloadItem.expectedFileSizeInBytes receivedSize:_downloadItem.receivedFileSizeInBytes] mutableCopy];
    self.iconImage.image = [self imageWithFileExt:[self splitExtFromFilename: self.fileLabel.text]];
   
    CGFloat progress = aDownloadItem.downloadProgress;
    
    WspxDownloadItemStatus downloadStatus = aDownloadItem.status;
    switch (downloadStatus) {
        case WspxDownloadItemStatusNotStarted:
        {
            [sizeString appendString:@" | 正在获取"];
            self.downloadButton.state = kPKDownloadButtonState_Pending;
            break;
        }
        case WspxDownloadItemStatusError:
        {
            self.downloadButton.state = kPKDownloadButtonState_Error;
            break;
        }
        case WspxDownloadItemStatusCompleted:
        {
            NSRange deleteRange = [sizeString rangeOfString:@"/"];
            [sizeString deleteCharactersInRange:NSMakeRange(deleteRange.location, sizeString.length - deleteRange.location)];
            self.downloadButton.state = kPKDownloadButtonState_Downloaded;
            break;
        }
        case WspxDownloadItemStatusCancelled:
        {
            //do nothing
            break;
        }
        case WspxDownloadItemStatusStarted:
        {
            [sizeString appendString:@" | "];
            [sizeString appendString:[self toStringWithBytesPerSecond:_downloadItem.bytesPerSecondSpeed]];
            self.downloadButton.state = kPKDownloadButtonState_Downloading;
            self.downloadButton.pauseDownloadButton.pkProgress = progress;
            self.downloadButton.downloadingButton.pkProgress = progress;
            break;
        }
        case WspxDownloadItemStatusInterrupted:
        case WspxDownloadItemStatusPaused:
        {
            [sizeString appendString:@" | 已暂停"];
            self.downloadButton.state = kPKDownloadButtonState_Pausing;
            self.downloadButton.pauseDownloadButton.pkProgress = progress;
            self.downloadButton.downloadingButton.pkProgress = progress;
            break;
        }
    }

    if (downloadStatus == WspxDownloadItemStatusError) {
        [self.sizeLabel setAttributedText:[self toDownloadFailedAttributedSizeString]];
    } else {
         self.sizeLabel.text = sizeString;
    }
    _downloadItem = aDownloadItem;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        _progressView.hidden = YES;
        _progressViewWidthConstraint.constant = 0;
        [UIView animateWithDuration:0.7 animations:^{
            _checkButton.alpha = 1;
            _progressView.alpha = 0;
        } completion:nil];
    } else {
        _checkButton.selected = NO;
        _progressView.hidden = NO;
        _progressViewWidthConstraint.constant = 40;
        [UIView animateWithDuration:0.7 animations:^{
            _checkButton.alpha = 0;
            _progressView.alpha = 1;
        } completion:nil];
    }
}

- (void)scrollViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self.contentView];
    CGRect frame = _checkButton.frame;
    frame = CGRectInset(frame, -15, -15);
    if (CGRectContainsPoint(frame, p)) {
        [_checkButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        [super scrollViewTapped:gestureRecognizer];
    }
}

- (void)onTapGesture:(UITapGestureRecognizer*)recognizer {

    if ([self.customDelegate respondsToSelector:@selector(tableViewCell:didClickedDownloadButton:)]) {
        [self.customDelegate tableViewCell:self didClickedDownloadButton:self.progressView];
    }
}

- (IBAction)onSelected:(UIButton*)button {
    if (self.isEditing) {
        _checkButton.selected = !_checkButton.selected;
        if (_customDelegate != nil && [_customDelegate respondsToSelector:@selector(onSelected:tableViewCell:)]) {
            [_customDelegate onSelected:button.selected tableViewCell:self];
        }
    }
    return;
}

- (void)downloadButtonTapped:(PKDownloadButton *)downloadButton
                currentState:(PKDownloadButtonState)state {
    [self onTapGesture:nil];
}

#pragma mark - privateMethod

- (UIImage *)imageWithFileExt:(NSString*)fileExt {
    NSArray* allKeys = [staticMap allKeys];
    __block NSString *imageKey = @"未知文件";
    [allKeys enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* filterString = [staticMap objectForKey:obj];
        if ([filterString containsString:fileExt]) {
            stop = YES;
            imageKey = obj;
        }
    }];
    
    UIImage * iconImage = [UIImage imageNamed:[staticExtImageMap objectForKey:imageKey]];
    
    return iconImage != nil ? iconImage : [UIImage imageNamed:@"未知文件"];
}

- (NSString *)splitFilenameFromUrl:(NSString *)strUrl {
    NSArray * subStrings = [strUrl componentsSeparatedByString:@"/"];
    NSString * filename = [subStrings lastObject];
    return filename;
}

- (NSString *)splitExtFromFilename:(NSString *)filename {
    NSArray * subStrings = [filename componentsSeparatedByString:@"."];
    if (subStrings && subStrings > 1) {
        return [subStrings lastObject];
    }
    return nil;
}

- (NSString *)jointWithExpectedSize:(int64_t)expectedSize receivedSize:(int64_t)receivedSize {
    return [NSString stringWithFormat:@"%@/%@", [self toStringWithBytes:(double)receivedSize],
                                                [self toStringWithBytes:(double)expectedSize]];
}

- (NSString *)toStringWithBytes:(double)bytes {
    NSArray<NSString *> * fmt = @[@"%.0fB", @"%.1fKB", @"%.1fMB",@"%.1fGB"];
    for (int i = 0; i < 4; i++) {
        if (bytes < 1024) {
            return [NSString stringWithFormat:fmt[i], bytes];
        }
        bytes = bytes / 1024.0;
    }
    return @"0KB";
}

- (NSString *)toStringWithBytesPerSecond:(double)butes {
    return [[self toStringWithBytes:butes] stringByAppendingString:@"/s"];
}

- (NSAttributedString *)toDownloadFailedAttributedSizeString {
    NSMutableString *sizeString = [[self jointWithExpectedSize: _downloadItem.expectedFileSizeInBytes receivedSize:_downloadItem.receivedFileSizeInBytes] mutableCopy];
    [sizeString appendString:@" | 下载失败"];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:sizeString];
    NSRange slashRange = [sizeString rangeOfString:@"|"];
    NSRange colorRange =NSMakeRange(slashRange.location+1, sizeString.length - slashRange.location-1) ;
    
    [attr addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0xfb5549) range:colorRange];


    return [attr copy];
    
}
static NSDictionary *staticMap = nil;
static NSDictionary *staticExtImageMap = nil;

- (void)initFileExtImageMap {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticMap = [self getDoucmentTypeMap];
        staticExtImageMap =[self getImageMap];
    });
}

- (NSDictionary*)getDoucmentTypeMap {
    
    NSString *pictureString = @"jpg、jpeg、png、bmp、gif";
    NSString *documentString = @"txt、doc、docx、ppt、pptx、xls、xlsx、pdf";
    NSString *videoString = @"avi、rmvb、rm、asf、divx、mpg、mpeg、mpe、wmv、mp4、mkv、vob";
    NSString *audioString = @"mp3、wma、wav";
    NSString *zipString = @"rar、zip";
    
    
    NSDictionary *map = @{@"pic": pictureString,
                          @"doc": documentString,
                          @"video": videoString,
                          @"audio": audioString,
                          @"zip": zipString};
    return map;
}

- (NSDictionary*)getImageMap {
    return @{@"pic" : @"图片",
             @"doc" : @"文档",
             @"video": @"视频",
             @"audio": @"音乐",
             @"zip": @"压缩" };
}

@end
