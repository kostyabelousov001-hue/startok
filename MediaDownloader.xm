#import "StarTok.h"

// No Watermark & Media Downloader Helper using standard UIKit & Photos Album selector
@interface StarTokDownloader : NSObject
+ (void)downloadVideoFromURL:(NSURL *)url completion:(void(^)(BOOL success))completion;
+ (void)saveImageToPhotos:(UIImage *)image completion:(void(^)(BOOL success))completion;
@end

@implementation StarTokDownloader

+ (void)downloadVideoFromURL:(NSURL *)url completion:(void(^)(BOOL success))completion {
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data) {
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"startok_download.mp4"];
            [data writeToFile:tempPath atomically:YES];
            
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempPath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(tempPath, nil, nil, nil);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[StarTokManager sharedManager] triggerHapticFeedback:UIImpactFeedbackStyleMedium];
                    if (completion) completion(YES);
                });
            } else {
                if (completion) completion(NO);
            }
        } else {
            if (completion) completion(NO);
        }
    }];
    [task resume];
}

+ (void)saveImageToPhotos:(UIImage *)image completion:(void(^)(BOOL success))completion {
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[StarTokManager sharedManager] triggerHapticFeedback:UIImpactFeedbackStyleMedium];
            if (completion) completion(YES);
        });
    } else {
        if (completion) completion(NO);
    }
}

@end

// Hook TikTok Video Model to disable watermark and expose clean bitstream
%hook AWEAwemeModel

- (BOOL)isWatermarkEnabled {
    return NO; // Suppress watermark completely
}

- (BOOL)preventDownload {
    return NO; // Unlock download for all videos even if restricted by creator
}

%end

// Avatar Peek & HD Zoom: Hook avatar view to add long-press gesture for full HD zoom
%hook AWEAvatarImageView

- (void)didMoveToSuperview {
    %orig;
    self.userInteractionEnabled = YES;
    
    // Add long press gesture
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleStarTokAvatarZoom:)];
    lp.minimumPressDuration = 0.4;
    [self addGestureRecognizer:lp];
}

%new
- (void)handleStarTokAvatarZoom:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [[StarTokManager sharedManager] triggerHapticFeedback:UIImpactFeedbackStyleMedium];
        UIImage *currentAvatar = [(UIImageView *)self image];
        if (!currentAvatar) return;
        
        // Present fullscreen zoom controller
        UIViewController *topVC = [UIApplication sharedApplication].windows.firstObject.rootViewController;
        while (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }
        
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"🔍 StarTok HD Avatar"
                                                                       message:@"Сохранить аватарку в галерею?"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [sheet addAction:[UIAlertAction actionWithTitle:@"Сохранить в Фото" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [StarTokDownloader saveImageToPhotos:currentAvatar completion:^(BOOL success) {
                UIAlertController *toast = [UIAlertController alertControllerWithTitle:success ? @"✅ Сохранено" : @"❌ Ошибка"
                                                                               message:success ? @"Аватарка успешно сохранена в Фото" : @"Не удалось сохранить"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [toast addAction:[UIAlertAction actionWithTitle:@"Ок" style:UIAlertActionStyleDefault handler:nil]];
                [topVC presentViewController:toast animated:YES completion:nil];
            }];
        }]];
        [sheet addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
        [topVC presentViewController:sheet animated:YES completion:nil];
    }
}

%end
