//
//  AppDelegate.m
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "AppDelegate.h"
#import "UpdateAlertView.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import <TwitterKit/TwitterKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SearchViewController.h"
#import "FSOAuth.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    Naz ekiz
    [Parse setApplicationId:@"KabAcqrSuoaFZZbPAbxZog2JFXlve3QXHeMxZljm"
                  clientKey:@"QHXbhgUjzEL0aZtaZMfVJO6rfT4Iz8UkOwPCeR7n"];
    
    [Flurry startSession:@"HDBRYMQCXXBZDX5SY3PS"];
    
    [Fabric with:@[CrashlyticsKit]];
    [Fabric with:@[[Crashlytics class], [Twitter class]]];
    
    [[Twitter sharedInstance] startWithConsumerKey:@"rXeRyDvs1NOonXvkJg0YMRcxV" consumerSecret:@"tQbiNooYred7qbO64S1LlrV2S4BLKgVTeqfEDNxNaO2tkVlk9C"];
    [Fabric with:@[[Twitter sharedInstance]]];
    
    self.instagram = [[Instagram alloc] initWithClientId:@"8585c1eca1a44ac696033a0991be915d" delegate:nil];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024 diskCapacity:100 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [Session registerForRemoteNotifications];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame: screenBounds];
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.window setRootViewController: [mainStoryboard instantiateInitialViewController]];
    [self.window makeKeyAndVisible];
    
    [Session checkForLogin];
    
    id remoteNtf = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNtf) {
        [self application: application didReceiveRemoteNotification: remoteNtf];
    }
    LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"LeftMenuViewController"];
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    
    RightMenuViewController *rightMenu = (RightMenuViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"RightMenuViewController"];
    [SlideNavigationController sharedInstance].rightMenu = rightMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)applicationWillResignActive:(UIApplication *)application{}

- (void)applicationDidEnterBackground:(UIApplication *)application{}

- (void)applicationWillEnterForeground:(UIApplication *)application{}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[url absoluteString] hasPrefix:@"fb"]) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    else if ([[url absoluteString] hasPrefix:@"istalk"]) {
        SearchViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"searchController"];
        [vc handleURL:url];
        return NO;
        
    }
    else if ([[url absoluteString] hasPrefix:@"ig"]) {
        return [self.instagram handleOpenURL:url];
    }
    else if ([[url absoluteString] hasPrefix:@"twtoken"]) {
        
        NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
        
        NSString *token = d[@"oauth_token"];
        NSString *verifier = d[@"oauth_verifier"];
        SearchViewController *vc = (SearchViewController *)[[[SlideNavigationController sharedInstance] viewControllers] lastObject];
        [vc setOAuthToken:token oauthVerifier:verifier];
        
        return YES;
    }
    return NO;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[url absoluteString] hasPrefix:@"ig"])
        return [self.instagram handleOpenURL:url];
    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    BOOL didHandle = NO;
    if ([userActivity.activityType isEqual:NSUserActivityTypeBrowsingWeb]) {
        SearchViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"searchController"];
        [vc handleURL:userActivity.webpageURL];
        didHandle = YES;
    }
    return didHandle;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    [Session dispatchDeviceToken: deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    UIApplicationState appState = [application applicationState];
    if ([userInfo objectForKey:@"dataType"]) {
        if ([[userInfo objectForKey:@"dataType"] boolValue]) {
            id data = [userInfo objectForKey:@"data"];
            if  (appState == UIApplicationStateActive) {
                UpdateAlertView *alert = [[UpdateAlertView alloc] initWithTitle:[data objectForKey:@"title"]
                                                                        message:[data objectForKey:@"text"]
                                                                       delegate:self
                                                              cancelButtonTitle:[Utils localizedString:@"ITDismiss"]
                                                              otherButtonTitles:[Utils localizedString:@"ITOk"], nil];
                alert.linktoOpen = [data objectForKey:@"url"];
                [alert setTag: 0xa];
                [alert show];
            }
            else
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [data objectForKey:@"url"]]];
        }
        else
            [PFPush handlePush:userInfo];
    }
    else
        [PFPush handlePush:userInfo];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 0xa) {
        UpdateAlertView *happyAlert = (UpdateAlertView *)alertView;
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: happyAlert.linktoOpen]];
    }
}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    return md;
}


#pragma mark - Core Data stack

NSManagedObjectContext* getDBCtx(){
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.managedObjectContext;
}

- (void)saveContext{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Users" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Users.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
