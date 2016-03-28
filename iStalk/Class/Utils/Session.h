//
//  Session.h
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject

+ (id) currentUserId;
+ (BOOL) sessionIsOpen;
+ (Identity *) identity;

+ (void) signOut;
+ (void) clearSessionObjects;
+ (void) endUserSession;

+ (void) checkForLogin;
+ (void) beginStartSessionWithToken: (NSString *) token uid: (NSNumber *) uid;
+ (void) beginStartSessionWithIdentity:(Identity *) identity;
+ (void) endStartSession;
+ (void) dispatchDeviceToken: (NSData *) deviceToken;
+ (void) registerForRemoteNotifications;
+ (id) sessionToken;
+ (NSString * const) sessionTokenKey;
+ (void) prepareSecuredRequestParameters: (__strong NSDictionary **) params;

@end
