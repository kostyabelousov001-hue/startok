#import "StarTok.h"

@implementation StarTokManager

+ (instancetype)sharedManager {
    static StarTokManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[StarTokManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userRolesCache = [NSMutableDictionary dictionary];
        _bumpedFriendsSet = [NSMutableSet set];
        _customNicknames = [NSMutableDictionary dictionary];
        _backendUrl = DEFAULT_BACKEND_URL;
        _currentRegion = @"US";
        _nomadCountry = @"JP";
        _isNomadActive = NO;
        [self loadSettings];
        [self initMotionSensor];
    }
    return self;
}

- (void)loadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *customBack = [defaults stringForKey:kStarTokCustomBackend];
    if (customBack && customBack.length > 0) {
        self.backendUrl = customBack;
    }
    self.currentRegion = [self stringForKey:kStarTokRegion defaultVal:@"US"];
    self.isNomadActive = [self boolForKey:kStarTokNomadMode defaultVal:NO];
    self.nomadCountry = [self stringForKey:kStarTokNomadCountry defaultVal:@"JP"];
}

- (void)saveSettings {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)boolForKey:(NSString *)key defaultVal:(BOOL)defaultVal {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) {
        return defaultVal;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (void)setBool:(BOOL)val forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setBool:val forKey:key];
    [self saveSettings];
}

- (NSString *)stringForKey:(NSString *)key defaultVal:(NSString *)defaultVal {
    NSString *val = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    return val ? val : defaultVal;
}

- (void)setString:(NSString *)val forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:val forKey:key];
    [self saveSettings];
}

- (void)triggerHapticFeedback:(UIImpactFeedbackStyle)style {
    if (![self boolForKey:kStarTokHaptics defaultVal:YES]) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
        [generator prepare];
        [generator impactOccurred];
    });
}

- (void)checkUserBadge:(NSString *)userId completion:(void(^)(StarTokRole role, BOOL isBumped))completion {
    if (!userId || userId.length == 0) {
        if (completion) completion(StarTokRoleNone, NO);
        return;
    }
    
    // Check local memory cache first
    NSNumber *cachedRole = self.userRolesCache[userId];
    BOOL isBumped = [self.bumpedFriendsSet containsObject:userId];
    if (cachedRole) {
        if (completion) completion((StarTokRole)[cachedRole integerValue], isBumped);
        return;
    }
    
    // Query Backend asynchronously
    NSString *endpoint = [NSString stringWithFormat:@"%@/api/badges/%@", self.backendUrl, userId];
    NSURL *url = [NSURL URLWithString:endpoint];
    if (!url) {
        if (completion) completion(StarTokRoleNone, isBumped);
        return;
    }
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json && json[@"role"]) {
                NSString *roleStr = [json[@"role"] lowercaseString];
                StarTokRole role = StarTokRoleUser;
                if ([roleStr isEqualToString:@"creator"] || [roleStr isEqualToString:@"admin"]) {
                    role = StarTokRoleCreator;
                } else if ([roleStr isEqualToString:@"tester"]) {
                    role = StarTokRoleTester;
                } else if ([roleStr isEqualToString:@"none"]) {
                    role = StarTokRoleNone;
                }
                
                BOOL backendBumped = [json[@"bumped"] boolValue];
                if (backendBumped) {
                    [self.bumpedFriendsSet addObject:userId];
                }
                
                self.userRolesCache[userId] = @(role);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(role, backendBumped || isBumped);
                });
                return;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(StarTokRoleNone, isBumped);
        });
    }];
    [task resume];
}

- (void)initMotionSensor {
    self.motionManager = [[CMMotionManager alloc] init];
    if (self.motionManager.isAccelerometerAvailable) {
        self.motionManager.accelerometerUpdateInterval = 0.1;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *data, NSError *error) {
            if (data) {
                double totalForce = sqrt(data.acceleration.x * data.acceleration.x +
                                         data.acceleration.y * data.acceleration.y +
                                         data.acceleration.z * data.acceleration.z);
                if (totalForce > 2.5) { // Significant shake threshold
                    static NSTimeInterval lastShakeTime = 0;
                    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                    if (now - lastShakeTime > 3.0) { // Debounce 3 seconds
                        lastShakeTime = now;
                        [self registerShakeBumpWithCompletion:nil];
                    }
                }
            }
        }];
    }
}

- (void)registerShakeBumpWithCompletion:(void(^)(BOOL success, NSString *bumpedFriendName))completion {
    [self triggerHapticFeedback:UIImpactFeedbackStyleHeavy];
    
    NSString *endpoint = [NSString stringWithFormat:@"%@/api/bump", self.backendUrl];
    NSURL *url = [NSURL URLWithString:endpoint];
    if (!url) return;
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *body = @{
        @"timestamp": @([[NSDate date] timeIntervalSince1970]),
        @"device_id": [[[UIDevice currentDevice] identifierForVendor] UUIDString] ?: @"unknown"
    };
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data) {
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([res[@"status"] isEqualToString:@"bumped"]) {
                NSString *friendId = res[@"friend_id"] ?: @"friend";
                NSString *friendName = res[@"friend_name"] ?: @"Друг со StarTok";
                [self.bumpedFriendsSet addObject:friendId];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self triggerHapticFeedback:UIImpactFeedbackStyleRigid];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"⚡ StarBump!"
                                                                                   message:[NSString stringWithFormat:@"Вы только что забампились с %@!", friendName]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"Огонь 🔥" style:UIAlertActionStyleDefault handler:nil]];
                    
                    UIViewController *topVC = [UIApplication sharedApplication].windows.firstObject.rootViewController;
                    while (topVC.presentedViewController) {
                        topVC = topVC.presentedViewController;
                    }
                    [topVC presentViewController:alert animated:YES completion:nil];
                    if (completion) completion(YES, friendName);
                });
                return;
            }
        }
        if (completion) completion(NO, nil);
    }];
    [task resume];
}

@end
