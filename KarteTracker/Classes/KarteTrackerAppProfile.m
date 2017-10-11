//
//  KarteTrackerAppProfile.m
//  Pods
//

#import <Foundation/Foundation.h>
#import "KarteTrackerAppProfile.h"
#import "KarteTrackerUtil.h"

@interface KarteTrackerAppProfile ()

@property (nonatomic, copy, readwrite) NSString *versionName;
@property (nonatomic, copy, readwrite) NSString *prevVersionName;

@end

@implementation KarteTrackerAppProfile

- (NSString *)appProfileFilePath
{
  return GetTrackerSerializeFilePath(@"karte.app.plist");
}

- (void)load
{
  NSDictionary *dict;
  @try {
    dict = [NSKeyedUnarchiver unarchiveObjectWithFile:[self appProfileFilePath]];
  }
  @catch (NSException *exception) {
    KarteTrackerLog(@"failed to load profile from file");
    return;
  }
  
  self.prevVersionName = dict[@"versionName"];
  self.versionName = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

- (void)save
{
  if(self.versionName == nil){
    KarteTrackerLog(@"invalid build code");
    return;
  }
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"versionName"] = self.versionName;
  
  if(![NSKeyedArchiver archiveRootObject:dict toFile:[self appProfileFilePath]]) {
    KarteTrackerLog(@"failed to save profile to file");
  }
}

- (id)init
{
  if (self = [super init]) {
    [self load];
    
    if(self.versionName != nil && ![self.versionName isEqualToString:self.prevVersionName]){
      [self save];
    }
  }
  return self;
}

@end
