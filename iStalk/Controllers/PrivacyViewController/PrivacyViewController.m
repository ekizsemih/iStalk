//
//  PrivacyViewController.m
//  iStalk
//
//  Created by Semih EKIZ on 10/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "PrivacyViewController.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [_webView setBackgroundColor:[UIColor clearColor]];
    [_webView setOpaque:NO];
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://semihekiz.co/local/istalk/privacy_%@.html",[Utils localizedString:@"ITLanguage"]]]];
    [self.webView setDelegate:self];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
}

- (IBAction)buttonFunctions:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"privacyVC" object:sender];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end