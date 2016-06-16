//
//  PKDownloadButton.m
//  PKDownloadButton
//
//  Created by Pavel on 28/05/15.
//  Copyright (c) 2015 Katunin. All rights reserved.
//

#import "PKDownloadButton.h"
#import "PKMacros.h"
#import "PKCircleProgressView.h"
#import "NSLayoutConstraint+PKDownloadButton.h"
#import "UIImage+PKDownloadButton.h"


static NSDictionary *DefaultTitleAttributes(UIColor *color) {
    return @{ NSForegroundColorAttributeName : color,
              NSFontAttributeName : [UIFont systemFontOfSize:14.f]};
}

static NSDictionary *HighlitedTitleAttributes() {
    return @{ NSForegroundColorAttributeName : [UIColor whiteColor],
              NSFontAttributeName : [UIFont systemFontOfSize:14.f]};
}

@interface PKDownloadButton ()

@property (nonatomic, weak) PKBorderedButton *startDownloadButton;
@property (nonatomic, weak) PKStopDownloadButton *stopDownloadButton;
@property (nonatomic, weak) PKPauseDownloadButton *pauseDownloadButton;
@property (nonatomic, weak) PKBorderedButton *downloadedButton;
@property (nonatomic, weak) PKDownloadingButton *downloadingButton;
@property (nonatomic, weak) PKPendingView *pendingView;

@property (nonatomic, strong) NSMutableArray *stateViews;

- (PKBorderedButton *)createStartDownloadButton;
- (PKStopDownloadButton *)createStopDownloadButton;
- (PKPauseDownloadButton *)createPauseDownloadButton;
- (PKBorderedButton *)createDownloadedButton;
- (PKDownloadingButton *)createDownloadingButton;
- (PKPendingView *)createPendingView;

- (void)currentButtonTapped:(id)sender;

- (void)createSubviews;
- (NSArray *)createConstraints;

@end

static PKDownloadButton *CommonInit(PKDownloadButton *self) {
    if (self != nil) {
        [self createSubviews];
        [self addConstraints:[self createConstraints]];
        
        self.state = kPKDownloadButtonState_StartDownload;
    }
    return self;
}

@implementation PKDownloadButton
#pragma mark - Properties

- (void)setState:(PKDownloadButtonState)state {
    _state = state;
    
    [self.stateViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SafeObjClassCast(UIView, view, obj);
        view.hidden = YES;
    }];
    
    self.hidden = NO;
    self.userInteractionEnabled = YES;
    
    switch (state) {
        case kPKDownloadButtonState_StartDownload:
            self.startDownloadButton.hidden = NO;
            self.downloadingButton.pkProgress = 0.f;
            NSLog(@"download state: StartDownLaod");
            break;
        case kPKDownloadButtonState_Pending:
            self.pendingView.hidden = NO;
//            [self.pendingView startSpin];
            NSLog(@"download state: Pending");
            break;
        case kPKDownloadButtonState_Downloading:
            self.downloadingButton.hidden = NO;
            NSLog(@"download state: downloading");
            break;
        case kPKDownloadButtonState_Pausing:
            self.pauseDownloadButton.hidden = NO;
            NSLog(@"download state: Pausing");
        break;
        case kPKDownloadButtonState_Downloaded:
        {
            self.downloadedButton.hidden = NO;
            self.hidden = YES;
            self.userInteractionEnabled = NO;
            NSLog(@"download state: Downloaded");
        }
            break;
        case kPKDownloadButtonState_Error:
        {
            self.hidden = YES;
            self.userInteractionEnabled = NO;
        }
            break;
        default:
            NSAssert(NO, @"unsupported state");
            break;
    }
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    return CommonInit([super initWithCoder:decoder]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    return CommonInit([super initWithFrame:frame]);
}

- (void)tintColorDidChange {
	[super tintColorDidChange];
	
//	[self updateButton:self.startDownloadButton title:@"download"];
//	[self updateButton:self.downloadedButton title:@"open"];
}

- (void)setStartDownloadTitle:(NSString *)startDownloadTitle {
    _startDownloadTitle = startDownloadTitle;
    [self updateButton:self.startDownloadButton title:startDownloadTitle];
    
}

- (void)setOpenDownloadedTitle:(NSString *)openDownloadedTitle {
    _openDownloadedTitle = openDownloadedTitle;
    [self updateButton:self.downloadedButton title:openDownloadedTitle];
}

- (void)setProgressTrackColor:(UIColor *)progressTrackColor {
    _progressTrackColor = progressTrackColor;
    self.downloadingButton.progressTrackColor = progressTrackColor;
    self.pauseDownloadButton.progressTrackColor = progressTrackColor;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    self.downloadingButton.progressColor = progressColor;
    self.pauseDownloadButton.progressColor = progressColor;
    [self setNeedsDisplay];
}

- (void)setProgressPendingColor:(UIColor *)progressPendingColor {
    _progressPendingColor = progressPendingColor;
    self.pendingView.circleView.strokeColor = progressPendingColor;
    [self setNeedsDisplay];
}
- (void)setProgressImageWidth:(CGFloat)progressImageWidth {
    [self.pauseDownloadButton setPauseButtonWidth:progressImageWidth];
    [self.downloadingButton setDownloadingButtonWidth:progressImageWidth];
//    [self.downloadedButton se];
//    [self.startDownloadButton set];
    [self.pendingView setRadius:progressImageWidth];
    [self.stopDownloadButton setStopButtonWidth:progressImageWidth];
    [self setNeedsDisplay];
}
#pragma mark - appearance

- (void)updateButton:(UIButton *)button title:(NSString *)title {
    if (!title) {
        NSAssert(NO, @"title string is nil");
    }
	NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:title attributes:DefaultTitleAttributes(self.tintColor)];
	[button setAttributedTitle:attrTitle forState:UIControlStateNormal];
	NSAttributedString *highlitedTitle = [[NSAttributedString alloc] initWithString:title attributes:HighlitedTitleAttributes()];
	[button setAttributedTitle:highlitedTitle forState:UIControlStateHighlighted];
}

#pragma mark - private methods

- (PKBorderedButton *)createStartDownloadButton {
    PKBorderedButton *startDownloadButton = [PKBorderedButton buttonWithType:UIButtonTypeCustom];
    [startDownloadButton configureDefaultAppearance];
    
	[self updateButton:startDownloadButton title:@"下载"];
	
    [startDownloadButton addTarget:self
                            action:@selector(currentButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
    return startDownloadButton;
}

- (PKStopDownloadButton *)createStopDownloadButton {
    PKStopDownloadButton *stopDownloadButton = [[PKStopDownloadButton alloc] init];
    [stopDownloadButton.stopButton addTarget:self
                                      action:@selector(currentButtonTapped:)
                            forControlEvents:UIControlEventTouchUpInside];
    return stopDownloadButton;
}

- (PKPauseDownloadButton *)createPauseDownloadButton {
    PKPauseDownloadButton *pauseDownloadButton = [[PKPauseDownloadButton alloc] init];
    [pauseDownloadButton.pauseButton addTarget:self
                                        action:@selector(currentButtonTapped:)
                              forControlEvents:UIControlEventTouchUpInside];
    return pauseDownloadButton;
}

- (PKBorderedButton *)createDownloadedButton {
    PKBorderedButton *downloadedButton = [PKBorderedButton buttonWithType:UIButtonTypeCustom];
    [downloadedButton configureDefaultAppearance];

	[self updateButton:downloadedButton title:@"open"];
    
    [downloadedButton addTarget:self
                         action:@selector(currentButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
    return downloadedButton;
}

- (PKDownloadingButton *)createDownloadingButton {
    PKDownloadingButton *downloadingButton = [[PKDownloadingButton alloc] init];
    [downloadingButton.downloadingButton addTarget:self
                                            action:@selector(currentButtonTapped:)
                                  forControlEvents:UIControlEventTouchUpInside];
    return downloadingButton;
}
- (PKPendingView *)createPendingView {
    PKPendingView *pendingView = [[PKPendingView alloc] init];
    [pendingView addTarget:self
                    action:@selector(currentButtonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    return pendingView;
}

- (void)currentButtonTapped:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(downloadButtonTapped:currentState:)]) {
        [self.delegate downloadButtonTapped:self currentState:self.state];
        BlockSafeRun(self.callback, self, self.state);
    }
}

- (void)createSubviews {
    self.stateViews = (__bridge_transfer NSMutableArray *)CFArrayCreateMutable(nil, 0, nil);
    
    PKBorderedButton *startDownloadButton = [self createStartDownloadButton];
    startDownloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:startDownloadButton];
    self.startDownloadButton = startDownloadButton;
    [self.stateViews addObject:startDownloadButton];
    
    PKStopDownloadButton *stopDownloadButton = [self createStopDownloadButton];
    stopDownloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stopDownloadButton];
    self.stopDownloadButton = stopDownloadButton;
    [self.stateViews addObject:stopDownloadButton];
    
    PKPauseDownloadButton *pauseDownloadButton = [self createPauseDownloadButton];
    pauseDownloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:pauseDownloadButton];
    self.pauseDownloadButton = pauseDownloadButton;
    [self.stateViews addObject:pauseDownloadButton];
    
    PKDownloadingButton *downloadingButton = [self createDownloadingButton];
    downloadingButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:downloadingButton];
    self.downloadingButton = downloadingButton;
    [self.stateViews addObject:downloadingButton];
    
    PKBorderedButton *downloadedButton = [self createDownloadedButton];
    downloadedButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:downloadedButton];
    self.downloadedButton = downloadedButton;
    [self.stateViews addObject:downloadedButton];
    
    
    
    PKPendingView *pendingView = [self createPendingView];
    pendingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:pendingView];
    self.pendingView = pendingView;
    [self.stateViews addObject:pendingView];
}

- (NSArray *)createConstraints {
    NSMutableArray *constraints = [NSMutableArray array];
    
    [self.stateViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SafeObjClassCast(UIView, view, obj);
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsForWrappedSubview:view
                                                                               withInsets:UIEdgeInsetsZero]];
    }];
    
    return constraints;
}

@end

