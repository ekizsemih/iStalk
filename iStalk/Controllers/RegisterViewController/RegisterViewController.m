//
//  RegisterViewController.m
//  iStalk
//
//  Created by Semih EKIZ on 08/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "RegisterViewController.h"
#import "PECropViewController.h"

@interface RegisterViewController ()<PECropViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic) UIPopoverController *popover;
@end

@implementation RegisterViewController{
    CGPoint svos;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(privacyStates:) name:@"privacyVC" object:nil];
    [_textField1 addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventEditingChanged];
    [_textField2 addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventEditingChanged];
    [_textField3 addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventEditingChanged];
    
    _textField1.text = _identity.username;
    _textField2.text = _identity.email;
    _indicator1.hidden = YES;
    _indicator2.hidden = YES;
    
    if ([NSData dataWithContentsOfURL:[NSURL URLWithString:_identity.imagePath]]) {
        [_button setBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_identity.imagePath]]] forState:UIControlStateNormal];
        [_button setTitle:@"" forState:UIControlStateNormal];
    }
    
    [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_identity.imagePath]]] ? [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_identity.imagePath]]] : [UIImage imageNamed:@"addphoto"];
    [_button setBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_identity.imagePath]]] ? [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_identity.imagePath]]] : [UIImage imageNamed:@"addphoto"] forState:UIControlStateNormal];
    
    [self.textField1 setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.textField2 setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.textField3 setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    _tempView.contentSize = CGSizeMake(_tempView.frame.size.width, _tempView.frame.size.height);
    
    _button.layer.cornerRadius = _button.frame.size.width / 2;
    _button.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateEditButtonEnabled];
}

- (void)keyboardHide:(UITapGestureRecognizer *)gr {
    [self scrollFunction];
    [UIView animateWithDuration:0.5 animations:^{
        [_textField1 resignFirstResponder];
        [_textField2 resignFirstResponder];
        [_textField3 resignFirstResponder];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    
    NSInteger nextTag = textField.tag + 1;
    
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        
        [nextResponder becomeFirstResponder];
        
    } else {
        [textField resignFirstResponder];
        [_tempView setContentOffset:svos animated:YES];
        [self keyboardHide:nil];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([Utils screenHeight]>480) {
        return;
    }
    svos = _tempView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:_tempView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [_tempView setContentOffset:pt animated:YES];
}

- (void)scrollFunction{
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint size;
        size.x = 0;
        size.y = 0;
        [_tempView setContentOffset:size animated:YES];
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self iconCheck];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag !=2)
        if (textField.text.length != 0)
            [self checkFunction:textField.text withType:[NSString stringWithFormat:@"%ld",(long)textField.tag]];
    
    [self iconCheck];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

- (void)iconCheck{
    if ([Utils stringIsEmpty:_textField1.text]) {
        _icon1.image = [UIImage imageNamed:@"username"];
    }
    if ([Utils stringIsEmpty:_textField2.text]) {
        _icon2.image = [UIImage imageNamed:@"mail"];
    }
    if ([Utils stringIsEmpty:_textField3.text]) {
        _icon3.image = [UIImage imageNamed:@"pw"];
    }
}

- (void)valueChange:(UITextField *)sender {
    if (sender.tag == 0) {
        if (sender.text.length>=3){
            _icon1.image = [UIImage imageNamed:@"username-green"];
            _icon1.tag = 0;
        }
        else if (sender.text.length == 0){
            _icon1.image = [UIImage imageNamed:@"username"];
            _icon1.tag = 0;
        }
        else{
            _icon1.image = [UIImage imageNamed:@"username-red"];
            _icon1.tag = 1;
        }
    }
    else if (sender.tag == 1){
        if ([Utils stringIsValidEmail:sender.text]) {
            _icon2.image = [UIImage imageNamed:@"mail-green"];
            _icon2.tag = 0;
        }
        else if (sender.text.length == 0){
            _icon2.image = [UIImage imageNamed:@"mail"];
            _icon2.tag = 0;
        }
        else{
            _icon2.image = [UIImage imageNamed:@"mail-red"];
            _icon2.tag = 1;
        }
        
    }
    else if (sender.tag == 2){
        if (![Utils stringIsEmpty:sender.text]) {
            if (sender.text.length>=1){
                _icon3.image = [UIImage imageNamed:@"pw-green"];
                _icon3.tag = 0;
            }
            else if (sender.text.length == 0){
                _icon1.image = [UIImage imageNamed:@"pw"];
                _icon1.tag = 0;
            }
            else{
                _icon3.image = [UIImage imageNamed:@"pw-red"];
                _icon3.tag = 1;
            }
        }
    }
}

- (void)checkFunction:(NSString *)value withType:(NSString *)type{
    if (![Utils stringIsValidEmail:value] && [type integerValue] == 1)
        return;
    if (3>[value length] && [type integerValue] == 0){
        _icon1.tag = 1;
        _icon1.image = [UIImage imageNamed:@"username-red"];
        [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"ITLeastCharacter"] withTag:1];
        return;
    }
    
    if ([Utils stringIsEmpty:value])
        value = @"----------";
    
    if ([type integerValue] == 0 && value.length!=0) {
        [_indicator1 startAnimating];
        _indicator1.hidden = NO;
    }
    else if ([type integerValue] == 1 && value.length!=0) {
        [_indicator2 startAnimating];
        _indicator2.hidden = NO;
    }
    
    id params = @{@"uservalue":value,
                  @"servicetoken":servicetoken,
                  @"typevalue":type
                  };
    
    [Utils callPostApi:checkuser params:params integer:0 withType:1 progress:nil success:^(id responseObject) {
        id data = [Utils jsonWithData:responseObject error:nil];
        if ([type integerValue] == 0) {
            _indicator1.hidden = YES;
            [_indicator1 stopAnimating];
            if ([[data objectForKey:@"returnCode"] boolValue] == TRUE){
                _icon1.image = [UIImage imageNamed:@"username-green"];
                _icon1.tag = 0;
                return;
            }
            else{
                _icon1.tag = 1;
                _icon1.image = [UIImage imageNamed:@"username-red"];
                [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"ITUsernameIsNotAvilable"] withTag:1];
                return;
            }
        }
        else if ([type integerValue] == 1) {
            _indicator2.hidden = YES;
            [_indicator2 stopAnimating];
            if ([[data objectForKey:@"returnCode"] boolValue] == TRUE){
                _icon2.image = [UIImage imageNamed:@"mail-green"];
                _icon2.tag = 0;
                return;
            }else{
                _icon2.tag = 1;
                _icon2.image = [UIImage imageNamed:@"mail-red"];
                [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"CLWrongEmail"] withTag:1];
                return;
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (IBAction)sendFunction:(id)sender {
    [self keyboardHide:nil];
    if ([Utils stringIsEmpty:_textField1.text]||[Utils stringIsEmpty:_textField2.text]||[Utils stringIsEmpty:_textField3.text])
        [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"ITAllFieldsAreRequired"] withTag:1];
    else if (3>[_textField1.text length])
        [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"ITLeastCharacter"] withTag:1];
    else if (!_privacyButton.isSelected)
        [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"ITPrivacyAcception"] withTag:1];
    else{
        if ([Utils stringIsValidEmail:_textField2.text]) {
            if (_icon1.tag == 1) {
                [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"CLUsernameIsNotAvilable"] withTag:1];
                return;
            }
            if (_icon2.tag == 1) {
                [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"CLEmailIsNotAvilable"] withTag:1];
                return;
            }
            if (_icon3.tag == 1) {
                [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"CLLengthErr6"] withTag:1];
                return;
            }
            _identity.username = _textField1.text;
            _identity.email = _textField2.text;
            _identity.passWord = _textField3.text;
            
            if ([UIImagePNGRepresentation (_button.currentBackgroundImage) isEqualToData:UIImagePNGRepresentation([UIImage imageNamed:@"addphoto"])])
                _identity.imageData = UIImagePNGRepresentation([UIImage imageNamed:@"profil-default-pf-pic"]);
            else
                _identity.imageData = [Utils imageWithImage:_button.currentBackgroundImage scaledToSize:CGSizeMake([Utils screenWidth]*2,[Utils screenWidth]*2)];
            
            id deviceToken = [Utils objForPrefKey:@"UserDeviceToken"];
            
            if ([Utils stringIsEmpty:deviceToken])
                deviceToken = @"-";
            
            id params = @{
                          @"fbid":_identity.fbid,
                          @"fbtoken":_identity.fbToken,
                          @"username":_textField1.text,
                          @"email":_textField2.text,
                          @"password":_textField3.text,
                          @"namesurname":_identity.nameSurname,
                          @"gender":_identity.gender,
                          @"servicetoken":servicetoken,
                          @"devicetoken":deviceToken,
                          @"iosversion":[NSString stringWithFormat:@"%f",[[[UIDevice currentDevice] systemVersion] floatValue]],
                          @"phonetype":[Utils deviceName],
                          @"photostr":[Utils base64forData:_identity.imageData]
                          };
            
            [Utils callPostApi:createuser params:params integer:0 withType:0 progress:nil success:^(id responseObject) {
                id data = [Utils jsonWithData:responseObject error:nil];
                if ([[data objectForKey:@"returnCode"] integerValue] == 1) {
                    _identity.userToken = [data objectForKey:@"apptoken"];
                    _identity.userid = @([[data objectForKey:@"userid"] integerValue]);
                    [Session beginStartSessionWithIdentity: _identity];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableVC" object:nil];
                    [self performSegueWithIdentifier:@"registerLoginSegue" sender:self];
                }
                else if ([[data objectForKey:@"returnCode"] integerValue] == 0) {
                    
                }
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
    }
}

- (IBAction)takePhotoFunction:(id)sender {
    [self keyboardHide:nil];
    UIActionSheet *photoactionSheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        photoactionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:[Utils localizedString:@"ITDismiss"]
                                         destructiveButtonTitle:nil//@"Fotoğrafı kaldır"
                                              otherButtonTitles:
                            [Utils localizedString:@"ITTakePhoto"],
                            [Utils localizedString:@"ITPickPhotoFromGallery"]
                            , nil];
    } else {
        photoactionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle: [Utils localizedString:@"ITDismiss"]
                                         destructiveButtonTitle:nil//@"Fotoğrafı kaldır"
                                              otherButtonTitles:[Utils localizedString:@"ITPickPhotoFromGallery"], nil];
    }
    
    [photoactionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && buttonIndex == 0) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        [imagePicker setDelegate:(id)self];
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        [imagePicker setDelegate:(id)self];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)showAlertView:(NSString *)title withMessage:(NSString *)message withTag:(int)tag{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[Utils localizedString:title] message:[Utils localizedString:message] delegate:self cancelButtonTitle:[Utils localizedString:@"ITOk"] otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
    return;
    
}

- (IBAction)backFunction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
    }
}

- (void)privacyStates:(NSNotification *)notice {
    UIButton * btn = (UIButton *)notice.object;
    if (btn.tag == 1) {
        [_privacyButton setImage:[UIImage imageNamed:@"check_1"] forState:UIControlStateNormal];
        [_privacyButton setSelected:YES];
    }
    else{
        [_privacyButton setSelected:NO];
        [_privacyButton setImage:[UIImage imageNamed:@"check_0"] forState:UIControlStateNormal];
    }
}

#pragma mark - Action methods

- (IBAction)openEditor:(id)sender{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.cropAspectRatio = 1;
    controller.keepingCropAspectRatio = YES;
    controller.image = _button.currentBackgroundImage;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [_button setBackgroundImage:image forState:UIControlStateNormal];
    [_button setTitle:@"" forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        
        [self updateEditButtonEnabled];
        
        [self openEditor:nil];
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self openEditor:nil];
        }];
    }
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [_button setBackgroundImage:croppedImage forState:UIControlStateNormal];
    [_button setTitle:@"" forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self updateEditButtonEnabled];
    }
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self updateEditButtonEnabled];
    }
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)updateEditButtonEnabled{
    self.editButton.enabled = !!_button.currentBackgroundImage;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
