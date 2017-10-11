//
//  Tracker.h
//  Pods
//

#ifndef Tracker_h
#define Tracker_h

#import <Foundation/Foundation.h>
#import "KarteTrackerConfig.h"
#import "KarteTrackerUserProfile.h"
#import "KarteTrackerAppProfile.h"

@interface KarteTracker : NSObject

#pragma mark - Tracking

+ (nullable instancetype)sharedTrackerWithAppKey:(nonnull NSString *)appKey;
+ (nullable instancetype)sharedTracker;
+ (nonnull instancetype)setupWithAppKey:(NSString *)appKey;
+ (nonnull instancetype)setupWithAppKey:(NSString *)appKey config:(nullable NSDictionary *)config;

- (nonnull instancetype)initWithAppKey:(nonnull NSString *)appKey;
- (nonnull instancetype)initWithAppKey:(nonnull NSString *)appKey config:(nullable NSDictionary *)config;

- (void)track:(nonnull NSString *)eventName values:(nullable NSDictionary *)values;
- (void)identify:(nonnull NSDictionary *)values;
- (void)view:(nonnull NSString *)view_name;
- (void)view:(nonnull NSString *)view_name values:(nullable NSDictionary *)values;
- (void)flush;

#pragma mark - Notification

- (void)registerFCMToken:(nonnull NSString *)token;

@end

#endif /* Tracker_h */
