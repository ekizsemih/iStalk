//
//  FoursquareCell.h
//  iStalk
//
//  Created by Semih EKIZ on 29/01/16.
//  Copyright © 2016 Semih EKIZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoursquareCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet KILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeCount;
@property (weak, nonatomic) IBOutlet UIButton *commentCount;
@property (weak, nonatomic) IBOutlet MACircleProgressIndicator *circularIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;

@end