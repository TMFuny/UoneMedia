//
//  PKDownloadButton.h
//  PKDownloadButton
//
//  Created by Pavel on 28/05/15.
//  Copyright (c) 2015 Katunin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKStopDownloadButton.h"
#import "PKPauseDownloadButton.h"
#import "PKBorderedButton.h"
#import "PKDownloadingButton.h"
#import "PKPendingView.h"


typedef NS_ENUM(NSUInteger, PKDownloadButtonState) {
    kPKDownloadButtonState_StartDownload,   //wait for user tap to download
    kPKDownloadButtonState_Pending,         //ready for download
    kPKDownloadButtonState_Downloading,     //downloading
    kPKDownloadButtonState_Pausing,         //pause
    kPKDownloadButtonState_Downloaded,      //complete
    kPKDownloadButtonState_Error,           //error
};

@class PKDownloadButton;

typedef void(^DownloadButtonTappedCallback)(PKDownloadButton *downloadButton, PKDownloadButtonState state);

@protocol PKDownloadButtonDelegate <NSObject>

- (void)downloadButtonTapped:(PKDownloadButton *)downloadButton
                currentState:(PKDownloadButtonState)state;

@end

IB_DESIGNABLE
@interface PKDownloadButton : UIView

@property (nonatomic, weak) IBOutlet id <PKDownloadButtonDelegate> delegate;
@property (nonatomic, copy) DownloadButtonTappedCallback callback;

@property (nonatomic, weak, readonly) PKBorderedButton *startDownloadButton;
@property (nonatomic, weak, readonly) PKStopDownloadButton *stopDownloadButton;
@property (nonatomic, weak, readonly) PKPauseDownloadButton *pauseDownloadButton;
@property (nonatomic, weak, readonly) PKDownloadingButton *downloadingButton;
@property (nonatomic, weak, readonly) PKBorderedButton *downloadedButton;
@property (nonatomic, weak, readonly) PKPendingView *pendingView;

@property (nonatomic, strong) NSString *startDownloadTitle;
@property (nonatomic, strong) NSString *openDownloadedTitle;

@property (nonatomic) IBInspectable UIColor *progressColor;
@property (nonatomic) IBInspectable UIColor *progressTrackColor;
@property (nonatomic) IBInspectable UIColor *progressPendingColor;

@property (nonatomic, assign) PKDownloadButtonState state;

@end