//
//  KarteTrackerConfig.h
//  Pods
//

#ifndef KarteTrackerConfig_h
#define KarteTrackerConfig_h

#import <Foundation/Foundation.h>

@interface KarteTrackerConfig : NSObject

- (instancetype)initWithConfig:(NSDictionary *)config;

- (BOOL)enabledTrackingAppLifecycle;
- (NSString *)getViewEventName;
- (NSString *)getEndpoint;
- (BOOL)enabledTrackingCrashError;

@end

#endif /* KarteTrackerConfig_h */
