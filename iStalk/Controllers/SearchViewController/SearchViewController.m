//
//  SearchViewController.m
//  iStalk
//
//  Created by Semih EKIZ on 14/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "SearchViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <TwitterKit/TwitterKit.h>
#import "FSOAuth.h"

extern NSManagedObjectContext* getDBCtx();


@interface SearchViewController (){
    NSInteger tag;
    User *fbUser, *twUser, *fsUser, *insUser;
    NSNumber *iD;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:twitterConsumerKey
                                             consumerSecret:twitterConsumerSecretKey];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tag = 0;
    dataArray = [NSMutableArray new];
    NSMutableArray *fbArray = [NSMutableArray new];
    NSMutableArray *twArray = [NSMutableArray new];
    NSMutableArray *fsArray = [NSMutableArray new];
    NSMutableArray *insArray = [NSMutableArray new];
    [dataArray addObject:fbArray];
    [dataArray addObject:twArray];
    [dataArray addObject:fsArray];
    [dataArray addObject:insArray];
    
    fbUser = [User new];
    twUser = [User new];
    fsUser = [User new];
    insUser = [User new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"reloadDataVC" object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    _context = getDBCtx();
}

- (void)appplicationIsActive:(NSNotification *)notification {
    if (![Utils stringIsEmpty:_textField.text] && tag == 2 && ![Utils stringIsEmpty:[Session identity].fsid])
        [self searchFunction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

#pragma -mark textField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    if (![Utils stringIsEmpty:_textField.text])
        [self searchFunction:nil];
    return NO;
}

#pragma mark - UITableView Delegate & Datasrouce

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[dataArray objectAtIndex:tag] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [[dataArray objectAtIndex:tag] objectAtIndex:indexPath.row];
    ProfileCell *cell = (ProfileCell *)[_tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.row;
    
    NSMutableURLRequest *imgRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:user.imageUrl]];
    [imgRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [imgRequest setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
    __weak typeof(cell.profileImageView) weakImageV = cell.profileImageView;
    [cell.profileImageView setImageWithURLRequest:imgRequest
                                 placeholderImage:[UIImage imageNamed:@"profil-default-pf-pic"]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                              weakImageV.image = image;
                                              UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
                                              [tapRecognizer addTarget:self action:@selector(photoViewer:)];
                                              [cell.profileImageView addGestureRecognizer:tapRecognizer];
                                          } failure:nil];
    
    cell.nameSurnameLabel.text = user.nameSurname;
    [cell.connectionButton setTitle:user.profileUrl forState:UIControlStateNormal];
    
    if ([user.userId integerValue] == [fbUser.userId integerValue]
        || [user.userId integerValue] == [twUser.userId integerValue]
        || [user.userId integerValue] == [fsUser.userId integerValue]
        || [user.userId integerValue] == [insUser.userId integerValue]) {
        [cell.followButton setImage:[UIImage imageNamed:@"follow_1"] forState:UIControlStateNormal];
        [cell.followButton setSelected:YES];
    }
    else{
        [cell.followButton setImage:[UIImage imageNamed:@"follow_0"] forState:UIControlStateNormal];
        [cell.followButton setSelected:NO];
    }
    cell.followButton.tag = indexPath.row;
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"haydaa");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62;
}

#pragma mark - IGSessionDelegate

- (void)request:(IGRequest *)request didLoad:(id)result {
    NSDictionary* resultDictionary = (NSDictionary*) result;
    NSDictionary* data = [resultDictionary valueForKey:@"data"];
    [Session identity].insid = [data objectForKey:@"id"];
    
    id params = @{
                  @"userid":[Session identity].userid,
                  @"parameters":@[[NSString stringWithFormat:@"insid = '%@'",[Session identity].insid],
                                  [NSString stringWithFormat:@"insaccesstoken = '%@'",[Session identity].insToken]]
                  };
    
    [self updateToken:params];
}

- (void)igDidLogin {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [Session identity].insToken = appDelegate.instagram.accessToken;
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self", @"method", nil];
    [appDelegate.instagram requestWithParams:params delegate:self];
}

- (void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled)
        message = @"Access cancelled!";
    else
        message = @"Access denied!";
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)igDidLogout {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)igSessionInvalidated {
    NSLog(@"Instagram session was invalidated");
}

#pragma - mark Foursquare

- (void)handleURL:(NSURL *)url {
    FSOAuthErrorCode errorCode;
    NSString *accessCode = [FSOAuth accessCodeForFSOAuthURL:url error:&errorCode];;
    
    if (errorCode == FSOAuthErrorNone)
        [self convertTapped:accessCode];
}

- (void)convertTapped:(NSString *)sender {
    [FSOAuth requestAccessTokenForCode:sender
                              clientId:foursquareClientId
                     callbackURIString:foursquareRedirectUrl
                          clientSecret:foursquareClientSecret
                       completionBlock:^(NSString *authToken, BOOL requestCompleted, FSOAuthErrorCode errorCode) {
                           if (requestCompleted) {
                               if (errorCode == FSOAuthErrorNone){
                                   [Session identity].fsToken = authToken;
                                   [Utils callApi:@"https://api.foursquare.com/v2/users/self" params:[NSString stringWithFormat:@"?oauth_token=%@&v=20151221",[Session identity].fsToken] integer:0 withType:0 success:^(id responseObject) {
                                       id data = [Utils jsonWithData:responseObject error:nil];
                                       [Session identity].fsid = [[[data objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
                                       id params = @{
                                                     @"userid":[Session identity].userid,
                                                     @"parameters":@[[NSString stringWithFormat:@"fsid = '%@'",[Session identity].fsid],
                                                                     [NSString stringWithFormat:@"fsaccesstoken = '%@'",authToken]]
                                                     };
                                       [self updateToken:params];
                                   } failure:^(NSError *error) {
                                       NSLog(@"%@",error);
                                   }];
                               }
                           }
                       }];
    
    
}

#pragma mark - Twitter

- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount {
    if(twitterAPI != _twitter)
        return;
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    [self dismissViewControllerAnimated:YES completion:^{
        [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
            [Session identity].twToken = oauthToken;
            [Session identity].twSecret = oauthTokenSecret;
            [Session identity].twid = userID;
            
            id params = @{
                          @"userid":[Session identity].userid,
                          @"parameters":@[[NSString stringWithFormat:@"twid = '%@'",[Session identity].twid],
                                          [NSString stringWithFormat:@"twaccesstoken = '%@'",oauthToken],
                                          [NSString stringWithFormat:@"twaccesstokensecret = '%@'",oauthTokenSecret]]
                          };
            [self updateToken:params];
            
            if (![Utils stringIsEmpty:_textField.text])
                [self searchFunction:nil];
        } errorBlock:^(NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
        }];
    }];
    
}

#pragma - mark Functions

- (IBAction)socialFunction:(UIButton *)sender {
    [self keyboardHide:nil];
    [_button1 setBackgroundColor:COLOR_RGBA(24, 121, 142, 0.28)];
    [_button1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_button2 setBackgroundColor:COLOR_RGBA(24, 121, 142, 0.28)];
    [_button2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_button3 setBackgroundColor:COLOR_RGBA(24, 121, 142, 0.28)];
    [_button3 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_button4 setBackgroundColor:COLOR_RGBA(24, 121, 142, 0.28)];
    [_button4 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [sender setBackgroundColor:COLOR_RGBA(24, 121, 142, 0.85)];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tag = sender.tag;
    
    [_tableView reloadData];
    if (sender.tag == 0) {
        if ([Utils stringIsEmpty:[Session identity].fbToken]) {
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            [login logInWithReadPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error){
                if (!error){
                    if ([result.grantedPermissions containsObject:@"email"]){
                        [Session identity].fbToken = [[FBSDKAccessToken currentAccessToken] tokenString];
                        if ([FBSDKAccessToken currentAccessToken]){
                            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, link, first_name, gender, last_name, picture.type(large), email, birthday, bio ,location ,friends ,hometown , friendlists"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                
                                [Session identity].fbid = [result objectForKey:@"id"];
                                [Session identity].nameSurname = [result objectForKey:@"name"];
                                if ([[result objectForKey:@"gender"] isEqualToString:@"male"])
                                    [Session identity].gender = @(2);
                                else if ([[result objectForKey:@"gender"] isEqualToString:@"female"])
                                    [Session identity].gender = @(3);
                                else
                                    [Session identity].gender = @(1);
                                
                                id params = @{
                                              @"userid":[Session identity].userid,
                                              @"parameters":@[[NSString stringWithFormat:@"namesurname = '%@'",[Session identity].nameSurname],
                                                              [NSString stringWithFormat:@"gender = '%@'",[Session identity].gender],
                                                              [NSString stringWithFormat:@"fbid = '%@'",[Session identity].fbid],
                                                              [NSString stringWithFormat:@"fbaccesstoken = '%@'",[Session identity].fbToken]]
                                              };
                                [self updateToken:params];
                            }];
                        }
                    }
                }
                [login logOut];
            }];
            return;
        }
    }
    else if (sender.tag == 1) {
        if ([Utils stringIsEmpty:[Session identity].twToken] && [Utils stringIsEmpty:[Session identity].twSecret]) {
            [LoadingView show];
            
            [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
                WebViewVC *webViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewVC"];
                [webViewVC setUrl:url];
                [self presentViewController:webViewVC animated:YES completion:nil];
            } authenticateInsteadOfAuthorize:NO
                            forceLogin:@(YES)
                            screenName:nil
                         oauthCallback:@"twtoken://twitter_access_tokens/"
                            errorBlock:^(NSError *error) {
                                NSLog(@"%@", error);
                            }];
            return;
        }
    }
    else if (sender.tag == 2) {
        if ([Utils stringIsEmpty:[Session identity].fsToken]) {
            FSOAuthStatusCode statusCode = [FSOAuth authorizeUserUsingClientId:foursquareClientId
                                                       nativeURICallbackString:foursquareRedirectUrl
                                                    universalURICallbackString:@""
                                                          allowShowingAppStore:YES];
            
            NSString *resultText = nil;
            switch (statusCode) {
                case FSOAuthStatusSuccess:
                    break;
                case FSOAuthStatusErrorInvalidCallback: {
                    resultText = @"Invalid callback URI";
                    break;
                }
                case FSOAuthStatusErrorFoursquareNotInstalled: {
                    resultText = @"Foursquare not installed";
                    break;
                }
                case FSOAuthStatusErrorInvalidClientID: {
                    resultText = @"Invalid client id";
                    break;
                }
                case FSOAuthStatusErrorFoursquareOAuthNotSupported: {
                    resultText = @"Installed FSQ app does not support oauth";
                    break;
                }
                default: {
                    resultText = @"Unknown status code returned";
                    break;
                }
            }
            NSLog(@"%@",resultText);
            return;
        }
    }
    else if (sender.tag == 3) {
        if ([Utils stringIsEmpty:[Session identity].insToken]) {
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            appDelegate.instagram.sessionDelegate = self;
            [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"basic",@"comments", @"likes", nil]];
            return;
        }
    }
    
    if ([[dataArray objectAtIndex:sender.tag] count] == 0 && ![Utils stringIsEmpty:_textField.text])
        [self searchFunction:nil];
}

- (void)keyboardHide:(UITapGestureRecognizer *)gr {
    [_textField resignFirstResponder];
}

- (void)goProfile:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sender.titleLabel.text]];
}

- (IBAction)addPerson:(id)sender {
    [self keyboardHide:nil];
    if ([Utils stringIsEmpty:_textField.text]) {
        [self showAlertView:@"ITAttention" withMessage:@"ITAttention_Message_7" withTag:1];
        return;
    }
    else if ([fbUser.userId integerValue] == 0 && [twUser.userId integerValue] == 0 && [fsUser.userId integerValue] == 0 && [insUser.userId integerValue] == 0){
        [self showAlertView:@"ITAttention" withMessage:@"ITAttention_Message_10" withTag:1];
        return;
    }
    
    if ([Utils stringIsEmpty:[NSString stringWithFormat:@"%@",iD]]) {
        NSLog(@"%@",[Utils objForPrefKey:@"nextID"]);
        if ([Utils stringIsEmpty:[Utils objForPrefKey:@"nextID"]])
            [Utils setObject:@"0" forPrefKey:@"nextID"];
        else
            [Utils setObject:[NSString stringWithFormat:@"%ld",[[Utils objForPrefKey:@"nextID"] integerValue]+1] forPrefKey:@"nextID"];
        [Utils synchronize];
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"DataEntity" inManagedObjectContext:self.context];
        [req setEntity:entityDesc];

        DataEntity *newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"DataEntity" inManagedObjectContext:self.context];
        newRecord.iD = @([[Utils objForPrefKey:@"nextID"] integerValue]);
        newRecord.userId = @([[Session identity].userid integerValue]);
        newRecord.nameSurname = _textField.text;
        newRecord.fbObject = [NSKeyedArchiver archivedDataWithRootObject:fbUser];
        newRecord.twObject = [NSKeyedArchiver archivedDataWithRootObject:twUser];
        newRecord.fsObject = [NSKeyedArchiver archivedDataWithRootObject:fsUser];
        newRecord.insObject= [NSKeyedArchiver archivedDataWithRootObject:insUser];
        [self.context save:nil];
        [self showAlertView:nil withMessage:@"ITAttention_Message_8" withTag:1];
    }
    else{
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"DataEntity" inManagedObjectContext:self.context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.iD == %d",[iD integerValue]];
        [req setEntity:entityDesc];
        [req setPredicate:predicate];
        NSArray *result = [self.context executeFetchRequest:req error:nil];
        
        if ([result count] > 0) {
            DataEntity *updateRecor = [result objectAtIndex:0];
            updateRecor.iD = iD;
            updateRecor.userId = @([[Session identity].userid integerValue]);
            updateRecor.nameSurname = _textField.text;
            [fbUser.userId integerValue] == 0 ? 0 : (updateRecor.fbObject = [NSKeyedArchiver archivedDataWithRootObject:fbUser]);
            [fsUser.userId integerValue] == 0 ? 0 : (updateRecor.fsObject = [NSKeyedArchiver archivedDataWithRootObject:fsUser]);
            [twUser.userId integerValue] == 0 ? 0 : (updateRecor.twObject = [NSKeyedArchiver archivedDataWithRootObject:twUser]);
            [insUser.userId integerValue] == 0 ? 0 : (updateRecor.insObject = [NSKeyedArchiver archivedDataWithRootObject:insUser]);
            [self.context save:nil];
            [self showAlertView:nil withMessage:@"ITAttention_Message_9" withTag:1];
        }
    }
}

- (IBAction)followFunction:(UIButton *)sender {
    NSString *str;
    if (tag == 0){
        fbUser = [[dataArray objectAtIndex:tag] objectAtIndex:sender.tag];
        str = [NSString stringWithFormat:@"fbid = '%@'",fbUser.userId];
    }
    else if (tag == 1){
        twUser = [[dataArray objectAtIndex:tag] objectAtIndex:sender.tag];
        str = [NSString stringWithFormat:@"twid = '%@'",twUser.userId];
    }
    else if (tag == 2){
        fsUser = [[dataArray objectAtIndex:tag] objectAtIndex:sender.tag];
        str = [NSString stringWithFormat:@"fsid = '%@'",fsUser.userId];
    }
    else {
        insUser = [[dataArray objectAtIndex:tag] objectAtIndex:sender.tag];
        str = [NSString stringWithFormat:@"insid = '%@'",insUser.userId];
    }
    
    id params = @{
                  @"userid":[Session identity].userid,
                  @"parameters":@[str,
                                  [NSString stringWithFormat:@"servicetoken = '%@'",servicetoken]]
                  };
    [Utils callPostApi:getuseraccesstoken params:params integer:0 withType:0 progress:nil success:^(id responseObject) {
        id data = [Utils jsonWithData:responseObject error:nil];
        for (int i=0; i<[[dataArray objectAtIndex:tag] count]; i++) {
            ProfileCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell.followButton setSelected:NO];
            [cell.followButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"follow_%d",sender.selected]] forState:UIControlStateNormal];
        }
        if (tag == 0)
            fbUser.accesstoken = [data objectForKey:@"fbaccesstoken"];
        else if (tag == 1){
            NSLog(@"%@",data);
            twUser.accesstoken = [data objectForKey:@"twaccesstoken"];
            twUser.accesstokensecret = [data objectForKey:@"twaccesstokensecret"];
        }
        else if (tag == 2)
            fsUser.accesstoken = [data objectForKey:@"fsaccesstoken"];
        else if (tag == 3)
            insUser.accesstoken = [data objectForKey:@"insaccesstoken"];
        
        [sender setSelected:YES];
        [sender setImage:[UIImage imageNamed:[NSString stringWithFormat:@"follow_%d",sender.selected]] forState:UIControlStateNormal];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (IBAction)leftMenuFunction:(id)sender {
    [[SlideNavigationController sharedInstance] openMenu:MenuLeft withCompletion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableVC" object:nil];
    }];
}

- (IBAction)searchFunction:(id)sender {
    [self keyboardHide:nil];
    if ([Utils stringIsEmpty:_textField.text]) {
        [self showAlertView:@"ITAttention" withMessage:@"ITAttention_Message_7" withTag:1];
        return;
    }
    [[dataArray objectAtIndex:tag] removeAllObjects];
    if (tag == 0) {
        if (![Utils stringIsEmpty:[Session identity].fbToken]){
            [Utils callApi:@"https://graph.facebook.com/search" params:[NSString stringWithFormat:@"?&q=%@&type=user&access_token=%@",[_textField.text urlEncodeUsingEncoding:NSUTF8StringEncoding],[Session identity].fbToken] integer:0 withType:0 success:^(id responseObject) {
                id dataResponse = [Utils jsonWithData:responseObject error:nil];
                id data = [dataResponse objectForKey:@"data"];
                for (int i = 0; i < [data count]; i++) {
                    User *user = [User new];
                    user.userId = [[data objectAtIndex:i] objectForKey:@"id"];
                    user.nameSurname = [[data objectAtIndex:i] objectForKey:@"name"];
                    user.imageUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%d&height=%d",[[data objectAtIndex:i] objectForKey:@"id"],(int)[Utils screenWidth]*2,(int)[Utils screenWidth]*2];
                    user.profileUrl = [NSString stringWithFormat:@"http://facebook.com/%@",[[data objectAtIndex:i] objectForKey:@"id"]];
                    [[dataArray objectAtIndex:tag] addObject:user];
                }
                [_tableView reloadData];
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
        else
            [self socialFunction:_button1];
    }
    else if (tag == 1) {
        if (![Utils stringIsEmpty:[Session identity].twToken] && ![Utils stringIsEmpty:[Session identity].twSecret]){
            
            _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil consumerKey:twitterConsumerKey consumerSecret:twitterConsumerSecretKey oauthToken:[Session identity].twToken oauthTokenSecret:[Session identity].twSecret];
            [LoadingView show];
            [_twitter getUsersSearchQuery:_textField.text page:@"0" count:@"100" includeEntities:nil successBlock:^(NSArray *users) {
                for (int i = 0; i<[users count]; i++) {
                    User *user = [User new];
                    user.userId = [[users objectAtIndex:i] objectForKey:@"id"];
                    user.nameSurname = [[users objectAtIndex:i] objectForKey:@"screen_name"];
                    user.imageUrl = [NSString stringWithFormat:@"https://twitter.com/%@/profile_image?size=original",[[users objectAtIndex:i] objectForKey:@"screen_name"]];
                    user.profileUrl = [NSString stringWithFormat:@"http://twitter.com/%@",[[users objectAtIndex:i] objectForKey:@"screen_name"]];
                    [[dataArray objectAtIndex:tag] addObject:user];
                }
                [_tableView reloadData];
                [LoadingView hide];
            } errorBlock:^(NSError *error) {
                [LoadingView hide];
                NSLog(@"%@",error);
            }];
        }
        else
            [self socialFunction:_button2];
    }
    else if (tag == 2) {
        if (![Utils stringIsEmpty:[Session identity].fsToken]){
            [Utils callApi:@"https://api.foursquare.com/v2/users/search" params:[NSString stringWithFormat:@"?name=%@&oauth_token=%@&v=20151221",[_textField.text urlEncodeUsingEncoding:NSUTF8StringEncoding],[Session identity].fsToken] integer:0 withType:0 success:^(id responseObject) {
                id data = [[[Utils jsonWithData:responseObject error:nil] objectForKey:@"response"] objectForKey:@"results"];
                for (int i = 0; i<[data count]; i++) {
                    User *user = [User new];
                    user.userId = [[data objectAtIndex:i] objectForKey:@"id"];
                    NSLog(@"%@",user.userId);
                    user.nameSurname = [NSString stringWithFormat:@"%@ %@",[[data objectAtIndex:i] objectForKey:@"firstName"],[[data objectAtIndex:i] objectForKey:@"lastName"]];
                    user.imageUrl = [NSString stringWithFormat:@"%@%dx%d%@",[[[data objectAtIndex:i] objectForKey:@"photo"] objectForKey:@"prefix"],(int)[Utils screenWidth]*2,(int)[Utils screenWidth]*2,[[[data objectAtIndex:i] objectForKey:@"photo"] objectForKey:@"suffix"]];
                    
                    if (![Utils stringIsEmpty:[[[data objectAtIndex:i] objectForKey:@"contact"] objectForKey:@"twitter"]])
                        user.profileUrl = [NSString stringWithFormat:@"http://foursquare.com/%@",[[[data objectAtIndex:i] objectForKey:@"contact"] objectForKey:@"twitter"]];
                    
                    else
                        user.profileUrl = [NSString stringWithFormat:@"http://foursquare.com/user/%@",[[data objectAtIndex:i] objectForKey:@"id"]];
                    [[dataArray objectAtIndex:tag] addObject:user];
                }
                [_tableView reloadData];
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
        else
            [self socialFunction:_button3];
    }
    else if (tag == 3) {
        if (![Utils stringIsEmpty:[Session identity].insToken]){
            [Utils callApi:@"https://api.instagram.com/v1/users/search" params:[NSString stringWithFormat:@"?q=%@&access_token=%@",[_textField.text urlEncodeUsingEncoding:NSUTF8StringEncoding],[Session identity].insToken] integer:0 withType:0 success:^(id responseObject) {
                id data = [[Utils jsonWithData:responseObject error:nil] objectForKey:@"data"];
                for (int i = 0; i<[data count]; i++) {
                    User *user = [User new];
                    user.userId = [[data objectAtIndex:i] objectForKey:@"id"];
                    user.nameSurname = [[data objectAtIndex:i] objectForKey:@"full_name"];
                    user.imageUrl = [[data objectAtIndex:i] objectForKey:@"profile_picture"];
                    user.profileUrl = [NSString stringWithFormat:@"http://instagram.com/%@",[[data objectAtIndex:i] objectForKey:@"username"]];
                    [[dataArray objectAtIndex:tag] addObject:user];
                }
                [_tableView reloadData];
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
        else
            [self socialFunction:_button4];
    }
}

- (void)showAlertView:(NSString *)title withMessage:(NSString *)message withTag:(int)alertTag{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[Utils localizedString:title] message:[Utils localizedString:message] delegate:self cancelButtonTitle:[Utils localizedString:@"ITOk"] otherButtonTitles:nil];
    alert.tag = alertTag;
    [alert show];
    return;
}

- (void)photoViewer:(UIGestureRecognizer *)sender{
    UIImageView *imageView = (UIImageView *)sender.view;
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = [(UIImageView *)sender.view image];
    imageInfo.referenceRect = imageView.frame;
    imageInfo.referenceView = imageView.superview;
    imageInfo.referenceContentMode = imageView.contentMode;
    imageInfo.referenceCornerRadius = imageView.layer.cornerRadius;
    
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (void)updateToken:(id)params {
    [Utils callPostApi:updatetoken params:params integer:0 withType:0 progress:nil success:^(id responseObject) {
        [LoadingView hide];
        if (![Utils stringIsEmpty:_textField.text] && tag !=2)
            [self searchFunction:nil];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)reloadData:(NSNotification *)notice {
    id data = notice.object;
    _textField.text = [data objectForKey:@"nameSurname"];
    tag = [(UIButton *)[data objectForKey:@"button"] tag];
    iD = [data objectForKey:@"userid"];
    if (tag == 0)
        [self socialFunction:_button1];
    else if (tag == 1)
        [self socialFunction:_button2];
    else if (tag == 2)
        [self socialFunction:_button3];
    else if (tag == 3)
        [self socialFunction:_button4];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end