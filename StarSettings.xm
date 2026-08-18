#import "StarTok.h"

// Apple-Grade Settings Controller with System SF Icons, Inset Grouped layout, and Native Sections
@interface StarSettingsViewController : UITableViewController
@end

@implementation StarSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"StarTok";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    // Apple-style Done Button
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSettings)];
    doneItem.tintColor = [UIColor systemBlueColor];
    self.navigationItem.rightBarButtonItem = doneItem;
}

- (void)dismissSettings {
    [[StarTokManager sharedManager] saveSettings];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"РЕГИОН И ЛОКАЛИЗАЦИЯ";
        case 1: return @"ЭКОСИСТЕМА И STARBUMP";
        case 2: return @"СООБЩЕНИЯ И ПРИВАТНОСТЬ";
        case 3: return @"МЕДИА И ВОСПРОИЗВЕДЕНИЕ";
        case 4: return @"ОФОРМЛЕНИЕ И ИНТЕРФЕЙС";
        case 5: return @"STARGUARD & СЕРВЕР";
        default: return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"Режим «Загадочный иностранец» позволяет просматривать локальные тренды других стран в режиме гостя без изменения алгоритма личного профиля.";
    } else if (section == 1) {
        return @"Потрясите iPhone рядом с другим пользователем StarTok для регистрации мгновенного контакта.";
    } else if (section == 5) {
        return @"StarTok v2.1.0 • Спроектировано в стиле iOS Human Interface Guidelines";
    }
    return nil;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 2; // Region + Nomad Mode
        case 1: return 2; // Badge Status + StarBump Test
        case 2: return 3; // Streak Saver + Ghost Typing + Ghost View
        case 3: return 4; // No Watermark + StarSpeed + Anti Live + PiP
        case 4: return 2; // OLED True Black + SF Symbols & Fonts
        case 5: return 2; // StarGuard Status + Backend Server
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppleStarCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AppleStarCell"];
    }
    
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    StarTokManager *mgr = [StarTokManager sharedManager];

    // Section 0: Region & Nomad
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Основной регион";
            cell.detailTextLabel.text = mgr.currentRegion;
            cell.imageView.image = [UIImage systemImageNamed:@"globe.americas.fill"];
            cell.imageView.tintColor = [UIColor systemBlueColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Загадочный иностранец";
            cell.imageView.image = [UIImage systemImageNamed:@"airplane.departure"];
            cell.imageView.tintColor = [UIColor systemIndigoColor];
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = mgr.isNomadActive;
            [sw addTarget:self action:@selector(toggleNomad:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    // Section 1: Ecosystem & StarBump
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Мой статус в сети";
            cell.detailTextLabel.text = @"⭐ Проверить";
            cell.imageView.image = [UIImage systemImageNamed:@"star.circle.fill"];
            cell.imageView.tintColor = [UIColor systemYellowColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"StarBump (Тест тряски)";
            cell.detailTextLabel.text = @"⚡ Потрясти";
            cell.imageView.image = [UIImage systemImageNamed:@"bolt.horizontal.fill"];
            cell.imageView.tintColor = [UIColor systemOrangeColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    // Section 2: Messages & Privacy
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Streak Saver (Огоньки)";
            cell.imageView.image = [UIImage systemImageNamed:@"flame.fill"];
            cell.imageView.tintColor = [UIColor systemRedColor];
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokStreakSaver defaultVal:YES];
            [sw addTarget:self action:@selector(toggleStreakSaver:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Скрытый набор (Ghost Typing)";
            cell.imageView.image = [UIImage systemImageNamed:@"character.cursor.ibeam"];
            cell.imageView.tintColor = [UIColor systemCyanColor];
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokGhostTyping defaultVal:NO];
            [sw addTarget:self action:@selector(toggleGhostTyping:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Анонимный просмотр историй";
            cell.imageView.image = [UIImage systemImageNamed:@"eye.slash.fill"];
            cell.imageView.tintColor = [UIColor systemPurpleColor];
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokGhostMode defaultVal:NO];
            [sw addTarget:self action:@selector(toggleGhostView:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    // Section 3: Media & Playback
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Скачивание без вотермарок";
            cell.imageView.image = [UIImage systemImageNamed:@"arrow.down.circle.fill"];
            cell.imageView.tintColor = [UIColor systemGreenColor];
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = YES;
            sw.enabled = NO;
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"StarSpeed перемотка удержанием";
            cell.detailTextLabel.text = @"2.5x";
            cell.imageView.image = [UIImage systemImageNamed:@"forward.fill"];
            cell.imageView.tintColor = [UIColor systemBlueColor];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Скрывать стримы в ленте";
            cell.imageView.image = [UIImage systemImageNamed:@"antenna.radiowaves.left.and.right.slash"];
            cell.imageView.tintColor = [UIColor systemPinkColor];
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokAntiLive defaultVal:NO];
            [sw addTarget:self action:@selector(toggleAntiLive:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Блокировка рекламы и покупок";
            cell.imageView.image = [UIImage systemImageNamed:@"shield.lefthalf.filled"];
            cell.imageView.tintColor = [UIColor systemTealColor];
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokAntiAds defaultVal:YES];
            [sw addTarget:self action:@selector(toggleAntiAds:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    // Section 4: Appearance & UI
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"OLED True Black (100% черный)";
            cell.imageView.image = [UIImage systemImageNamed:@"moon.fill"];
            cell.imageView.tintColor = [UIColor labelColor];
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokPureBlack defaultVal:NO];
            [sw addTarget:self action:@selector(togglePureBlack:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Тактильный отклик (Haptics)";
            cell.imageView.image = [UIImage systemImageNamed:@"waveform"];
            cell.imageView.tintColor = [UIColor systemMintColor];
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = [mgr boolForKey:kStarTokHaptics defaultVal:YES];
            [sw addTarget:self action:@selector(toggleHaptics:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    // Section 5: StarGuard & Server
    else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"StarGuard Защита";
            cell.detailTextLabel.text = @"Активна 🛡️";
            cell.imageView.image = [UIImage systemImageNamed:@"lock.shield.fill"];
            cell.imageView.tintColor = [UIColor systemGreenColor];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Сервер StarTok";
            cell.detailTextLabel.text = mgr.backendUrl;
            cell.imageView.image = [UIImage systemImageNamed:@"server.rack"];
            cell.imageView.tintColor = [UIColor systemGrayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void)toggleGhostView:(UISwitch *)sw {
    [[StarTokManager sharedManager] setBool:sw.on forKey:kStarTokGhostMode];
}

- (void)toggleAntiLive:(UISwitch *)sw {
    [[StarTokManager sharedManager] setBool:sw.on forKey:kStarTokAntiLive];
}

- (void)toggleAntiAds:(UISwitch *)sw {
    [[StarTokManager sharedManager] setBool:sw.on forKey:kStarTokAntiAds];
}

- (void)togglePureBlack:(UISwitch *)sw {
    [[StarTokManager sharedManager] setBool:sw.on forKey:kStarTokPureBlack];
}

- (void)toggleHaptics:(UISwitch *)sw {
    [[StarTokManager sharedManager] setBool:sw.on forKey:kStarTokHaptics];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    StarTokManager *mgr = [StarTokManager sharedManager];
    
    // Change Region
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIAlertController *regionSheet = [UIAlertController alertControllerWithTitle:@"Выберите регион"
                                                                             message:@"Контент и тренды будут адаптированы под выбранную страну"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        NSArray *regions = @[@"US (США 🇺🇸)", @"BY (Беларусь 🇧🇾)", @"KZ (Казахстан 🇰🇿)", @"DE (Германия 🇩🇪)", @"JP (Япония 🇯🇵)", @"GB (Великобритания 🇬🇧)"];
        NSArray *codes = @[@"US", @"BY", @"KZ", @"DE", @"JP", @"GB"];
        
        for (NSInteger i = 0; i < regions.count; i++) {
            NSString *code = codes[i];
            [regionSheet addAction:[UIAlertAction actionWithTitle:regions[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                mgr.currentRegion = code;
                [mgr setString:code forKey:kStarTokRegion];
                [tableView reloadData];
            }]];
        }
        [regionSheet addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:regionSheet animated:YES completion:nil];
    }
    // Check Status
    else if (indexPath.section == 1 && indexPath.row == 0) {
        [mgr checkUserBadge:@"my_user_id" completion:^(StarTokRole role, BOOL isBumped) {
            NSString *roleTitle = @"⭐ Пользователь StarTok";
            if (role == StarTokRoleCreator) roleTitle = @"👑 Создатель StarTok";
            if (role == StarTokRoleTester) roleTitle = @"🧪 Тестер StarTok";
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:roleTitle
                                                                           message:[NSString stringWithFormat:@"Подключение к %@ успешно установлено!", mgr.backendUrl]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Отлично" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }];
    }
    // Trigger Bump Test
    else if (indexPath.section == 1 && indexPath.row == 1) {
        [mgr registerShakeBumpWithCompletion:nil];
    }
    // Edit Backend URL
    else if (indexPath.section == 5 && indexPath.row == 1) {
        UIAlertController *prompt = [UIAlertController alertControllerWithTitle:@"Сервер StarTok"
                                                                        message:@"Укажите URL вашего бэкенда или Cloudflare туннеля"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        [prompt addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"https://api.krnlcamel.space";
            textField.text = mgr.backendUrl;
            textField.keyboardType = UIKeyboardTypeURL;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        }];
        [prompt addAction:[UIAlertAction actionWithTitle:@"Сохранить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *newUrl = prompt.textFields.firstObject.text;
            if (newUrl.length > 0) {
                mgr.backendUrl = newUrl;
                [mgr setString:newUrl forKey:kStarTokCustomBackend];
                [tableView reloadData];
            }
        }]];
        [prompt addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:prompt animated:YES completion:nil];
    }
}

@end

// Hook Profile View Controller to inject Native Apple Navigation Bar Button
%hook AWEUserProfileViewController

- (void)viewDidLoad {
    %orig;
    @try {
        UIImage *starImg = [UIImage systemImageNamed:@"star.circle.fill"];
        UIBarButtonItem *starItem = [[UIBarButtonItem alloc] initWithImage:starImg style:UIBarButtonItemStylePlain target:self action:@selector(openStarTokSettings)];
        starItem.tintColor = [UIColor systemYellowColor];
        self.navigationItem.rightBarButtonItem = starItem;
    } @catch (NSException *e) {}
}

%new
- (void)openStarTokSettings {
    [[StarTokManager sharedManager] triggerHapticFeedback:UIImpactFeedbackStyleLight];
    StarSettingsViewController *settingsVC = [[StarSettingsViewController alloc] initWithStyle:UITableViewStyleInsetGrouped];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

%end
