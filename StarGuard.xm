#import "StarTok.h"

// List of forbidden toxic / forced spam phrases
static NSArray *forbiddenPhrases() {
    static NSArray *phrases = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        phrases = @[
            @"коч",
            @"коч братан",
            @"галда",
            @"голда",
            @"кабилджон",
            @"кобилджон",
            @"горка-2",
            @"горки-2"
        ];
    });
    return phrases;
}

static BOOL containsForbiddenWords(NSString *text) {
    if (!text || text.length == 0) return NO;
    
    // Normalize string: lowercase, trim, remove excessive spaces
    NSString *normalized = [[text lowercaseString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    normalized = [normalized stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    
    for (NSString *phrase in forbiddenPhrases()) {
        if ([normalized containsString:phrase]) {
            return YES;
        }
    }
    return NO;
}

static void triggerInstantSafetyCrash() {
    NSLog(@"[StarTok StarGuard] CRITICAL: Forbidden toxic spam word detected! Executing instant crash termination.");
    // Instant termination of app process
    exit(0);
}

// 1. Hook Comment Input View Controller
%hook AWECommentInputViewController

- (void)sendCommentWithText:(NSString *)text {
    if (containsForbiddenWords(text)) {
        triggerInstantSafetyCrash();
        return; // Execution won't even reach here due to exit(0)
    }
    %orig(text);
}

%end

// 2. Hook Direct Message Input Field
%hook AWEIMMessageInputViewController

- (void)didTapSendButtonWithContent:(NSString *)content {
    if (containsForbiddenWords(content)) {
        triggerInstantSafetyCrash();
        return;
    }
    %orig(content);
}

%end
