//
//  KarteTrackerViewController.m
//  KarteTracker
//


#import <Foundation/Foundation.h>
#import <KarteTracker/KarteTracker.h>

#import "KarteTrackerViewController.h"

@import Firebase;

@interface KarteTrackerViewController ()

@end

@implementation KarteTrackerViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.userIdTextField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return NO;
}

- (IBAction)sendView:(id)sender {
  NSLog(@"'Send View' has been clicked");
  [[KarteTracker sharedTracker] view:@"main_view" values:@{@"from":@"Send View Button"}];
}

- (IBAction)sendBuy:(id)sender {
  NSLog(@"'Send Buy' has been clicked");
  NSDictionary *values = @{ @"affiliation":@"shop name",
                            @"revenue":[NSNumber numberWithUnsignedInt:arc4random_uniform(10000)],
                            @"shipping":@100,
                            @"tax":@10,
                            @"items":@[@{ @"item_id":@"test",
                                          @"name":@"掃除機A",
                                          @"category":@[@"家電", @"掃除機"],
                                          @"price":[NSNumber numberWithUnsignedInteger:arc4random_uniform(1000)],
                                          @"quantity":@1 }] };
  [[KarteTracker sharedTracker] track:@"buy" values:values];
}

- (IBAction)sendIdentify:(id)sender {
  NSLog(@"'Identify has been clicked");
  NSString *userId = self.userIdTextField.text;
  if ([userId length] > 0) {
    [[KarteTracker sharedTracker] identify:@{ @"user_id":userId }];
  }
}

- (IBAction)logToken:(id)sender {
  NSString *refreshedToken = [[FIRInstanceID instanceID] token];
  NSLog(@"fcm token: %@", refreshedToken);
}

@end
