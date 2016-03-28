//
//  InstagramCell.m
//  iStalk
//
//  Created by Semih EKIZ on 06/01/16.
//  Copyright © 2016 Semih EKIZ. All rights reserved.
//

#import "InstagramCell.h"

@implementation InstagramCell

- (void)awakeFromNib {
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width / 2;
    _profileImageView.layer.borderWidth = 1.0f;
    _profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _profileImageView.layer.masksToBounds = NO;
    _profileImageView.clipsToBounds = YES;
    _profileImageView.userInteractionEnabled = YES;
    [_like sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
