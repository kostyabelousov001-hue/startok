#import "StarTok.h"

// iOS Settings UI for StarTok
@interface StarSettingsViewController : UITableViewController
@end

@implementation StarSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"🌟 Настройки StarTok";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSettings)];
}

- (void)dismissSettings {
    [[StarTokManager sharedManager] saveSettings];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"🌍 РЕГИОН И СЕТЬ";
        case 1: return @"👑 РОЛИ И STARBUMP";
        case 2: return @"💬 ЧАТ, СТРИКИ И СИСТЕМА";
        case 3: return @"🎨 ИНТЕРФЕЙС И ТЕМА";
        case 4: return @"🛡️ STARGUARD & БЕЗОПАСНОСТЬ";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 2; // Region + Nomad Mode
        case 1: return 2; // Check My Role + Test Bump
        case 2: return 3; // Streak Saver + Ghost Typing + Chat Commands Info
        case 3: return 4; // OLED Black + No Watermark + Anti Ads + Speed Hold
        case 4: return 2; // Stop List Info + Backend URL
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StarTokCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"StarTokCell"];
    }
    cell.accessoryView = nil;
    cell.detailTextLabel.text = @"";
    StarTokManager *mgr = [StarTokManager sharedManager];

    // Section 0: Region & Nomad
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Основной регион";
            cell.detailTextLabel.text = mgr.currentRegion;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Режим загадочного иностранца";
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = mgr.isNomadActive;
            [sw addTarget:self action:@selector(toggleNomad:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
        }
    }
    // Section 1: Roles & Bump
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Мой статус и бейдж";
            cell.detailTextLabel.text = @"Проверить ⭐";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Протестировать StarBump ⚡";
            cell.detailTextLabel.text = @"Потрясти";
        }
    }
    // Section 2: Chat & Streaks
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Streak Saver (Спасение огоньков)";
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokStreakSaver defaultVal:YES];
            [sw addTarget:self action:@selector(toggleStreakSaver:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Ghost Typing (Скрытый набор)";
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokGhostTyping defaultVal:NO];
            [sw addTarget:self action:@selector(toggleGhostTyping:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Команды чата (!help)";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    // Section 3: Interface & Theme
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"OLED Pure Black (100% Черный)";
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokPureBlack defaultVal:NO];
            [sw addTarget:self action:@selector(togglePureBlack:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Скачивание без вотермарки";
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = YES;
            sw.enabled = NO; // Always on
            cell.accessoryView = sw;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Блокировка рекламы & Shop";
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokAntiAds defaultVal:YES];
            [sw addTarget:self action:@selector(toggleAntiAds:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"StarSpeed перемотка удержанием";
            cell.detailTextLabel.text = @"2.5x";
        }
    }
    // Section 4: StarGuard & Backend
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"StarGuard Защита";
            cell.detailTextLabel.text = @"Активна (Instant Crash)";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Сервер StarTok";
            cell.detailTextLabel.text = mgr.backendUrl;
        }
    }
    
    return cell;
}

- (void)toggleNomad:(UISwitch *)sw {
    [[StarTokManager sharedManager] setBool:sw.on forKey:kStarTokNomadMode];
    [StarTokManager sharedManager].isNomadActive = sw.on;
}

- (void)toggleStreakSaver:(UISwitch *)sw {
    [[StarTokManager sharedManager] setBool:sw.on forKey:kStarTokStreakSaver];
}

- (void)toggleGhostTyping:(UISwitch *)sw {
    [[StarTokManager sharedManager] setBool:sw.on forKey:kStarTokGhostTyping];
}

- (void)togglePureBlack:(UISwitch *)sw {
    [[StarTokManager sharedManager] setBool:sw.on forKey:kStarTokPureBlack];
}

- (void)toggleAntiAds:(UISwitch *)sw {
    [[StarTokManager sharedManager] setBool:sw.on forKey:kStarTokAntiAds];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        [[StarTokManager sharedManager] registerShakeBumpWithCompletion:nil];
    }
}

@end

// Hook Profile View Controller to inject StarTok Settings button in Navigation Bar
%hook AWEUserProfileViewController

- (void)viewDidLoad {
    %orig;
    
    UIButton *starBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [starBtn setTitle:@"⭐" forState:UIControlStateNormal];
    starBtn.titleLabel.font = [UIFont systemFontOfSize:22];
    starBtn.frame = CGRectMake(0, 0, 36, 36);
    [starBtn addTarget:self action:@selector(openStarTokSettings) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *starItem = [[UIBarButtonItem alloc] initWithCustomView:starBtn];
    self.navigationItem.rightBarButtonItem = starItem;
}

%new
- (void)openStarTokSettings {
    [[StarTokManager sharedManager] triggerHapticFeedback:UIImpactFeedbackStyleLight];
    StarSettingsViewController *settingsVC = [[StarSettingsViewController alloc] initWithStyle:UITableViewStyleInsetGrouped];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [self presentViewController:nav animated:YES completion:nil];
}

%end
