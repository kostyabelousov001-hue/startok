#import "StarTok.h"

// =========================================================================
// 1. APPLE SYSTEM FONTS (SF Pro Display / SF Pro Text) OVERRIDE EVERYWHERE
// =========================================================================
%hook UIFont

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    // Intercept TikTok custom fonts (ProximaNova, TikTokFont, etc.) and replace with Apple SF Pro
    if ([fontName containsString:@"Proxima"] || 
        [fontName containsString:@"TikTok"] || 
        [fontName containsString:@"ByteDance"] ||
        [fontName containsString:@"Avenir"]) {
        
        if ([fontName containsString:@"Bold"] || [fontName containsString:@"Heavy"] || [fontName containsString:@"Black"]) {
            return [UIFont systemFontOfSize:fontSize weight:UIFontWeightBold];
        } else if ([fontName containsString:@"SemiBold"] || [fontName containsString:@"Medium"]) {
            return [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
        } else {
            return [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
        }
    }
    return %orig;
}

%end

// =========================================================================
// 2. APPLE NATIVE SF SYMBOLS & ICONS FOR TIKTOK TABS & ACTIONS
// =========================================================================
%hook UITabBarItem

- (void)setImage:(UIImage *)image {
    NSString *title = self.title;
    if (title) {
        if ([title containsString:@"Главная"] || [title containsString:@"Home"]) {
            %orig([UIImage systemImageNamed:@"house.fill"]);
            return;
        } else if ([title containsString:@"Друзья"] || [title containsString:@"Friends"]) {
            %orig([UIImage systemImageNamed:@"person.2.fill"]);
            return;
        } else if ([title containsString:@"Входящие"] || [title containsString:@"Inbox"]) {
            %orig([UIImage systemImageNamed:@"bubble.left.and.bubble.right.fill"]);
            return;
        } else if ([title containsString:@"Профиль"] || [title containsString:@"Profile"]) {
            %orig([UIImage systemImageNamed:@"person.crop.circle.fill"]);
            return;
        }
    }
    %orig;
}

%end

// =========================================================================
// 3. WORK WITHOUT VPN (BYPASS SNI / IP RESTRICTIONS & REGION RESOLUTION)
// =========================================================================
%hook TTNetworkManager

- (NSDictionary *)commonParams {
    NSMutableDictionary *params = [%orig mutableCopy] ?: [NSMutableDictionary dictionary];
    StarTokManager *mgr = [StarTokManager sharedManager];
    
    // Inject non-restricted Region & Carrier directly into TTNet network stack
    NSString *activeReg = mgr.isNomadActive ? (mgr.nomadCountry ?: @"JP") : (mgr.currentRegion ?: @"US");
    
    params[@"carrier_region"] = [activeReg lowercaseString];
    params[@"sys_region"] = activeReg;
    params[@"app_language"] = @"ru";
    params[@"language"] = @"ru";
    params[@"region"] = activeReg;
    params[@"tz_name"] = @"Europe/Minsk"; // Clean timezone for non-VPN bypass
    params[@"mcc_mnc"] = @"310260";
    params[@"sim_region"] = [activeReg lowercaseString];
    params[@"account_region"] = activeReg;
    
    return params;
}

%end

// Safe Region & Config Hooks
%hook AWEAppContextConfig

- (NSString *)currentRegion {
    StarTokManager *mgr = [StarTokManager sharedManager];
    return mgr.isNomadActive ? (mgr.nomadCountry ?: @"JP") : (mgr.currentRegion ?: @"US");
}

- (NSString *)carrierRegion {
    StarTokManager *mgr = [StarTokManager sharedManager];
    return [mgr.isNomadActive ? (mgr.nomadCountry ?: @"JP") : (mgr.currentRegion ?: @"US") lowercaseString];
}

- (NSString *)userRegion {
    StarTokManager *mgr = [StarTokManager sharedManager];
    return mgr.isNomadActive ? (mgr.nomadCountry ?: @"JP") : (mgr.currentRegion ?: @"US");
}

%end
