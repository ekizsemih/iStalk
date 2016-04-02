//
//  InstagramCell.h
//  iStalk
//
//  Created by Semih EKIZ on 06/01/16.
//  Copyright © 2016 Semih EKIZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KILabel/KILabel.h>
#import "MACircleProgressIndicator.h"

@interface InstagramCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *like;
@property (weak, nonatomic) IBOutlet UILabel *commentsCount;
@property (weak, nonatomic) IBOutlet KILabel *comment;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet MACircleProgressIndicator *circularIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentHeight;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@end