#import <notify.h>
#include <libactivator/libactivator.h>
#include "common.h"



@interface SBDeviceLockView

@property(retain, nonatomic) NSString *passcode;

@end



//from https://github.com/rpetrich/libactivator/blob/master/libactivator-private.h#L168
__attribute__((always_inline))
static inline LAEvent *LASendEventWithName(NSString *eventName) {
	LAEvent *event = [[[LAEvent alloc] initWithName:eventName mode:[LASharedActivator currentEventMode]] autorelease];
	[LASharedActivator sendEventToListener:event];
	return event;
}
//to https://github.com/rpetrich/libactivator/blob/master/libactivator-private.h#L174



typedef NS_ENUM(NSInteger, ProtectiPlusAction)
{
	ProtectiPlusActionDoNothing = 0,
	ProtectiPlusActionEnable = 1,
	ProtectiPlusActionDisable = 2
};

static NSString *correctPasscode = nil;
static NSString *fakePasscode = nil;
static ProtectiPlusAction protectiPlusAction = ProtectiPlusActionDoNothing;



%hook SBLockScreenManager

- (BOOL)attemptUnlockWithPasscode:(id)arg1 {
	BOOL result = NO;
	BOOL fakePasscodeWasEntered = NO;
	fakePasscodeWasEntered = [arg1 isEqualToString:fakePasscode];

	if (fakePasscodeWasEntered && correctPasscode != nil) {
		result = %orig(correctPasscode);
	} else {
		result = %orig(arg1);
	}

    if (result) {
    	if (fakePasscodeWasEntered) {
			LASendEventWithName(@"com.gviridis.fakepasscode");
            switch (protectiPlusAction) {
                case ProtectiPlusActionDoNothing:
                    break;
                case ProtectiPlusActionEnable:
                    notify_post("com.gviridis.protectiplus/Enable");
                    break;
                case ProtectiPlusActionDisable:
                    notify_post("com.gviridis.protectiplus/Disable");
                    break;
                default:
                    break;
            }
		} else {
			if (arg1 != nil && [arg1 isKindOfClass: [NSString class]]) {
	        	correctPasscode = [[NSString stringWithString:arg1] retain];
			}
		}
    } else {
    	if ((fakePasscodeWasEntered && correctPasscode != nil)
    		||
    		(!fakePasscodeWasEntered && correctPasscode != nil && [correctPasscode isEqualToString:arg1])
    		) {
			correctPasscode = nil;
		} else {

		}
    }
    return result;
}

%end



@interface FPDataSource: NSObject <LAEventDataSource> {
}

+ (id)sharedInstance;

@end

@implementation FPDataSource

+ (id)sharedInstance {
	static FPDataSource *shared = nil;
	if (!shared) {
		shared = [[FPDataSource alloc] init];
	}
	return shared;
}

- (id)init {
        if ((self = [super init])) {
                [LASharedActivator registerEventDataSource:self forEventName:@"com.gviridis.fakepasscode"];
        }
        return self;
}

- (void)dealloc {
        if (LASharedActivator.runningInsideSpringBoard) {
                [LASharedActivator unregisterEventDataSourceWithEventName:@"com.gviridis.fakepasscode"];
        }
        [super dealloc];
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
        return @"Fake Passcode";
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
        return @"Fake Passcode";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
        return @"Fake passcode was entered";
}

- (BOOL)eventWithNameIsHidden:(NSString *)eventName {
        return NO;
}

- (BOOL)eventWithNameRequiresAssignment:(NSString *)eventName {
        return NO;
}

- (BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode {
        return YES;
}

- (BOOL)eventWithNameSupportsUnlockingDeviceToSend:(NSString *)eventName {
        return NO;
}

@end



void updatePreferences(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo) {
    if (fakePasscode) {
        [fakePasscode release];
        fakePasscode = nil;
    } else {

    }
    NSDictionary *prefDict = [NSDictionary dictionaryWithContentsOfFile:@kPreferencesPath];
    fakePasscode = [[prefDict objectForKey:@"fakePasscode"] retain];
    protectiPlusAction = [[prefDict objectForKey:@"protectiPlusAction"] integerValue];
}



%ctor {
	%init;
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),NULL,&updatePreferences,CFSTR("com.gviridis.fakepasscode/UpdatePreferences"),NULL,0);
    notify_post("com.gviridis.fakepasscode/UpdatePreferences");
	[FPDataSource sharedInstance];
}
