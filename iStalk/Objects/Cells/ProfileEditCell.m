//
//  ProfileEditCell.m
//  iStalk
//
//  Created by Semih EKIZ on 14/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "ProfileEditCell.h"

@implementation ProfileEditCell

- (void)awakeFromNib {
    _profileImageButton.layer.cornerRadius = _profileImageButton.frame.size.width / 2;
    _profileImageButton.layer.borderWidth = 1.0f;
    _profileImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _profileImageButton.layer.masksToBounds = NO;
    _profileImageButton.clipsToBounds = YES;
    
    [_textField3 setKeyboardType:UIKeyboardTypeEmailAddress];
    
    [_textField1 setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_textField2 setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_textField3 setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
