#import "StarTok.h"

// Safe main initialization hook
%hook UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @try {
            [[StarTokManager sharedManager] loadSettings];
            NSLog(@"[StarTok] Successfully initialized StarTok v%@ in TikTok process!", STARTOK_VERSION);
        } @catch (NSException *e) {
            NSLog(@"[StarTok] Error initializing settings: %@", e);
        }
    });
    
    return result;
}

%end
