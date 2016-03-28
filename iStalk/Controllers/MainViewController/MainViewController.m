//
//  MainViewController.m
//  iStalk
//
//  Created by Semih EKIZ on 14/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "MainViewController.h"
#import "UIImageView+DownloadProgress.h"
#import <TwitterKit/TwitterKit.h>
#import "OAuthCore.h"

@interface MainViewController (){
    NSInteger tag;
    DataEntity *item;
    NSString *nextPage, *errorMessage;
    BOOL loadFlag;
    TimeLine *timeLine;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserFunction:) name:@"loadUserVC" object:nil];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    dataArray = [NSMutableArray new];
    NSMutableArray *fbArray = [NSMutableArray new];
    NSMutableArray *twArray = [NSMutableArray new];
    NSMutableArray *fsArray = [NSMutableArray new];
    NSMutableArray *insArray = [NSMutableArray new];
    [dataArray addObject:fbArray];
    [dataArray addObject:twArray];
    [dataArray addObject:fsArray];
    [dataArray addObject:insArray];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return YES;
}

#pragma - mark UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[dataArray objectAtIndex:tag] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    timeLine = [[dataArray objectAtIndex:tag] objectAtIndex:indexPath.row];
    if ([Utils stringIsEmpty:timeLine.errorMessage]) {
        if (tag == 0) {
            
            
        }
        else if (tag == 1) {
            TweetCell *cell = (TweetCell *)[_tableView dequeueReusableCellWithIdentifier:@"TweetIdentifier"];
            if ([Utils stringIsEmpty:errorMessage]) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = indexPath.row;
                NSLog(@"%@",timeLine.profileImageUrl);
                NSMutableURLRequest *imgRequestP = [NSMutableURLRequest requestWithURL:timeLine.profileImageUrl];
                [imgRequestP addValue:@"image/*" forHTTPHeaderField:@"Accept"];
                [imgRequestP setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
                __weak typeof(cell.profileImageView) weakImageP = cell.profileImageView;
                [cell.profileImageView setImageWithURLRequest:imgRequestP
                                             placeholderImage:[UIImage imageNamed:@"profil-default-pf-pic"]
                                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                                          weakImageP.image = image;
                                                      } failure:nil];
                
                cell.namesurname.text = timeLine.nameSurname;
                cell.dateLabel.text = [Utils timeStringBetweenDates:timeLine.createDate:[NSDate date]];
                cell.username.text = timeLine.userName;
                cell.text.text = timeLine.text;
                
                KILinkTapHandler tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
                    [self tappedLink:string cellForRowAtIndexPath:indexPath];
                };
                cell.text.userHandleLinkTapHandler = tapHandler;
                cell.text.urlLinkTapHandler = tapHandler;
                cell.text.hashtagLinkTapHandler = tapHandler;
                //      cell.text.usernameLinkTapHandler = tapHandler;
                
                [cell.retweetCount setTitle:[NSString stringWithFormat:@" %@",timeLine.retweetsCount] forState:UIControlStateNormal];
                [cell.favCount setTitle:[NSString stringWithFormat:@" %@",timeLine.favsCount] forState:UIControlStateNormal];
                if (!timeLine.retweet){
                    [cell.retweet setTitle:@"" forState:UIControlStateNormal];
                    cell.retweetHeight.constant = 0;
                    cell.topHeight.constant = 0;
                }else{
                    [cell.retweet setTitle:[NSString stringWithFormat:@"%@ %@",timeLine.retweetUserName, [Utils localizedString:@"ITRetweetDesc"]] forState:UIControlStateNormal];
                    cell.retweetHeight.constant = 30;
                    cell.topHeight.constant = 8;
                }
                if (indexPath.row + 1 == [[dataArray objectAtIndex:tag] count])
                    [cell.indicator startAnimating];
            }
            else
                cell.textLabel.text = errorMessage;
            return cell;
        }
        else if (tag == 2) {
            FoursquareCell *cell = (FoursquareCell *)[_tableView dequeueReusableCellWithIdentifier:@"FoursquareIdentifier"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            NSLog(@"%@",timeLine.text);
            NSMutableURLRequest *imgRequestP = [NSMutableURLRequest requestWithURL:timeLine.profileImageUrl];
            [imgRequestP addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            [imgRequestP setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
            __weak typeof(cell.profileImageView) weakImageP = cell.profileImageView;
            [cell.profileImageView setImageWithURLRequest:imgRequestP
                                         placeholderImage:[UIImage imageNamed:@"profil-default-pf-pic"]
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                                      weakImageP.image = image;
                                                  } failure:nil];
            
            cell.nameLabel.text = timeLine.nameSurname;
            cell.dateLabel.text = [Utils timeStringBetweenDates:timeLine.createDate:[NSDate date]];
            cell.descLabel.text = timeLine.text;
            cell.addressLabel.text = timeLine.address;
            
            NSMutableURLRequest *imgRequest = [NSMutableURLRequest requestWithURL:timeLine.imageUrl];
            [imgRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            [imgRequest setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
            __weak typeof(cell.cellImageView) weakImageV = cell.cellImageView;
            [cell.cellImageView setImageWithURLRequest:imgRequest
                                      placeholderImage:[UIImage imageNamed:@"noimage"]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                                   weakImageV.image = image;
                                               } failure:nil];
            
            [cell.imageView setImageWithURLRequest:imgRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakImageV.image = image;
            } failure:nil downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                cell.circularIndicator.value = (float)totalBytesRead / totalBytesExpectedToRead;
            }];
            [cell.likeCount setTitle:[NSString stringWithFormat:@" %@",timeLine.likesCount] forState:UIControlStateNormal];
            [cell.commentCount setTitle:[NSString stringWithFormat:@" %@",timeLine.commentsCount] forState:UIControlStateNormal];
            return cell;
        }
        else if (tag == 3) {
            InstagramCell *cell = (InstagramCell *)[_tableView dequeueReusableCellWithIdentifier:@"InstagramIdentifier"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            
            NSMutableURLRequest *imgRequestP = [NSMutableURLRequest requestWithURL:timeLine.profileImageUrl];
            [imgRequestP addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            [imgRequestP setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
            __weak typeof(cell.profileImageView) weakImageP = cell.profileImageView;
            [cell.profileImageView setImageWithURLRequest:imgRequestP
                                         placeholderImage:[UIImage imageNamed:@"profil-default-pf-pic"]
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                                      weakImageP.image = image;
                                                  } failure:nil];
            cell.nameLabel.text = timeLine.userName;
            cell.dateLabel.text = [Utils timeStringBetweenDates:timeLine.createDate:[NSDate date]];
            
            NSMutableURLRequest *imgRequest = [NSMutableURLRequest requestWithURL:timeLine.imageUrl];
            [imgRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            [imgRequest setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
            __weak typeof(cell.cellImageView) weakImageV = cell.cellImageView;
            [cell.cellImageView setImageWithURLRequest:imgRequest
                                      placeholderImage:[UIImage imageNamed:@"noimage"]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                                   weakImageV.image = image;
                                               } failure:nil];
            
            [cell.imageView setImageWithURLRequest:imgRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakImageV.image = image;
            } failure:nil downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                cell.circularIndicator.value = (float)totalBytesRead / totalBytesExpectedToRead;
            }];
            cell.like.text = timeLine.likes;
            
            if ([timeLine.commentsCount integerValue] != 0)
                cell.commentsCount.text = [NSString stringWithFormat:@"%@ %@",timeLine.commentsCount, [Utils localizedString:@"ITComment"]];
            else{
                cell.verticalHeight.constant = 0;
                cell.commentsCount.text = @"";
            }
            
            if ([timeLine.commentsArray count] == 0)
                cell.commentHeight.constant = 0;
            else{
                NSString *str = @"";
                for (int i=0; i<[timeLine.commentsArray count]; i++) {
                    str = [NSString stringWithFormat:@"\a%@ %@\n%@",[[[timeLine commentsArray] objectAtIndex:i] objectForKey:@"username"],[[[timeLine commentsArray] objectAtIndex:i] objectForKey:@"text"],str];
                }
                cell.comment.text = str;
                cell.commentHeight.constant = [self getHeight:str withXposition:16];
            }
            
            if (indexPath.row + 1 == [[dataArray objectAtIndex:tag] count])
                [cell.indicator startAnimating];
            
            return cell;
        }
    }
    else {
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        SettingCell *cell = (SettingCell *)[_tableView dequeueReusableCellWithIdentifier:@"ErrorIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.label.text = timeLine.errorMessage;
        return cell;
    }
    return nil;
}

- (NSString *)timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    timeLine = [[dataArray objectAtIndex:tag] objectAtIndex:indexPath.row];
    if (![Utils stringIsEmpty:timeLine.errorMessage])
        return 16 + [self getHeight:timeLine.errorMessage withXposition:16];
    else if (tag == 1) {
        return 65 + [self getHeight:timeLine.text withXposition:59] + (timeLine.retweet == TRUE ? 38 : 0) + (indexPath.row+1 == [[dataArray objectAtIndex:tag] count] && ![Utils stringIsEmpty:nextPage] ? 50 : 0);
    }
    else if (tag == 2)
        return 600;
    else if (tag == 3) {
        NSString *strC = @"";
        for (int i=0; i<[timeLine.commentsArray count]; i++) {
            strC = [NSString stringWithFormat:@"\a%@ %@\n%@",[[[timeLine commentsArray] objectAtIndex:i] objectForKey:@"username"],[[[timeLine commentsArray] objectAtIndex:i] objectForKey:@"text"],strC];
        }
        
        return 45 + [Utils screenWidth] + [self getHeight:timeLine.likes withXposition:44]  + ([Utils stringIsEmpty:strC] ? 0 : [self getHeight:strC withXposition:16]) +  [self getHeight:[timeLine.commentsCount integerValue] !=0 ?[NSString stringWithFormat:@"%@ %@",timeLine.commentsCount, [Utils localizedString:@"ITComment"]]:@"" withXposition:16] + ([timeLine.commentsCount integerValue] == 0 ? 0 : 16) + ((!loadFlag && indexPath.row+1 == [[dataArray objectAtIndex:tag] count] && ![Utils stringIsEmpty:nextPage]) ? 50 : 0);
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex) && !loadFlag) {
        if (tag == 1){
            if (![Utils stringIsEmpty:nextPage])
                [self twitterFunction:nextPage withLoadingType:1];
        }
        else if (tag == 3) {
            if (![Utils stringIsEmpty:nextPage])
                [self instagramFunction:nextPage withLoadingType:1];
        }
    }
}

#pragma - mark Functions

- (void)facebookFunction {}

- (void)twitterFunction:(NSString *)page withLoadingType:(int)type {
    User *twUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.twObject];
    timeLine = [TimeLine new];
    
    if ([twUser.userId integerValue] == 0) {
        timeLine.errorMessage = [NSString stringWithFormat:[Utils localizedString:@"ITAttention_Message_11"],@"twitter"];
        [[dataArray objectAtIndex:tag] addObject:timeLine];
        [_tableView reloadData];
        return;
    }
    if (type == 0)
        [LoadingView show];
    
    _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil consumerKey:twitterConsumerKey consumerSecret:twitterConsumerSecretKey oauthToken:twUser.accesstoken oauthTokenSecret:twUser.accesstokensecret];
    [_twitter getStatusesUserTimelineForUserID:nil screenName:twUser.nameSurname sinceID:nil count:@"200" maxID:page trimUser:nil excludeReplies:nil contributorDetails:nil includeRetweets:nil accesstoken:twUser.accesstoken accesstokensecret:twUser.accesstokensecret successBlock:^(NSArray *statuses) {
        for (int i=0; i<[statuses count]; i++) {
            if ([statuses count] != 1)
                nextPage = [NSString stringWithFormat:@"%@",[[statuses objectAtIndex:i] objectForKey:@"id"]];
            else
                nextPage = nil;
            if ([statuses count]!=i+1 || [statuses count] == 1)
                [[dataArray objectAtIndex:tag] addObject:[TimeLine twitterTimeLine:[statuses objectAtIndex:i]]];
        }
        [LoadingView hide];
        [_tableView reloadData];
    } errorBlock:^(NSError *error) {
        [LoadingView hide];
        if (error.code == 0)
            timeLine.errorMessage = [Utils localizedString:@"ITAttention_Message_12"];
        else if (error.code == -1009)
            timeLine.errorMessage = [Utils localizedString:@"ITAttention_Message_1"];
        
        [[dataArray objectAtIndex:tag] addObject:timeLine];
        [_tableView reloadData];
    }];
}

- (void)instagramFunction:(NSString *)page withLoadingType:(int)type {
    loadFlag = true;
    User *insUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.insObject];
    timeLine = [TimeLine new];
    if ([insUser.userId integerValue] == 0 ){
        timeLine.errorMessage = [NSString stringWithFormat:[Utils localizedString:@"ITAttention_Message_11"],@"instagram"];
        [[dataArray objectAtIndex:tag] addObject:timeLine];
        [_tableView reloadData];
        return;
    }
    
    NSString *userId,*usertoken;
    if ([Utils stringIsEmpty:insUser.accesstoken]) {
        userId = [NSString stringWithFormat:@"%@",insUser.userId];
        usertoken = [Session identity].insToken;
    }else{
        userId = @"self";
        usertoken = insUser.accesstoken;
    }
    
    [Utils callApi:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/",userId] params:[NSString stringWithFormat:@"?access_token=%@&&max_id=%@",usertoken,page] integer:0 withType:type success:^(id responseObject) {
        id data = [[Utils jsonWithData:responseObject error:nil] objectForKey:@"data"];
        nextPage = [[[Utils jsonWithData:responseObject error:nil] objectForKey:@"pagination"] objectForKey:@"next_max_id"];
        for (int i=0; i<[data count]; i++) {
            [[dataArray objectAtIndex:tag] addObject:[TimeLine instagramTimeLine:[data objectAtIndex:i]]];
        }
        [_tableView reloadData];
        loadFlag = false;
    } failure:^(NSError *error) {
        [LoadingView hide];
        if (error.code == -1011)
            timeLine.errorMessage = [Utils localizedString:@"ITAttention_Message_12"];
        else if (error.code == -1009)
            timeLine.errorMessage = [Utils localizedString:@"ITAttention_Message_1"];
        
        [[dataArray objectAtIndex:tag] addObject:timeLine];
        [_tableView reloadData];
    }];
}

- (void)foursquareFunction {
    loadFlag = true;
    User *fsToken = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.fsObject];
    timeLine = [TimeLine new];
    if ([fsToken.userId integerValue] == 0 ) {
        timeLine.errorMessage = [NSString stringWithFormat:[Utils localizedString:@"ITAttention_Message_11"],@"foursquare"];
        [[dataArray objectAtIndex:tag] addObject:timeLine];
        [_tableView reloadData];
        return;
    }
    NSDateComponents *comp = [Utils getDateComponents:[NSDate date]];
    if (![Utils stringIsEmpty:fsToken.accesstoken]) {
        [Utils callApi:@"https://api.foursquare.com/v2/users/self/checkins" params:[NSString stringWithFormat:@"?oauth_token=%@&v=%ld%02ld%02ld",fsToken.accesstoken,[comp year],(long)[comp month],(long)[comp day]] integer:0 withType:0 success:^(id responseObject) {
            id data = [[[[Utils jsonWithData:responseObject error:nil] objectForKey:@"response"] objectForKey:@"checkins"] objectForKey:@"items"];
            for (int i=0; i<[data count]; i++) {
            
                [[dataArray objectAtIndex:tag] addObject:[TimeLine foursquareTimeLine:[data objectAtIndex:i]]];
                
                //                if ([[[dataContent objectForKey:@"likes"] objectForKey:@"count"] integerValue]==0)
                //                    return;
                ////                id dataLikes = [[[[dataContent objectForKey:@"likes"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"];
                ////                for (int i=0; i<[dataLikes count]; i++) {
                ////                    NSLog(@"%@ %@",[[dataLikes objectAtIndex:i] objectForKey:@"firstName"],[[dataLikes objectAtIndex:i] objectForKey:@"lastName"]);
                ////                }
                NSLog(@"***********************************************************************");
            }
            loadFlag = false;
            [_tableView reloadData];
        } failure:^(NSError *error) {
            [LoadingView hide];
            if (error.code == -1011)
                timeLine.errorMessage = [Utils localizedString:@"ITAttention_Message_12"];
            else if (error.code == -1009)
                timeLine.errorMessage = [Utils localizedString:@"ITAttention_Message_1"];
            
            [[dataArray objectAtIndex:tag] addObject:timeLine];
            [_tableView reloadData];
        }];
    }else{
        
        
        //twitter
        
        
        
    }
}

- (float)getHeight:(NSString *)str withXposition:(int)value{
    CGSize maximumLabelSize = CGSizeMake([Utils screenWidth]-value,9999);
    CGRect textRect = [str boundingRectWithSize:maximumLabelSize
                                        options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Verdana" size:15]}
                                        context:nil];
    return textRect.size.height;
}

- (IBAction)buttonFunctions:(UIButton *)sender {
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
    [[dataArray objectAtIndex:tag] removeAllObjects];
    
    if (tag == 0)
        [self facebookFunction];
    else if (tag == 1){
        if ([Utils stringIsEmpty:[Session identity].twToken] && [Utils stringIsEmpty:[Session identity].twSecret]) {
            [LoadingView show];
            _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:twitterConsumerKey
                                                     consumerSecret:twitterConsumerSecretKey];
            
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
        }else
            [self twitterFunction:nil withLoadingType:0];
    }
    else if (tag == 2)
        [self foursquareFunction];
    else if (tag == 3){
        if ([Utils stringIsEmpty:[Session identity].insToken]) {
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            appDelegate.instagram.sessionDelegate = self;
            [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"basic",@"comments", @"likes", nil]];
        }else
            [self instagramFunction:@"" withLoadingType:0];
    }
    
}

- (void)loadUserFunction:(NSNotification *)notice {
    [[dataArray objectAtIndex:tag] removeAllObjects];
    item = [notice.object objectForKey:@"userObject"];
    _titleLabel.text = item.nameSurname;
    if (tag == 0)
        [self facebookFunction];
    else if (tag == 1){
        if ([Utils stringIsEmpty:[Session identity].twToken] && [Utils stringIsEmpty:[Session identity].twSecret]) {
            [LoadingView show];
            _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:twitterConsumerKey
                                                     consumerSecret:twitterConsumerSecretKey];
            
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
        }else
            [self twitterFunction:nil withLoadingType:0];
    }
    else if (tag == 2)
        [self foursquareFunction];
    else if (tag == 3) {
        if ([Utils stringIsEmpty:[Session identity].insToken]) {
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            appDelegate.instagram.sessionDelegate = self;
            [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"basic",@"comments", @"likes", nil]];
        }else
            [self instagramFunction:@"" withLoadingType:0];
    }
    
}

- (IBAction)leftMenuFunction:(id)sender {
    [[SlideNavigationController sharedInstance] openMenu:MenuLeft withCompletion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableVC" object:nil];
    }];
}

- (IBAction)rightMenuFunction:(id)sender {
    [[SlideNavigationController sharedInstance] openMenu:MenuRight withCompletion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableVC" object:nil];
    }];
}

- (void)showAlertView:(NSString *)title withMessage:(NSString *)message withTag:(int)alertTag{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[Utils localizedString:title] message:[Utils localizedString:message] delegate:self cancelButtonTitle:[Utils localizedString:@"ITOk"] otherButtonTitles:nil];
    alert.tag = alertTag;
    [alert show];
}

- (void)updateToken:(id)params {
    [Utils callPostApi:updatetoken params:params integer:0 withType:0 progress:nil success:^(id responseObject) {
        if (tag == 1)
            [self twitterFunction:nil withLoadingType:0];
        else if (tag == 3)
            [self instagramFunction:@"" withLoadingType:0];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)getWebView:(NSURL *)url {
    WebViewVC *webViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewVC"];
    [webViewVC setUrl:url];
    [self presentViewController:webViewVC animated:YES completion:nil];
}

- (void)tappedLink:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[link substringToIndex:1] isEqualToString:@"@"]){
        link = [link substringFromIndex:1];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",[link urlEncodeUsingEncoding:NSUTF8StringEncoding]]]];
    }
    else if ([[link substringToIndex:1] isEqualToString:@"#"]){
        link = [link substringFromIndex:1];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://search?query=%@",[link urlEncodeUsingEncoding:NSUTF8StringEncoding]]]];
    }
    else {
        if (![link containsString:@"http"])
            link = [NSString stringWithFormat:@"http//%@",link];
        [self getWebView:[NSURL URLWithString:link]];
    }
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
        } errorBlock:^(NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
        }];
    }];
    
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end