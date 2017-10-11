//
//  KarteTrackerUserProfile.m
//  Pods
//

#import <Foundation/Foundation.h>
#import "KarteTrackerUtil.h"
#import "KarteTrackerUserProfile.h"

@interface KarteTrackerUserProfile ()

@property (nonatomic, copy, readwrite) NSString *visitorId;

@end

@implementation KarteTrackerUserProfile

- (NSString *) getVisitorId
{
  if (!self.visitorId) {
    [self loadAndSave];
  }
  return self.visitorId;
}

- (NSString *) profileFilePath
{
  return GetTrackerSerializeFilePath(@"karte.user.plist");
}

- (void) loadAndSave
{
  [self load];
  if (!self.visitorId) {
    self.visitorId = [KarteTrackerUserProfile generateVisitorId];
    [self save];
  }
}

- (void)save
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  [dict setValue:self.visitorId forKey:@"visitorId"];
  if(![NSKeyedArchiver archiveRootObject:dict toFile:[self profileFilePath]]) {
    KarteTrackerLog(@"failed to save profile to file");
  }
}

- (void)load
{
  NSDictionary *dict;
  @try {
    dict = [NSKeyedUnarchiver unarchiveObjectWithFile:[self profileFilePath]];
  }
  @catch (NSException *exception) {
    KarteTrackerLog(@"failed to load profile from file");
    return;
  }
  if(dict[@"visitorId"]){
    self.visitorId = dict[@"visitorId"];
  }
}

- (id)init
{
  if (self = [super init]) {
    [self load];
    if (!self.visitorId) {
      self.visitorId = [KarteTrackerUserProfile generateVisitorId];
      [self save];
    }
  }
  return self;
}


+ (NSString *)generateVisitorId
{
  NSUUID *uuid = [NSUUID UUID];
  return [uuid UUIDString];
}

@end
