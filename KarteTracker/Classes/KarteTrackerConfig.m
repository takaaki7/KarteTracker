//
//  KarteTrackerConfig.m
//  Pods
//

#import <Foundation/Foundation.h>

#import "KarteTrackerConfig.h"

@interface KarteTrackerConfig ()

@property (nonatomic, assign) BOOL enableTrackingAppLifecycle;
@property (nonatomic, copy) NSString* endpoint;
@property (nonatomic, copy) NSString* viewEventName;
@property (nonatomic, assign) BOOL enableTrackingCrashError;

@end

@implementation KarteTrackerConfig

- (instancetype)initWithConfig:(NSDictionary *)config
{
  if(self = [self init]){
    self.enableTrackingAppLifecycle = config[@"enableTrackingAppLifecycle"] != nil ? [config[@"enableTrackingAppLifecycle"] boolValue] : YES;
    self.endpoint = config[@"endpoint"] ? config[@"endpoint"] : @"https://api.karte.io/v0/track";
    self.viewEventName = config[@"viewEventName"] ? config[@"viewEventName"] : @"view";
    self.enableTrackingCrashError = config[@"enableTrackingCrashError"] != nil ? [config[@"enableTrackingCrashError"] boolValue] : YES;
  }
  return self;
}

- (BOOL)enabledTrackingAppLifecycle
{
  return self.enableTrackingAppLifecycle;
}

- (NSString *)getEndpoint
{
  return self.endpoint;
}

- (NSString *)getViewEventName
{
  return self.viewEventName;
}

- (BOOL)enabledTrackingCrashError
{
  return self.enableTrackingCrashError;
}

@end
