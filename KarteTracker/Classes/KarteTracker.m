//
//  Tracker.m
//  Pods
//

#import <Foundation/Foundation.h>
#import "KarteTracker.h"
#import "KarteTrackerUtil.h"

@interface KarteTracker ()

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, strong) KarteTrackerConfig *config;
@property (nonatomic, strong) KarteTrackerUserProfile *userProfile;
@property (nonatomic, strong) KarteTrackerAppProfile *appProfile;
@property (nonatomic, strong) NSMutableArray *bufferedEvents;
@property (nonatomic, strong) dispatch_queue_t flushingTaskQueue;

@end

@implementation KarteTracker

static NSMutableDictionary *appKeyToInstance;
static NSString *defaultAppKey;

static KarteTracker *_sharedTracker = nil;
static int kMaxEventBufferSize = 10;

+ (instancetype)setupWithAppKey:(NSString *)appKey
{
  return [self setupWithAppKey:appKey config:@{}];
}

+ (instancetype)setupWithAppKey:(NSString *)appKey config:(NSDictionary *)config
{
  if (appKeyToInstance[appKey]) {
    return appKeyToInstance[appKey];
  }
  
  return [[self alloc] initWithAppKey:appKey config:config];
}

+ (instancetype)sharedTrackerWithAppKey:(NSString *)appKey
{
  return appKeyToInstance[appKey];
}

+ (instancetype)sharedTracker
{
  return appKeyToInstance[defaultAppKey];
}

- (instancetype)initWithAppKey:(NSString *)appKey
{
  return [self initWithAppKey:appKey config:nil];
}

- (instancetype)initWithAppKey:(NSString *)appKey config:(NSDictionary *)config
{
  if (self = [self init]) {
    self.appKey = appKey;
    self.config = [[KarteTrackerConfig alloc] initWithConfig:config];
    self.userProfile = [[KarteTrackerUserProfile alloc] init];
    self.appProfile = [[KarteTrackerAppProfile alloc] init];
    if ([self.config enabledTrackingAppLifecycle]) {
      [self trackAppLifecycle];
    }
  }
  return self;
}

- (instancetype)init:(NSString *)appKey {
  
  if (appKey == nil) {
    self.appKey = @"";
  }

  if (self = [super init]) {
    self.appKey = appKey;
    self.bufferedEvents = [NSMutableArray array];
    NSString *label = [NSString stringWithFormat:@"io.karte.tracker.%@", appKey];
    self.flushingTaskQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      appKeyToInstance = [NSMutableDictionary dictionary];
      defaultAppKey = appKey;
    });
  }
  return self;
}

- (void)track:(NSString *)eventName values:(NSDictionary *)values
{
  if (values == nil) {
    values = @{};
  }
  NSMutableDictionary *clonedValues = [values mutableCopy];
  clonedValues[@"_event_local_date"] = @([[NSDate date] timeIntervalSince1970]);

  NSDictionary *event = @{ @"event_name": eventName,
                           @"values": clonedValues };
  [self.bufferedEvents addObject:event];
  
  [self flush];
}

- (void)identify:(NSDictionary *)values
{
  [self track:@"identify" values:values];
}

- (void)view:(NSString *)view_name
{
  [self view:view_name values:nil];
}

- (void)view:(NSString *)view_name values:(nullable NSDictionary *)values
{
  if (values == nil) {
    values = @{};
  }
  NSMutableDictionary *copy = [values mutableCopy];
  [copy setObject:view_name forKey:@"view_name"];
  NSString* viewEventName = [self.config getViewEventName];
  [self track:viewEventName values:copy];
}

- (void)flush
{
  dispatch_async(_flushingTaskQueue, ^{
    [self flushBufferedEvents];
  });
}

- (void)flushBufferedEvents
{
  NSArray *events;
  @synchronized (self) {
    NSInteger count = [_bufferedEvents count];
    if( count == 0 ){
      KarteTrackerLog(@"No events to send");
      return;
    }
    
    // limit buffer size
    if(count > kMaxEventBufferSize){
      NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_bufferedEvents count] - kMaxEventBufferSize)];
      [_bufferedEvents removeObjectsAtIndexes:indexSet];
    }
    events = [_bufferedEvents copy];
  }
  
  NSString *endpoint = [self.config getEndpoint];
  
  BOOL success = [self sendRequest:endpoint events:events];
  if(success){
//    @synchronized (self) {
//      NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [events count])];
//      [_bufferedEvents removeObjectsAtIndexes:indexSet];
//    }
  }
}

- (void)trackAppLifecycle
{
  if(self.appProfile.versionName == nil){
    return;
  }
  
  NSMutableDictionary *values = [@{ @"version_name": self.appProfile.versionName,
                                    @"system_info": @{ @"os": [[UIDevice currentDevice] systemName],
                                                       @"os_version": [[UIDevice currentDevice] systemVersion],
                                                       @"device": [[UIDevice currentDevice] model],
                                                       @"model": GetDeviceName() }}
                                 mutableCopy];
  
  if(self.appProfile.prevVersionName == nil){
    // installed
    [self track:@"native_app_install" values:values];
  }else if(![self.appProfile.prevVersionName isEqualToString:self.appProfile.versionName]){
    // updated
    values[@"prev_version_name"] = self.appProfile.prevVersionName;
    [self track:@"native_app_update" values:values];
  }
}

- (void)registerFCMToken:(NSString *)token
{
  if( token == nil ){
    KarteTrackerLog(@"token must not be nil");
    return;
  }

  [self track:@"plugin_native_app_identify"
        values:@{ @"fcm_token": token,
                  @"subscribe": @YES }];
}

- (void)trackNotification:(NSDictionary *)userInfo
{
  if( !userInfo[@"krt_push_notification"] ){ return; }

  NSString *campaignId = userInfo[@"krt_campaign_id"];
  NSString *shortenId = userInfo[@"krt_shorten_id"];
  if( campaignId != nil && shortenId != nil ){
    [self track:@"message_click" values:@{ @"message": @{ @"campaign_id": campaignId,
                                                          @"shorten_id": shortenId } }];
  }
}

- (BOOL)sendRequest:(NSString *)endpoint events:(NSArray *)events
{
  NSURLSession *session = [NSURLSession sharedSession];

  __block BOOL success = NO;
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  
  NSURL* url = [NSURL URLWithString:endpoint];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                     timeoutInterval:10.0];
  [request setHTTPMethod:@"POST"];
  [request setValue:@"content-type" forHTTPHeaderField:@"text/plain; charset=utf-8"];
  [request setValue:@"X-KARTE-App-Key" forHTTPHeaderField:self.appKey];
  
  NSData *postData = [self createEventJson:events];
  
  [request setHTTPBody:postData];
  
  [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){

    if (error != nil) {
      KarteTrackerLog(@"failed to send request %@ : %@", url, error);
    }else if([(NSHTTPURLResponse *)response statusCode] != 200) {
      KarteTrackerLog(@"server responded %d", [(NSHTTPURLResponse *)response statusCode]);
    }else{
      success = YES;
    }

    dispatch_semaphore_signal(semaphore);

  }] resume];
  
  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
  
  return success;
}

- (NSData *)createEventJson:(NSArray *)events
{
  NSDictionary *data = @{ @"events": events,
                          @"keys": @{
                              @"visitor_id": [self.userProfile getVisitorId]
                              }
                          };
  
  if ([NSJSONSerialization isValidJSONObject:data]) {
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error];
    if (json != nil && error == nil) {
      return json;
    } else {
      KarteTrackerLog(@"Failed to construct json string");
    }
  } else {
    KarteTrackerLog(@"Invalid json format");
  }
  
  return nil;
}

@end
