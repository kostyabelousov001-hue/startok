#import "StarTok.h"

// SVG Vector Badge View using CoreGraphics / CAShapeLayer
@interface StarBadgeView : UIView
@property (nonatomic, assign) StarTokRole role;
@property (nonatomic, assign) BOOL isBumped;
- (instancetype)initWithRole:(StarTokRole)role isBumped:(BOOL)isBumped;
@end

@implementation StarBadgeView

- (instancetype)initWithRole:(StarTokRole)role isBumped:(BOOL)isBumped {
    self = [super initWithFrame:CGRectMake(0, 0, isBumped ? 38 : 18, 18)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _role = role;
        _isBumped = isBumped;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBadgeTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)handleBadgeTap {
    [[StarTokManager sharedManager] triggerHapticFeedback:UIImpactFeedbackStyleLight];
    NSString *roleTitle = @"Пользователь StarTok ⭐";
    NSString *roleDesc = @"Этот пользователь использует официальный мод StarTok.";
    
    if (self.role == StarTokRoleCreator) {
        roleTitle = @"👑 Создатель StarTok";
        roleDesc = @"Официальный разработчик и создатель мода StarTok!";
    } else if (self.role == StarTokRoleTester) {
        roleTitle = @"🧪 Тестер StarTok";
        roleDesc = @"Официальный бета-тестер новых функций StarTok.";
    }
    
    if (self.isBumped) {
        roleDesc = [roleDesc stringByAppendingString:@"\n\n⚡ Вы забампились в реале!"];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:roleTitle
                                                                   message:roleDesc
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Понятно" style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *topVC = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    [topVC presentViewController:alert animated:YES completion:nil];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;
    
    // Draw Star / Crown Badge
    if (self.role != StarTokRoleNone) {
        CGRect badgeRect = CGRectMake(0, 0, 18, 18);
        UIColor *fillColor = [UIColor colorWithRed:0.20 green:0.80 blue:1.0 alpha:1.0]; // Star Cyan
        
        if (self.role == StarTokRoleCreator) {
            fillColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0]; // Gold
        } else if (self.role == StarTokRoleTester) {
            fillColor = [UIColor colorWithRed:0.75 green:0.35 blue:0.95 alpha:1.0]; // Purple
        }
        
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        
        // Draw crisp 5-point Vector Star
        CGFloat centerX = 9.0;
        CGFloat centerY = 9.0;
        CGFloat rOuter = 8.0;
        CGFloat rInner = 3.8;
        
        UIBezierPath *starPath = [UIBezierPath bezierPath];
        for (int i = 0; i < 5; i++) {
            CGFloat angleOuter = (i * 72.0 - 90.0) * M_PI / 180.0;
            CGFloat angleInner = (i * 72.0 + 36.0 - 90.0) * M_PI / 180.0;
            CGPoint ptOuter = CGPointMake(centerX + rOuter * cos(angleOuter), centerY + rOuter * sin(angleOuter));
            CGPoint ptInner = CGPointMake(centerX + rInner * cos(angleInner), centerY + rInner * sin(angleInner));
            
            if (i == 0) {
                [starPath moveToPoint:ptOuter];
            } else {
                [starPath addLineToPoint:ptOuter];
            }
            [starPath addLineToPoint:ptInner];
        }
        [starPath closePath];
        [fillColor setFill];
        [starPath fill];
    }
    
    // Draw Bump Lightning Bolt if Bumped
    if (self.isBumped) {
        CGFloat boltOffsetX = (self.role != StarTokRoleNone) ? 20.0 : 0.0;
        UIBezierPath *boltPath = [UIBezierPath bezierPath];
        [boltPath moveToPoint:CGPointMake(boltOffsetX + 9, 1)];
        [boltPath addLineToPoint:CGPointMake(boltOffsetX + 2, 9)];
        [boltPath addLineToPoint:CGPointMake(boltOffsetX + 7, 9)];
        [boltPath addLineToPoint:CGPointMake(boltOffsetX + 5, 17)];
        [boltPath addLineToPoint:CGPointMake(boltOffsetX + 14, 8)];
        [boltPath addLineToPoint:CGPointMake(boltOffsetX + 9, 8)];
        [boltPath closePath];
        
        [[UIColor colorWithRed:1.0 green:0.85 blue:0.1 alpha:1.0] setFill];
        [boltPath fill];
    }
}

@end

// Hooking TikTok Comment and Profile username views
%hook AWECommentAuthorView

- (void)configWithComment:(id)comment {
    %orig;
    
    // Retrieve userId from comment model if available
    NSString *userId = nil;
    @try {
        id author = [comment valueForKey:@"author"];
        userId = [author valueForKey:@"uid"] ?: [author valueForKey:@"secUid"];
    } @catch (NSException *e) {}
    
    if (userId) {
        [[StarTokManager sharedManager] checkUserBadge:userId completion:^(StarTokRole role, BOOL isBumped) {
            if (role != StarTokRoleNone || isBumped) {
                // Attach StarBadgeView next to username label
                UIView *existing = [self viewWithTag:889911];
                [existing removeFromSuperview];
                
                StarBadgeView *badge = [[StarBadgeView alloc] initWithRole:role isBumped:isBumped];
                badge.tag = 889911;
                badge.frame = CGRectMake(self.bounds.size.width + 4, (self.bounds.size.height - 18) / 2, badge.frame.size.width, 18);
                [self addSubview:badge];
            }
        }];
    }
}

%end
