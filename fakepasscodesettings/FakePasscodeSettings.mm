#import <notify.h>
#import <Preferences/Preferences.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListItemsController.h>
#include "../common.h"



BOOL protectiPlusIsInstalled() {
    return [[NSFileManager defaultManager]fileExistsAtPath:@kProtectiPlusDylibPath];
}



@interface FakePasscodeSettingsListControllerForProtectiPlusActions: PSListItemsController {
}
@end

@implementation FakePasscodeSettingsListControllerForProtectiPlusActions

@end



@interface FakePasscodeSettingsListController: PSListController {
}
@end

@implementation FakePasscodeSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
        if (protectiPlusIsInstalled()) {
            _specifiers = [[self loadSpecifiersFromPlistName:@"FakePasscodeSettings" target:self] mutableCopyWithZone:NULL];
            PSSpecifier* protectiPlusActionsSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Protecti+ Actions"
                                                                                       target:self
                                                                                          set:@selector(setValue:forSpecifier:)
                                                                                          get:@selector(getValueForSpecifier:)
                                                                                       detail:[PSListItemsController class]
                                                                                         cell:PSLinkListCell
                                                                                         edit:Nil];
            [protectiPlusActionsSpecifier setProperty:@"protectiPlusAction" forKey:@"key"];
            [protectiPlusActionsSpecifier setValues:@[@0, @1, @2] titles:@[@"Do Nothing", @"Enable Protecti+", @"Disable Protecti+"]];
            
            if (protectiPlusActionsSpecifier) {
                [(NSMutableArray *)_specifiers insertObject:protectiPlusActionsSpecifier atIndex:4];
            } else {
                
            }
        } else {
            _specifiers = [[self loadSpecifiersFromPlistName:@"FakePasscodeSettings" target:self] retain];
        }
		
	}
	return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier
{
    return [[NSDictionary dictionaryWithContentsOfFile:@kPreferencesPath][specifier.identifier] retain] ? : @0;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *prefDict = [ NSMutableDictionary dictionary];
    [prefDict addEntriesFromDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:@kPreferencesPath]];
    [prefDict setObject:value forKey:specifier.identifier];
    [prefDict writeToFile:@kPreferencesPath atomically:YES];
    notify_post("com.gviridis.fakepasscode/UpdatePreferences");
}

- (void)followMeOnTwitter {
	if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"tweetbot:///user_profile/gviridis"]];
	} else if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"twitter://user?screen_name=gviridis"]];
	} else {
		[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://twitter.com/intent/follow?screen_name=gviridis"]];
	}
}

- (void)followMeOnWeibo {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://weibo.com/gviridis"]];
}

@end





// vim:ft=objc
