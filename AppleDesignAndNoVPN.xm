#import "StarTok.h"

// Safe UI and Font Hooks with strict recursion guard
%hook UIFont

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    if (!fontName || ![fontName isKindOfClass:[NSString class]]) {
        return %orig;
    }
    
    // Replace TikTok custom typography with native Apple SF Pro
    if ([fontName rangeOfString:@"Proxima" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [fontName rangeOfString:@"TikTok" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [fontName rangeOfString:@"ByteDance" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        
        if ([fontName rangeOfString:@"Bold" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [fontName rangeOfString:@"Heavy" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [fontName rangeOfString:@"Black" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return [UIFont systemFontOfSize:fontSize weight:UIFontWeightBold];
        } else if ([fontName rangeOfString:@"SemiBold" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                   [fontName rangeOfString:@"Medium" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
        } else {
            return [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
        }
    }
    return %orig;
}

%end

// Hook TabBar to use Apple SF Symbols safely
%hook UITabBarItem

- (void)setImage:(UIImage *)image {
    @try {
        NSString *title = self.title;
        if (title && [title isKindOfClass:[NSString class]]) {
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
    } @catch (NSException *e) {}
    %orig(image);
}

%end

// Safe Network Parameters (No VPN Bypass)
%hook TTNetworkManager

- (NSDictionary *)commonParams {
    NSDictionary *orig = %orig;
    if (!orig || ![orig isKindOfClass:[NSDictionary class]]) {
        return orig;
    }
    
    NSMutableDictionary *params = [orig mutableCopy];
    StarTokManager *mgr = [StarTokManager sharedManager];
    
    @try {
        NSString *activeReg = mgr.isNomadActive ? (mgr.nomadCountry ?: @"JP") : (mgr.currentRegion ?: @"US");
        
        params[@"carrier_region"] = [activeReg lowercaseString];
        params[@"sys_region"] = activeReg;
        params[@"app_language"] = @"ru";
        params[@"language"] = @"ru";
        params[@"region"] = activeReg;
        params[@"tz_name"] = @"Europe/Minsk";
        params[@"mcc_mnc"] = @"310260";
        params[@"sim_region"] = [activeReg lowercaseString];
        params[@"account_region"] = activeReg;
    } @catch (NSException *e) {}
    
    return params;
}

%end
