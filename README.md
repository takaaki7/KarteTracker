# KarteTracker

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## 1. Installation

KarteTracker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "KarteTracker"
pod "Firebase/Messaging" #Optional
```

## 2. Implement set up code in AppDelegate
Import <KarteTracker/KarteTracker.h> into AppDelegate.m, and initialize KarteTracker within `application:didFinishLaunchingWithOptions:`

```objective-c
#import "AppDelegate.h"
#import <KarteTracker/KarteTracker.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [KarteTracker setupWithAppKey:KARTE_APP_KEY
                         config:@{}];
}
```

## 3. Add to event tracking code
#### View event to track opening a view
```objective-c
[[KarteTracker sharedTracker] view:@"main_view" values:@{@"from":@"Send View Button"}];
```

#### Identify event to track user infomation
```objective-c
[[KarteTracker sharedTracker] identify:@{@"user_id":userId }];
```

#### Custom event
```objective-c
[[KarteTracker sharedTracker] track:@"sample_event_name" values:@{ }];
```

## 4. (Option) Track the instance id of Firebase Cloud Messaging
Send FCMToken to Karte and track a notification within `tokenRefreshNotification` and `didReceiveRemoteNotification`
```objective-c
- (void)tokenRefreshNotification:(NSNotification *)notification {
  NSString *refreshedToken = [[FIRInstanceID instanceID] token];
  if ( refreshedToken == nil ) {
    return;
  }
    
  // send FCM token to KARTE
  [[KarteTracker sharedTracker] registerFCMToken:refreshedToken];

  [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error){  }];
 }
 
 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{

  if( application.applicationState != UIApplicationStateActive ){
    [[KarteTracker sharedTracker] trackNotification:userInfo];
  }

  completionHandler(UIBackgroundFetchResultNoData);
}

```
