//
//  RightMenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/26/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "RightMenuViewController.h"

extern NSManagedObjectContext* getDBCtx();

@implementation RightMenuViewController {
    NSArray *arryData;
}

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder{
    self.slideOutAnimationEnabled = YES;
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    searchArray = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadTableVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide) name:@"keyboardHideVC" object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    
    [self.view addGestureRecognizer:tap];
    self.definesPresentationContext = YES;
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.delegate = self;
    [_searchController.searchBar sizeToFit];
    [_searchController.searchBar setBarTintColor:COLOR_RGB(57, 148, 160)];
    _tableView.tableHeaderView = _searchController.searchBar;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _searchController.searchBar.layer.borderColor = COLOR_RGB(57, 148, 160).CGColor;
    _searchController.searchBar.layer.borderWidth = 1;
    
    [self reloadTable];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if ([Utils stringIsEmpty:_searchController.searchBar.text]) {
        searchArray = [arryData mutableCopy];
    }else{
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"nameSurname contains[c] %@",[searchController.searchBar.text uppercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"tr_TR"]]];
        searchArray = [[arryData filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    }
    [self.tableView reloadData];
}

#pragma - mark UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.active)
        return [searchArray count];
    else
        return [arryData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DataEntity *item;
    if (_searchController.active)
        item = [searchArray objectAtIndex:indexPath.row];
    else
        item = [arryData objectAtIndex:indexPath.row];
    
    User *fbUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.fbObject];
    User *twUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.twObject];
    User *fsUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.fsObject];
    User *insUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.insObject];
    
    NSString *str;
    if (![Utils stringIsEmpty:fbUser.imageUrl])
        str = fbUser.imageUrl;
    else if (![Utils stringIsEmpty:twUser.imageUrl])
        str = twUser.imageUrl;
    else if (![Utils stringIsEmpty:fsUser.imageUrl])
        str = fsUser.imageUrl;
    else if (![Utils stringIsEmpty:insUser.imageUrl])
        str = insUser.imageUrl;
    
    ProfileCell *cell = (ProfileCell *)[_tableView dequeueReusableCellWithIdentifier:@"ProfileIdentifier"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.row;
    
    NSMutableURLRequest *imgRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str]];
    [imgRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [imgRequest setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
    __weak typeof(cell.profileImageView) weakImageV = cell.profileImageView;
    [cell.profileImageView setImageWithURLRequest:imgRequest
                                 placeholderImage:[UIImage imageNamed:@"profil-default-pf-pic"]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                              weakImageV.image = image;
                                          } failure:nil];
    
    cell.nameSurnameLabel.text = item.nameSurname;
    [cell.fbButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"find_%d",[fbUser.userId integerValue] == 0 ? 0:1]] forState:UIControlStateNormal];
    [cell.twButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"find_%d",[twUser.userId integerValue] == 0 ? 0:1]] forState:UIControlStateNormal];
    [cell.fsButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"find_%d",[fsUser.userId integerValue] == 0 ? 0:1]] forState:UIControlStateNormal];
    [cell.insButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"find_%d",[insUser.userId integerValue] == 0 ? 0:1]] forState:UIControlStateNormal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DataEntity *item;
    if (_searchController.active)
        item = [searchArray objectAtIndex:indexPath.row];
    else
        item = [arryData objectAtIndex:indexPath.row];
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
        id data = @{
                    @"userObject":item
                    };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadUserVC" object:data];
    }];
}

#pragma - mark UIGesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:_tableView])
        return NO;
    return YES;
}

#pragma - mark Functions

- (void)keyboardHide {
    [_searchController.searchBar resignFirstResponder];
    [_searchController setActive:NO];
}

- (void)reloadTable {
    self.context = getDBCtx();
    NSManagedObjectContext *ctx = _context;
    NSFetchRequest *fetchReq  = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"DataEntity" inManagedObjectContext:ctx];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId contains[c] %@",[Session identity].userid];
    [fetchReq setEntity:entityDesc];
    [fetchReq setPredicate:predicate];
    arryData = [ctx executeFetchRequest:fetchReq error:nil];
    [_tableView reloadData];
}

- (IBAction)buttonFunctions:(UIButton *)sender {
    ProfileCell *cell = (ProfileCell *)[[sender superview] superview];
    DataEntity *item = [arryData objectAtIndex:cell.tag];
    User *fbUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.fbObject];
    User *twUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.twObject];
    User *fsUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.fsObject];
    User *insUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:item.insObject];
    
    id data = @{
                @"nameSurname":item.nameSurname,
                @"button":sender,
                @"userid":item.iD
                };
    
    if (sender.tag == 0)
        [Utils stringIsEmpty:fbUser.profileUrl] ? [self openSearch:data]:[[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbUser.profileUrl]];
    else if (sender.tag == 1)
        [Utils stringIsEmpty:twUser.profileUrl] ? [self openSearch:data]:[[UIApplication sharedApplication] openURL:[NSURL URLWithString:twUser.profileUrl]];
    else if (sender.tag == 2)
        [Utils stringIsEmpty:fsUser.profileUrl] ? [self openSearch:data]:[[UIApplication sharedApplication] openURL:[NSURL URLWithString:fsUser.profileUrl]];
    else if (sender.tag == 3)
        [Utils stringIsEmpty:insUser.profileUrl] ? [self openSearch:data]:[[UIApplication sharedApplication] openURL:[NSURL URLWithString:insUser.profileUrl]];
}

- (void)openSearch:(id)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"searchController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:^{
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDataVC" object:sender];
                                                                     }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end