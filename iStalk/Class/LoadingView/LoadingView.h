//
//  LoadingView.h
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface LoadingView : UIView

+ (void) show;
+ (void) hide;
+ (void) hide: (NSTimeInterval) delay;

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end
