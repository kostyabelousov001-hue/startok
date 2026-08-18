#import "StarTok.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

// Nomad Mode & Global Region Spoofing
%hook CTCarrier

- (NSString *)isoCountryCode {
    StarTokManager *mgr = [StarTokManager sharedManager];
    if (mgr.isNomadActive) {
        return [mgr.nomadCountry lowercaseString];
    }
    return [mgr.currentRegion lowercaseString];
}

- (NSString *)mobileCountryCode {
    StarTokManager *mgr = [StarTokManager sharedManager];
    if (mgr.isNomadActive) {
        if ([mgr.nomadCountry isEqualToString:@"JP"]) return @"440";
        if ([mgr.nomadCountry isEqualToString:@"FR"]) return @"208";
        if ([mgr.nomadCountry isEqualToString:@"BR"]) return @"724";
        if ([mgr.nomadCountry isEqualToString:@"BY"]) return @"257";
        if ([mgr.nomadCountry isEqualToString:@"KZ"]) return @"401";
        return @"310"; // US
    }
    return @"310";
}

- (NSString *)carrierName {
    return @"StarTok Global";
}

%end

// Hook Feed Request Parameters to inject Nomad region on-the-fly
%hook TTFeedFetchParameterModel

- (void)setRegion:(NSString *)region {
    StarTokManager *mgr = [StarTokManager sharedManager];
    if (mgr.isNomadActive) {
        %orig(mgr.nomadCountry);
    } else {
        %orig(mgr.currentRegion);
    }
}

%end
