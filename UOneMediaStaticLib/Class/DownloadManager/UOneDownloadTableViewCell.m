//
//  UOneDownloadTableViewCell.m
//  UOneMedia
//
//  Created by wuxin on 5/26/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import "UOneDownloadTableViewCell.h"
#import "WspxDownloadManager.h"

@interface UOneDownloadTableViewCell ()<PKDownloadButtonDelegate>

@end

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
    self.fileLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

    [self.fileLabel setTextColor:UIColorFromHex(0x565656)];
    [self.sizeLabel setTextColor:UIColorFromHex(0xbdbdbd)];
    [self initDownloadButton];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    _tapRecognizer.numberOfTapsRequired = 1;
    [self.progressView addGestureRecognizer:_tapRecognizer];
    [self.progressView setBackgroundColor:[UIColor clearColor]];
    
    NSMutableArray* rightButtons = [[NSMutableArray alloc] initWithCapacity:1];

    [rightButtons sw_addUtilityButtonWithColor:UIColorFromHex(0xFE5443)
                                          icon:[UIImage imageNamed:@"UOneMedia.bundle/history_item_delete"]];
    
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
    self.downloadButton.delegate = self;
    self.downloadButton.progressColor = UIColorFromHex(0xbdbdbd);
    self.downloadButton.progressTrackColor = UIColorFromHex(0xffb72c);
    self.downloadButton.progressPendingColor = UIColorFromHex(0xbdbdbd);
    self.downloadButton.tintColor = UIColorFromHex(0xbdbdbd);
    self.downloadButton.progressImageWidth = 17;
    self.downloadButton.startDownloadTitle = @"下载";
    self.downloadButton.openDownloadedTitle = @"打开";
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (self.downloadButton.pendingView.isSpinning) {
        [self.downloadButton.pendingView startSpin];
    } else {
        [self.downloadButton.pendingView stopSpin];
    }
}

- (NSUInteger)getStringLengthOfString:(NSString *)str {
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [str dataUsingEncoding:enc];
    return [da length];
}

- (void)resetWithDownloadItem : ( WspxDownloadItem * _Nonnull )aDownloadItem {
    NSString *title = @"未知文件";
    _downloadItem = aDownloadItem;
    if (aDownloadItem.downloadSuggestedFileName && [aDownloadItem.downloadSuggestedFileName length] != 0) {
        title = aDownloadItem.downloadSuggestedFileName;
    } else {
        title = [self splitFilenameFromUrl:aDownloadItem.remoteURL.path];
    }
    
    self.fileLabel.text = title;
    
   NSMutableString *sizeString = [[self jointWithExpectedSize: aDownloadItem.expectedFileSizeInBytes receivedSize:aDownloadItem.receivedFileSizeInBytes] mutableCopy];
    self.iconImage.image = [self imageWithFileExt:[self splitExtFromFilename: self.fileLabel.text]];
   
    CGFloat progress = aDownloadItem.downloadProgress;
    
    WspxDownloadItemStatus downloadStatus = aDownloadItem.status;

    self.downloadButton.pauseDownloadButton.pkProgress = 0;
    self.downloadButton.downloadingButton.pkProgress = 0;
    self.downloadButton.state = kPKDownloadButtonState_Downloaded;
    switch (downloadStatus) {
        case WspxDownloadItemStatusNotStarted:
        {
            [sizeString appendString:@" | 等待中"];
            self.downloadButton.state = kPKDownloadButtonState_Downloading;
            break;
        }
        case WspxDownloadItemStatusCancelled:
        {
            //do nothing
            self.downloadButton.state = kPKDownloadButtonState_StartDownload;
            break;
        }
        case WspxDownloadItemStatusPending:
        {
            [sizeString appendString:@" | 获取中"];
            self.downloadButton.state = kPKDownloadButtonState_Pending;
            break;
        }
        case WspxDownloadItemStatusInterrupted:
        case WspxDownloadItemStatusError:
        {
            self.downloadButton.state = kPKDownloadButtonState_Error;
            break;
        }
        case WspxDownloadItemStatusCompleted:
        {
            NSRange deleteRange = [sizeString rangeOfString:@"/"];
            [sizeString deleteCharactersInRange:NSMakeRange(deleteRange.location, sizeString.length - deleteRange.location)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            NSString *dateString = [dateFormatter stringFromDate:aDownloadItem.lastUpdateTime];
            
            [sizeString appendString:[NSString stringWithFormat:@" | %@", dateString]];
            self.downloadButton.state = kPKDownloadButtonState_Downloaded;
            break;
        }
        
        case WspxDownloadItemStatusStarted:
        {
            [sizeString appendString:@" | "];
            [sizeString appendString:[self toStringWithBytesPerSecond:aDownloadItem.bytesPerSecondSpeed]];
            self.downloadButton.state = kPKDownloadButtonState_Downloading;
            self.downloadButton.pauseDownloadButton.pkProgress = progress;
            self.downloadButton.downloadingButton.pkProgress = progress;
            break;
        }
        
        case WspxDownloadItemStatusPaused:
        {
            [sizeString appendString:@" | 已暂停"];
            self.downloadButton.state = kPKDownloadButtonState_Pausing;
            self.downloadButton.pauseDownloadButton.pkProgress = progress;
            self.downloadButton.downloadingButton.pkProgress = progress;
            break;
        }
    }
    
    if (downloadStatus == WspxDownloadItemStatusError || downloadStatus == WspxDownloadItemStatusInterrupted) {
        [self.sizeLabel setAttributedText:[self toDownloadFailedAttributedSizeString]];
    } else {
         self.sizeLabel.text = sizeString;
    }
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
#pragma mark - PKDownloadButtonDelegate
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
        if ([filterString respondsToSelector:@selector(containsString:)]) {
            if ([filterString containsString:fileExt]) {
                stop = YES;
                imageKey = obj;
            }
        } else {
            NSRange range = [filterString rangeOfString:fileExt];
            if(range.location != NSNotFound){
                stop = YES;
                imageKey = obj;
            }
        }
    }];
    
    NSString *imageName = [staticExtImageMap objectForKey:imageKey];
    
    if (!imageName) {
        imageName = @"UOneMedia.bundle/未知文件";
    }
    UIImage * iconImage = [UIImage imageNamed:imageName];
    
    return iconImage != nil ? iconImage : [UIImage imageNamed:@"UOneMedia.bundle/未知文件"];
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
    NSString *expectedSizeStr = @"未知大小";
    if (expectedSize != -1) {
        expectedSizeStr = [self toStringWithBytes:(double)expectedSize];
    }
    return [NSString stringWithFormat:@"%@/%@", [self toStringWithBytes:(double)receivedSize],
                                                expectedSizeStr];
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
    NSString *documentString = @"txt、doc、docx、ppt、pptx、xls、xlsx、pdf、mobi、epub";
    NSString *videoString = @"avi、rmvb、rm、asf、divx、mpg、mpeg、mpe、wmv、mp4、mkv、vob、mov、swf";
    NSString *audioString = @"mp3、wma、wav、ram、amr、au";
    NSString *zipString = @"rar、zip";
    
    
    NSDictionary *map = @{@"pic": pictureString,
                          @"doc": documentString,
                          @"video": videoString,
                          @"audio": audioString,
                          @"zip": zipString};
    return map;
}

- (NSDictionary*)getImageMap {
    return @{@"pic" : @"UOneMedia.bundle/图片",
             @"doc" : @"UOneMedia.bundle/文档",
             @"video": @"UOneMedia.bundle/视频",
             @"audio": @"UOneMedia.bundle/音乐",
             @"zip": @"UOneMedia.bundle/压缩" };
}

@end
