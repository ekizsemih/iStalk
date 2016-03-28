//
//  LoadingView.m
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView {
    BOOL mLoading;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    @throw [NSException exceptionWithName:@"CLNotSuportedException"
                                   reason:@"CLLoadingView fullscreen calisir, izin verilenin disinda initilize edilemez"
                                 userInfo: nil];
}

- (id)initWithFrame:(CGRect)frame {
    @throw [NSException exceptionWithName:@"CLNotSuportedException"
                                   reason:@"CLLoadingView fullscreen calisir, izin verilenin disinda initilize edilemez"
                                 userInfo: nil];
}

- (id)init {
    @throw [NSException exceptionWithName:@"CLNotSuportedException"
                                   reason:@"CLLoadingView fullscreen calisir, izin verilenin disinda initilize edilemez"
                                 userInfo: nil];
}

- (id) initALoadingView {
    self = [super initWithFrame:  [[UIScreen mainScreen] bounds]];
    if (self) {
        [self initialize];
    }
    return self;
}

+ (instancetype) _sharedInstance {
    static LoadingView *  _appDefaultModalLoadingView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _appDefaultModalLoadingView =  [[LoadingView alloc] initALoadingView];
    });
    return _appDefaultModalLoadingView;
}

- (void) initialize {
    if (self.subviews.count == 0) {
        self.backgroundColor = [UIColor clearColor];
        
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle: [NSBundle mainBundle]];
        UIView *view = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        view.frame = self.bounds;
        [self addSubview:view];
    }
}

+ (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        LoadingView *loadingView = [LoadingView _sharedInstance];
        if (loadingView->mLoading) {
            [[loadingView superview] bringSubviewToFront: loadingView];
        }
        
        
        UIView *view = [loadingView.subviews objectAtIndex: 0];
        loadingView.backgroundColor = COLOR_RGBA(0, 0, 0, 0.0);
        view.transform = CGAffineTransformMakeScale(0, 0);
        
        
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        
        SlideNavigationController *navigationController = (SlideNavigationController *)[keyWindow rootViewController];
        
        UIViewController *rootViewController = [[navigationController viewControllers] lastObject];
        [[rootViewController view] addSubview: loadingView];
        [UIView animateWithDuration: 0.25 animations:^{
            loadingView.alpha = 1.0;
            loadingView.transform = CGAffineTransformIdentity;
            view.transform = CGAffineTransformMakeScale(1, 1);
            loadingView.backgroundColor = COLOR_RGBA(0, 0, 0, 0.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration: 0.3 animations:^{
                view.transform = CGAffineTransformMakeScale(0.8, 0.8);
            }];
            
            [UIView animateWithDuration:0.5 animations:^{
                loadingView.contentView.alpha = 1.0;
            }];
        }];
    });
}

+ (void) hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        LoadingView *loadingView = [LoadingView _sharedInstance];
        UIView *indicatorView = [loadingView.subviews objectAtIndex: 0];
        
        [UIView animateWithDuration: 0.3 animations:^{
            //    loadingView.transform = CGAffineTransformMakeScale(10, 10);
            loadingView.alpha = 0;
            indicatorView.transform = CGAffineTransformMakeScale(0, 0);
        } completion:^(BOOL finished) {
            loadingView->mLoading = NO;
            //  [self removeFromSuperview];
        }];
    });
}

+ (void)hide:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [LoadingView hide];
    });
}

- (void)dealloc {
}

@end