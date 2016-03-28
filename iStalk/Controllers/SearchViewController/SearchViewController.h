//
//  SearchViewController.h
//  iStalk
//
//  Created by Semih EKIZ on 14/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate ,UITableViewDelegate, UITableViewDataSource, IGSessionDelegate, IGRequestDelegate, STTwitterAPIOSProtocol>{
    NSMutableArray *dataArray;
}
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (nonatomic, strong) STTwitterAPI *twitter;

- (IBAction)socialFunction:(id)sender;
- (IBAction)searchFunction:(id)sender;
- (IBAction)followFunction:(id)sender;
- (IBAction)goProfile:(id)sender;
- (IBAction)addPerson:(id)sender;
- (void)handleURL:(NSURL *)url;
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;
@end