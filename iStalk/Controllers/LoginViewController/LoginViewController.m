//
//  LoginViewController.m
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utils flurry:@"LoginScreen" withlogError:@"LoginScreen_Error"];
    
    [self.textField1 setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.textField2 setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
//    _button.layer.cornerRadius = 0.0f;
//    _button.layer.masksToBounds = YES;
//    _button.layer.borderColor = [[UIColor lightTextColor] CGColor];
//    _button.layer.borderWidth = 1.0f;
//    
//    _fbbutton.layer.cornerRadius = 0.0f;
//    _fbbutton.layer.masksToBounds = YES;
//    _fbbutton.layer.borderColor = [[UIColor lightTextColor] CGColor];
//    _button.layer.borderWidth = 1.0f;
    
    
    
    
    NSString *baseURL;
#ifdef DEBUG
    baseURL = @"debug";
#endif
    
#ifdef RELEASE
    baseURL = @"release";
#endif
    
#ifdef DISTRIBUTIONRELEASE
    baseURL = @"Distributiobrelease";
#endif
    
#ifdef SEMIHDEBUG
    baseURL = @"semihdebug";
#endif
    NSLog(@"%@",baseURL);
    
    

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma -mark textField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder)
        [nextResponder becomeFirstResponder];
    else
        [self loginFunction:nil];
    return NO;
}

#pragma -mark Functions

- (void)keyboardHide:(UITapGestureRecognizer *)gr {
    [_textField1 resignFirstResponder];
    [_textField2 resignFirstResponder];
}

- (IBAction)loginFunction:(id)sender {
    if ([Utils stringIsEmpty:_textField1.text]) {
        [self showAlertView:@"ITAttention" withMessage:@"ITAttention_Message_4" withTag:1];
        return;
    }
    else if ([Utils stringIsEmpty:_textField2.text]){
        [self showAlertView:@"ITAttention" withMessage:@"ITAttention_Message_5" withTag:1];
        return;
    }
    
    id deviceToken = [Utils objForPrefKey:@"UserDeviceToken"];
    if ([Utils stringIsEmpty:deviceToken])
        deviceToken = @"-";

    [self keyboardHide:nil];
    
    id params = @{
                  @"servicetoken":servicetoken,
                  @"username":_textField1.text,
                  @"password":_textField2.text,
                  @"devicetoken":deviceToken
                  };
    
    [Utils callPostApi:login params:params integer:0 withType:0 progress:nil success:^(id responseObject) {
        id data = [Utils jsonWithData:responseObject error:nil];
        if ([[data objectForKey:@"returnCode"] integerValue] == 1) {
            id dataContent = [[data objectForKey:@"data"] objectAtIndex:0];
            Identity *identity = [Identity new];
            identity.authtoken = servicetoken;
            identity.fbid = [dataContent objectForKey:@"fbid"];
            identity.fbToken = [dataContent objectForKey:@"fbtoken"];
            identity.twid = [dataContent objectForKey:@"twid"];
            identity.twToken = [dataContent objectForKey:@"twtoken"];
            identity.twSecret = [dataContent objectForKey:@"twtokensecret"];
            identity.fsid = [dataContent objectForKey:@"fsid"];
            identity.fsToken = [dataContent objectForKey:@"fstoken"];
            identity.insid = [dataContent objectForKey:@"insid"];
            identity.insToken = [dataContent objectForKey:@"instoken"];
            identity.userid = [dataContent objectForKey:@"userid"];
            identity.nameSurname = [dataContent objectForKey:@"namesurname"];
            identity.username = [dataContent objectForKey:@"namesurname"];
            identity.gender = [dataContent objectForKey:@"gender"];
            identity.email = [dataContent objectForKey:@"email"];
            identity.imagePath = [dataContent objectForKey:@"imageurl"];
            identity.userToken = [dataContent objectForKey:@"apptoken"];
            identity.loginFlag = @(1);
            
            [Session beginStartSessionWithIdentity: identity];
            [self performSegueWithIdentifier:@"mainSegue" sender:nil];
        }
        else
            [self showAlertView:@"ITAttention" withMessage:@"ITAttention_Message_6" withTag:1];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (IBAction)facebookFunction:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error){
        if (!error){
            if ([result.grantedPermissions containsObject:@"email"]){
                [self fetchUserInfo];
                [login logOut];
            }
        }
    }];
}

- (IBAction)registerFunction:(id)sender {
    Identity *identity = [Identity new];
    identity.authtoken = @"logged";
    identity.gender = @(1);
    identity.nameSurname = @"-";
    identity.fbid = @"0";
    identity.fbToken = @"-";
    [self performSegueWithIdentifier:@"loginSegue" sender:identity];
}

- (void)fetchUserInfo{
    Identity *identity = [Identity new];
    identity.fbToken = [[FBSDKAccessToken currentAccessToken] tokenString];
    
    if ([FBSDKAccessToken currentAccessToken]){
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, link, first_name, gender, last_name, picture.type(large), email, birthday, bio ,location ,friends ,hometown , friendlists"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             
             id params = @{
                           @"servicetoken":servicetoken,
                           @"fbid":[result objectForKey:@"id"]
                           };
             if (!error) {
                 [Utils callPostApi:loginWithFb params:params integer:0 withType:0 progress:nil success:^(id responseObject) {
                     id data = [Utils jsonWithData:responseObject error:nil];
                     if ([[data objectForKey:@"returnCode"] integerValue] == 1) {
                         id dataContent = [[data objectForKey:@"data"] objectAtIndex:0];
                         identity.authtoken = servicetoken;
                         identity.fbid = [dataContent objectForKey:@"fbid"];
                         identity.fbToken = [dataContent objectForKey:@"fbtoken"];
                         identity.twid = [dataContent objectForKey:@"twid"];
                         identity.twToken = [dataContent objectForKey:@"twtoken"];
                         identity.twSecret = [dataContent objectForKey:@"twtokensecret"];
                         identity.fsid = [dataContent objectForKey:@"fsid"];
                         identity.fsToken = [dataContent objectForKey:@"fstoken"];
                         identity.insid = [dataContent objectForKey:@"insid"];
                         identity.insToken = [dataContent objectForKey:@"instoken"];
                         identity.userid = [dataContent objectForKey:@"userid"];
                         identity.nameSurname = [dataContent objectForKey:@"namesurname"];
                         identity.username = [dataContent objectForKey:@"username"];
                         identity.gender = [dataContent objectForKey:@"gender"];
                         identity.email = [dataContent objectForKey:@"email"];
                         identity.imagePath = [dataContent objectForKey:@"imageurl"];
                         identity.userToken = [dataContent objectForKey:@"apptoken"];
                         identity.loginFlag = @(1);
                         [Session beginStartSessionWithIdentity: identity];
                         [self performSegueWithIdentifier:@"mainSegue" sender: identity];
                     }else{
                         identity.authtoken = servicetoken;
                         identity.fbid = [result objectForKey:@"id"];
                         identity.nameSurname = [result objectForKey:@"name"];
                         identity.email = [result objectForKey:@"email"];
                         identity.imagePath = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%d&height=%d",[result objectForKey:@"id"],(int)[Utils screenWidth]*2,(int)[Utils screenWidth]*2];
                         identity.loginFlag = @(1);
                         if ([[result objectForKey:@"gender"] isEqualToString:@"male"])
                             identity.gender = @(2);
                         else if ([[result objectForKey:@"gender"] isEqualToString:@"female"])
                             identity.gender = @(3);
                         else
                             identity.gender = @(1);
                         [self performSegueWithIdentifier:@"loginSegue" sender:identity];
                     }
                     
                 } failure:^(NSError *error) {
                     NSLog(@"%@",error);
                 }];
             }
         }];
        
    }
    
}

- (void)showAlertView:(NSString *)title withMessage:(NSString *)message withTag:(int)tag{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[Utils localizedString:title] message:[Utils localizedString:message] delegate:self cancelButtonTitle:[Utils localizedString:@"ITOk"] otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
    return;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(Identity *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableVC" object:nil];
    if ([[segue identifier] isEqualToString:@"loginSegue"])
        [segue.destinationViewController setIdentity:sender];
}
@end
