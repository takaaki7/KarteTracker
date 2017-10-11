//
//  KarteTrackerViewController.h
//  KarteTracker
//

@import UIKit;

@interface KarteTrackerViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;

- (IBAction)sendView:(id)sender;
- (IBAction)sendBuy:(id)sender;
- (IBAction)sendIdentify:(id)sender;
- (IBAction)logToken:(id)sender;

@end
