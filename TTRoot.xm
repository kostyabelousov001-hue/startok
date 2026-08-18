#import "StarTok.h"

%ctor {
    @autoreleasepool {
        NSLog(@"[StarTok] Initializing StarTok v%@ engine...", STARTOK_VERSION);
        [[StarTokManager sharedManager] loadSettings];
        
        // Show startup toast on first view launch
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"[StarTok] StarTok successfully loaded into TikTok process!");
        });
    }
}
