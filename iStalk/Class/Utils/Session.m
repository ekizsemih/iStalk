//
//  Session.h
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "Session.h"
#import "Utils.h"

NSString * const kSessionIdentityKey = @"kSessionIdentityKey";
NSString * const kSessionUserIdKey = @"kSessionUserIdKey";
NSString * const kSessionTokenKey = @"kSessionTokenKey";
NSString * const kSessionRemoteTokenKey= @"token";

static Identity * __identity;

@implementation Session

+ (BOOL)sessionIsOpen {
    id token = [self sessionToken];
    if ([Utils stringIsEmpty: token]) {
        return NO;
    }
    return YES;
}

+ (void)signOut{
    
    [Utils setRootViewController:@"mainlogincontroller"];
    
    id deviceTokenRetained = [Utils objForPrefKey:@"UserDeviceToken"];

        [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
        [[NSUserDefaults standardUserDefaults] synchronize];

    [Utils deleteAllUserFiles];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSessionIdentityKey];
    
    [Session identity].reset_me = YES;
    __identity = nil;
    
    if (deviceTokenRetained) {
        [Utils setObject: deviceTokenRetained forPrefKey:@"UserDeviceToken"];
        [Utils synchronize];
    }
}

+ (id)currentUserId {
    return [Utils objForPrefKey: kSessionUserIdKey];
}

+ (void)prepareSecuredRequestParameters:(__strong NSDictionary **)params {
    if (![self sessionIsOpen]) {
        return;
    }
    
    NSDictionary *dic = (NSDictionary *)*params;
    if ([dic objectForKey:[self sessionTokenKey]] == nil) {
        NSMutableDictionary *newParams;
        if (*params != nil) {
            newParams = [NSMutableDictionary dictionaryWithDictionary:*params];
        } else {
            newParams = [NSMutableDictionary new];
        }
        
        [newParams setObject:[self sessionToken] forKey: kSessionRemoteTokenKey];
        
        *params = newParams;
    }
}

+ (id)sessionToken {
    return [[Session identity] authtoken];
}

+ (NSString * const)sessionTokenKey {
    return kSessionTokenKey;
}

+ (void) checkForLogin{
    if (![Session sessionIsOpen]) {
        [Session signOut];
        return;
    }
    
    [self endStartSession];
}

+ (void) beginStartSessionWithToken: (NSString *) token uid: (NSNumber *) uid {
    [Utils setObject: [Utils trimString:token] forPrefKey:kSessionTokenKey];
    [Utils setObject: uid forPrefKey:kSessionUserIdKey];
    [Utils synchronize];
}

+ (Identity *) identity {
    if (!__identity) {
        NSData *archivedObject = [Utils objForPrefKey: kSessionIdentityKey];
        __identity = [NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
    } else if (__identity.reset_me) {
        __identity.reset_me = NO;
        
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject: __identity];
        [Utils setObject: encodedObject forPrefKey:kSessionIdentityKey];
        [Utils synchronize];
        
        NSData *archivedObject = [Utils objForPrefKey: kSessionIdentityKey];
        __identity = [NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
    }
    return __identity;
}

+ (void)beginStartSessionWithIdentity:(Identity *) identity {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject: identity];
    
    [Utils setObject: [Utils trimString: identity.authtoken] forPrefKey:kSessionTokenKey];
    [Utils setObject: identity.userid forPrefKey:kSessionUserIdKey];
    [Utils setObject: encodedObject forPrefKey:kSessionIdentityKey];
    [Utils synchronize];
}

+ (void) endStartSession {
    [Utils setRootViewController:@"maincontroller"];
}

+ (void) prepareSession {
    [Utils setRootViewController:@"maincontroller"];
}

+ (void)registerForRemoteNotifications {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

+ (void)dispatchDeviceToken:(NSData *)deviceToken {
    NSString *dtoken = [[deviceToken description] stringByTrimmingCharactersInSet:
                        [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dtoken = [dtoken stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([Session sessionIsOpen]) {
        id deviceToken = [Utils objForPrefKey:@"UserDeviceToken"];
        if (![Utils stringIsEmpty:deviceToken]) {
            
            id params = @{
                          @"userid":[Session identity].userid,
                          @"devicetoken":deviceToken,
                          @"servicetoken":servicetoken,
                          @"apptoken":[Session identity].userToken
                          };
            [Utils callPostApi:updatedevicetoken params:params integer:0 withType:1 progress:nil success:^(id responseObject) {
                id data = [Utils jsonWithData:responseObject error:nil];
                if ([[data objectForKey:@"returnCode"] boolValue]) {
                    [Utils setObject:dtoken forPrefKey:@"UserDeviceToken"];
                    [Utils synchronize];
                }
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
    } else {
        [Utils setObject:dtoken forPrefKey:@"UserDeviceToken"];
        [Utils synchronize];
    }
}

+ (void)clearSessionObjects {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}

+ (void)endUserSession {
    [Utils setObject:nil forPrefKey:kSessionTokenKey];
    [Utils synchronize];
}

@end

