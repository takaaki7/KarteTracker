//
//  KarteTrackerAppDelegate.m
//  KarteTracker
//

#import "KarteTrackerAppDelegate.h"
#import <KarteTracker/KarteTracker.h>
#import <KarteTracker/KarteTrackerUtil.h>

@import Firebase;

// api_key of KARTE
static NSString *const kAppKey = @"62047b8feddfdf076202b56ee77f7d43";

@implementation KarteTrackerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.

  // setup Tracker
  NSLog(@"Setup tracker");
  KarteTrackerShowLog(YES); // for debugging
  [KarteTracker setupWithAppKey:kAppKey
                         config:@{ @"endpoint": @"http://localhost:8010/v0/track" }];

  // setup Firebase
  [FIRApp configure];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:) name:kFIRInstanceIDTokenRefreshNotification object:nil];

  // register notification
  [application registerForRemoteNotifications];
  UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
  UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
  [application registerUserNotificationSettings:settings];

  return YES;
}

// called when FCM token is refreshed
- (void)tokenRefreshNotification:(NSNotification *)notification {
  NSString *refreshedToken = [[FIRInstanceID instanceID] token];
  if ( refreshedToken == nil ) {
    NSLog(@"instance id token is nil");
    return;
  }
  NSLog(@"instance id token: %@", refreshedToken);
  
  // send FCM token to KARTE
  [[KarteTracker sharedTracker] registerFCMToken:refreshedToken];

  [self connectToFCM];
}

- (void)connectToFCM {
  [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error){
    if (error != nil){
      NSLog(@"Unable to connect to FCM. %@", error);
    } else {
      NSLog(@"Connected to FCM.");
    }
  }];
}

// - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
// {
//   NSString *token = deviceToken.description;
//   NSLog(@"device token: %@", token);
// }

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error
{
  NSLog(@"device token error: %@", [error description]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
{
  NSLog(@"push info: %@", [userInfo description]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
  NSLog(@"push info background: %@", [userInfo description]);

  if( application.applicationState != UIApplicationStateActive ){
    // track notification tapped
    // Capabilities > Background Modes > Remote notifications がoffになっている必要あり
    // onになっている場合、以下のクリックトラッキングが配送直後に実行されてしまう場合がある
    [[KarteTracker sharedTracker] trackNotification:userInfo];
  }

  completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  [[FIRMessaging messaging] disconnect];
  NSLog(@"disconnected from FCM");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  [self connectToFCM];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
