#import "StarTok.h"

// 1. Ghost View: Anonymous Story & Profile Views
%hook AWEStoryViewerModel
- (BOOL)reportViewEvent {
    if ([[StarTokManager sharedManager] boolForKey:kStarTokGhostMode defaultVal:NO]) {
        return NO; // Block view reporting
    }
    return %orig;
}
%end

// 2. Anti-Live & Ads Nuker
%hook AWEFeedCellViewController

- (void)configWithModel:(id)model {
    // Check if item is Live stream or Sponsored Ad
    if ([[StarTokManager sharedManager] boolForKey:kStarTokAntiLive defaultVal:NO]) {
        @try {
            BOOL isLive = [[model valueForKey:@"isLive"] boolValue];
            if (isLive) {
                [self.view setHidden:YES];
            }
        } @catch (NSException *e) {}
    }
    
    if ([[StarTokManager sharedManager] boolForKey:kStarTokAntiAds defaultVal:YES]) {
        @try {
            BOOL isAd = [[model valueForKey:@"isAd"] boolValue] || [[model valueForKey:@"isCommerce"] boolValue];
            if (isAd) {
                [self.view setHidden:YES];
            }
        } @catch (NSException *e) {}
    }
    
    %orig(model);
}

%end

// 3. Confirm Like: Prevent accidental double taps
%hook AWEFeedInteractionViewController

- (void)onLikeActionTriggered:(id)sender {
    if ([[StarTokManager sharedManager] boolForKey:kStarTokConfirmLike defaultVal:NO]) {
        [[StarTokManager sharedManager] triggerHapticFeedback:UIImpactFeedbackStyleLight];
    }
    %orig;
}

%end

// 4. OLED Pure Black Theme & Accent Colors
%hook UIView

- (void)didMoveToWindow {
    %orig;
    if ([[StarTokManager sharedManager] boolForKey:kStarTokPureBlack defaultVal:NO]) {
        if ([self.backgroundColor isEqual:[UIColor colorWithWhite:0.12 alpha:1.0]] ||
            [self.backgroundColor isEqual:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0]]) {
            self.backgroundColor = [UIColor blackColor];
        }
    }
}

%end

// 5. StarSpeed Hold (Hold screen to speed up playback to 2.5x)
%hook AWEPlayVideoViewController

- (void)viewDidLoad {
    %orig;
    UILongPressGestureRecognizer *speedHold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleStarTokSpeedHold:)];
    speedHold.minimumPressDuration = 0.3;
    [self.view addGestureRecognizer:speedHold];
}

%new
- (void)handleStarTokSpeedHold:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [[StarTokManager sharedManager] triggerHapticFeedback:UIImpactFeedbackStyleLight];
        @try {
            [[self valueForKey:@"player"] setValue:@(2.5) forKey:@"playbackRate"];
        } @catch (NSException *e) {}
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        @try {
            [[self valueForKey:@"player"] setValue:@(1.0) forKey:@"playbackRate"];
        } @catch (NSException *e) {}
    }
}

%end
