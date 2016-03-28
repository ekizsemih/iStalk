//
//  TweetCell.h
//  iStalk
//
//  Created by Semih EKIZ on 13/01/16.
//  Copyright © 2016 Semih EKIZ. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "KILabel.h"

@interface TweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *retweet;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *namesurname;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet KILabel *text;
@property (weak, nonatomic) IBOutlet UIButton *retweetCount;
@property (weak, nonatomic) IBOutlet UIButton *favCount;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetHeight;
@end