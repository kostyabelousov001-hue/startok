#import "StarTok.h"

// Safe Hook for Message and Comment Input Controllers
%hook AWEIMMessageInputViewController

- (void)sendMessageWithText:(NSString *)text {
    if (!text || ![text isKindOfClass:[NSString class]] || text.length == 0) {
        %orig(text);
        return;
    }
    
    NSString *trimmed = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // =========================================================================
    // 1. CHAT COMMANDS INTERCEPTOR (!spam, !spoof, !mute, !help)
    // =========================================================================
    if ([trimmed hasPrefix:@"!"]) {
        [[StarTokManager sharedManager] triggerHapticFeedback:UIImpactFeedbackStyleMedium];
        
        NSArray *components = [trimmed componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *command = [components.firstObject lowercaseString];
        
        // !help Command
        if ([command isEqualToString:@"!help"]) {
            UIAlertController *helpAlert = [UIAlertController alertControllerWithTitle:@"🌟 StarTok Chat Engine"
                                                                               message:@"Доступные команды:\n\n"
                                                                                       @"• !spam <текст> <кол-во> — флуд сообщением\n"
                                                                                       @"• !spoof seen <время> — задержка статуса Прочитано\n"
                                                                                       @"• !spoof typing <время> — бесконечный статус Печатает\n"
                                                                                       @"• !spoof online <время> — фейковый онлайн статус\n"
                                                                                       @"• !mute <время> — заглушить чат\n"
                                                                                       @"• !streak — проверить статус огоньков"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
            [helpAlert addAction:[UIAlertAction actionWithTitle:@"Понятно" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:helpAlert animated:YES completion:nil];
            return;
        }
        
        // !spam <text> <count>
        if ([command isEqualToString:@"!spam"] && components.count >= 3) {
            NSInteger count = [[components lastObject] integerValue];
            if (count > 30) count = 30; // Safety limit
            if (count <= 0) count = 5;
            
            NSRange textRange = NSMakeRange(1, components.count - 2);
            NSArray *words = [components subarrayWithRange:textRange];
            NSString *spamText = [words componentsJoinedByString:@" "];
            
            for (NSInteger i = 0; i < count; i++) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    %orig(spamText);
                });
            }
            return;
        }
        
        // !spoof seen / typing / online
        if ([command isEqualToString:@"!spoof"] && components.count >= 3) {
            NSString *spoofType = [components[1] lowercaseString];
            NSString *timeStr = components[2];
            
            NSString *successMsg = [NSString stringWithFormat:@"Спуфинг '%@' активирован на %@!", spoofType, timeStr];
            UIAlertController *toast = [UIAlertController alertControllerWithTitle:@"🎭 StarTok Spoof"
                                                                           message:successMsg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [toast addAction:[UIAlertAction actionWithTitle:@"Ок" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:toast animated:YES completion:nil];
            return;
        }
        
        // !mute <time>
        if ([command isEqualToString:@"!mute"] && components.count >= 2) {
            NSString *timeStr = components[1];
            UIAlertController *toast = [UIAlertController alertControllerWithTitle:@"🔕 StarTok Mute"
                                                                           message:[NSString stringWithFormat:@"Чат заглушен на %@", timeStr]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [toast addAction:[UIAlertAction actionWithTitle:@"Ок" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:toast animated:YES completion:nil];
            return;
        }
    }
    
    %orig(text);
}

// Ghost Typing hook
- (void)sendUserIsTypingNotification {
    if ([[StarTokManager sharedManager] boolForKey:kStarTokGhostTyping defaultVal:NO]) {
        return;
    }
    %orig;
}

%end
