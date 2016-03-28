//
//  LoginViewController.h
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController : UIViewController <UITextViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *fbbutton;
- (IBAction)loginFunction:(id)sender;
- (IBAction)facebookFunction:(id)sender;
- (IBAction)registerFunction:(id)sender;

@end

