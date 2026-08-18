#import "StarTok.h"

// Safe Region Spoofing (hooking region resolvers instead of fragile low-level CTCarrier)
%hook NSLocale

- (NSString *)countryCode {
    StarTokManager *mgr = [StarTokManager sharedManager];
    if (mgr.isNomadActive) {
        return mgr.nomadCountry ?: @"JP";
    }
    return mgr.currentRegion ?: @"US";
}

%end

// Hook TikTok Internal Region Utility
%hook AWEAppContextConfig

- (NSString *)currentRegion {
    StarTokManager *mgr = [StarTokManager sharedManager];
    if (mgr.isNomadActive) {
        return mgr.nomadCountry ?: @"JP";
    }
    return mgr.currentRegion ?: @"US";
}

- (NSString *)carrierRegion {
    StarTokManager *mgr = [StarTokManager sharedManager];
    if (mgr.isNomadActive) {
        return [mgr.nomadCountry lowercaseString] ?: @"jp";
    }
    return [mgr.currentRegion lowercaseString] ?: @"us";
}

%end
