//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder{
    self.slideOutAnimationEnabled = YES;
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadTableVC" object:nil];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableView Delegate & Datasrouce

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ProfileCell *cell = (ProfileCell *)[_tableView dequeueReusableCellWithIdentifier:@"ProfileIdentifier"];
    
    if ([Session identity].imageData)
        cell.profileImageView.image = [UIImage imageWithData:[Session identity].imageData];
    else{
        NSMutableURLRequest *imgRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[Session identity].imagePath]];
        [imgRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        [imgRequest setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
        __weak typeof(cell.profileImageView) weakImageV = cell.profileImageView;
        [cell.profileImageView setImageWithURLRequest:imgRequest
                                     placeholderImage:[UIImage imageNamed:@"profil-default-pf-pic"]
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                                  weakImageV.contentMode = UIViewContentModeScaleToFill;
                                                  weakImageV.image = image;
                                              } failure:nil];
    }
    cell.nameSurnameLabel.text = [Session identity].username;
    
    UITapGestureRecognizer *singleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileFunction:)];
    [singleTapRecogniser setDelegate:self];
    singleTapRecogniser.numberOfTouchesRequired = 1;
    singleTapRecogniser.numberOfTapsRequired = 1;
    [cell addGestureRecognizer:singleTapRecogniser];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingCell *cell = (SettingCell *)[_tableView dequeueReusableCellWithIdentifier:@"SettingIdentifier"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.image.image = [UIImage imageNamed:[NSString stringWithFormat:@"setting_%ld",indexPath.row]];
    cell.label.text = [Utils localizedString:[NSString stringWithFormat:@"ITSettingTitle_%ld",(long)indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *vc ;
    
    switch (indexPath.row)
    {
        case 0:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"maincontroller"];
            break;
            
        case 1:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"searchController"];
            break;
            
        case 2:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FriendsViewController"];
            break;
            
        case 3:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[Utils localizedString:@"ITSure"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utils localizedString:@"ITDismiss"]
                                                  otherButtonTitles:[Utils localizedString:@"ITOk"],nil];
            alert.tag = 1;
            [alert show];
        }
            break;
    }
    if (indexPath.row != 3)
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                         andCompletion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 97;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

#pragma mark - Functions

- (void)reloadTable{
    [_tableView reloadData];
}

- (void)profileFunction:(UIGestureRecognizer *)sender{
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"profileEditController"]
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
            id params = @{
                          @"userid":[Session identity].userid,
                          @"servicetoken":servicetoken,
                          @"apptoken":[Session identity].userToken
                          };
            [Utils callPostApi:logout params:params integer:0 withType:0 progress:nil success:^(id responseObject) {
                id data = [Utils jsonWithData:responseObject error:nil];
                if ([[data objectForKey:@"returnCode"] boolValue])
                    [Session signOut];
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
            
        }];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
