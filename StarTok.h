#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

// =========================================================================
// StarTok Global Configuration & Constants
// =========================================================================
#define STARTOK_VERSION @"2.0.0"
#define STARTOK_PREFS_PATH @"/var/mobile/Library/Preferences/com.startok.prefs.plist"
#define DEFAULT_BACKEND_URL @"https://api.startok.app"

// Keys for NSUserDefaults / Preferences
#define kStarTokEnabled @"st_enabled"
#define kStarTokRegion @"st_region"
#define kStarTokNomadMode @"st_nomad_mode"
#define kStarTokNomadCountry @"st_nomad_country"
#define kStarTokNoWatermark @"st_no_watermark"
#define kStarTokGhostMode @"st_ghost_mode"
#define kStarTokGhostTyping @"st_ghost_typing"
#define kStarTokPureBlack @"st_pure_black"
#define kStarTokAccentColor @"st_accent_color"
#define kStarTokFont @"st_font"
#define kStarTokSpeedMultiplier @"st_speed_multiplier"
#define kStarTokAntiLive @"st_anti_live"
#define kStarTokAntiAds @"st_anti_ads"
#define kStarTokConfirmLike @"st_confirm_like"
#define kStarTokHaptics @"st_haptics"
#define kStarTokStreakSaver @"st_streak_saver"
#define kStarTokAutoTranslate @"st_auto_translate"
#define kStarTokCustomBackend @"st_custom_backend"

// User Roles for Badges
typedef NS_ENUM(NSInteger, StarTokRole) {
    StarTokRoleNone = 0,
    StarTokRoleUser = 1,
    StarTokRoleTester = 2,
    StarTokRoleCreator = 3
};

// Manager Interface for Global State
@interface StarTokManager : NSObject

@property (nonatomic, strong) NSString *backendUrl;
@property (nonatomic, strong) NSString *currentRegion;
@property (nonatomic, assign) BOOL isNomadActive;
@property (nonatomic, strong) NSString *nomadCountry;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *userRolesCache;
@property (nonatomic, strong) NSMutableSet<NSString *> *bumpedFriendsSet;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *customNicknames;
@property (nonatomic, strong) CMMotionManager *motionManager;

+ (instancetype)sharedManager;
- (void)loadSettings;
- (void)saveSettings;
- (BOOL)boolForKey:(NSString *)key defaultVal:(BOOL)defaultVal;
- (void)setBool:(BOOL)val forKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key defaultVal:(NSString *)defaultVal;
- (void)setString:(NSString *)val forKey:(NSString *)key;
- (void)triggerHapticFeedback:(UIImpactFeedbackStyle)style;
- (void)checkUserBadge:(NSString *)userId completion:(void(^)(StarTokRole role, BOOL isBumped))completion;
- (void)registerShakeBumpWithCompletion:(void(^)(BOOL success, NSString *bumpedFriendName))completion;

@end
