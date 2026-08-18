#import "StarTok.h"

// 1. Ghost View: Anonymous Story & Profile Views
%hook AWEStoryViewerModel
- (BOOL)reportViewEvent {
    if ([[StarTokManager sharedManager] boolForKey:kStarTokGhostMode defaultVal:NO]) {
        return NO;
    }
    return %orig;
}
%end

// 2. Anti-Live & Ads Nuker
%hook AWEFeedCellViewController

- (void)configWithModel:(id)model {
    %orig(model);
    if (!model) return;
    
    @try {
        if ([[StarTokManager sharedManager] boolForKey:kStarTokAntiLive defaultVal:NO]) {
            if ([model respondsToSelector:@selector(isLive)] && [[model valueForKey:@"isLive"] boolValue]) {
                [self.view setHidden:YES];
            }
        }
        if ([[StarTokManager sharedManager] boolForKey:kStarTokAntiAds defaultVal:YES]) {
            if (([model respondsToSelector:@selector(isAd)] && [[model valueForKey:@"isAd"] boolValue]) ||
                ([model respondsToSelector:@selector(isCommerce)] && [[model valueForKey:@"isCommerce"] boolValue])) {
                [self.view setHidden:YES];
            }
        }
    } @catch (NSException *e) {}
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

// 4. StarSpeed Hold (Hold screen to speed up playback to 2.5x)
%hook AWEPlayVideoViewController

- (void)viewDidLoad {
    %orig;
    @try {
        UILongPressGestureRecognizer *speedHold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleStarTokSpeedHold:)];
        speedHold.minimumPressDuration = 0.3;
        [self.view addGestureRecognizer:speedHold];
    } @catch (NSException *e) {}
}

%new
- (void)handleStarTokSpeedHold:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [[StarTokManager sharedManager] triggerHapticFeedback:UIImpactFeedbackStyleLight];
        @try {
            if ([self respondsToSelector:@selector(player)]) {
                [[self valueForKey:@"player"] setValue:@(2.5) forKey:@"playbackRate"];
            }
        } @catch (NSException *e) {}
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        @try {
            if ([self respondsToSelector:@selector(player)]) {
                [[self valueForKey:@"player"] setValue:@(1.0) forKey:@"playbackRate"];
            }
        } @catch (NSException *e) {}
    }
}

%end
