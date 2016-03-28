//
//  RegisterViewController.h
//  iStalk
//
//  Created by Semih EKIZ on 08/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField3;
@property (weak, nonatomic) IBOutlet UIImageView *icon1;
@property (weak, nonatomic) IBOutlet UIImageView *icon2;
@property (weak, nonatomic) IBOutlet UIImageView *icon3;
@property (weak, nonatomic) IBOutlet UIScrollView *tempView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator1;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator2;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (nonatomic, strong) Identity *identity;
- (IBAction)sendFunction:(id)sender;
- (IBAction)takePhotoFunction:(id)sender;
- (IBAction)backFunction:(id)sender;
@end
