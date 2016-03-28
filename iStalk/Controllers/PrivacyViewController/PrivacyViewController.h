//
//  PrivacyViewController.h
//  iStalk
//
//  Created by Semih EKIZ on 10/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacyViewController :UIViewController<UIWebViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (IBAction)buttonFunctions:(id)sender;
@end