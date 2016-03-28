//
//  WebViewVC.m
//  STTwitterDemoIOS
//
//  Created by Nicolas Seriot on 06/08/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "WebViewVC.h"

@interface WebViewVC ()

@end

@implementation WebViewVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *request  = [NSURLRequest requestWithURL:_url];
    [_webView loadRequest:request];
    _titleLabel.text = [self getTitle:_url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)bottomFunctions:(UIButton *)sender {
    if (sender.tag == 0)
        [_webView goBack];
    else if (sender.tag == 1)
        [_webView stopLoading];
    else if (sender.tag == 2)
        [_webView reload];
    else if (sender.tag == 3)
        [_webView goForward];
}

- (void)updateButtons {
    _rightButton.userInteractionEnabled = self.webView.canGoForward;
    _leftButton.userInteractionEnabled = self.webView.canGoBack;
    _closeButton.userInteractionEnabled = self.webView.loading;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

- (NSString *)getTitle:(NSURL *)link{
    NSArray *listItems = [[NSString stringWithFormat:@"%@",_url] componentsSeparatedByString:@"/"];
    NSString *str = [NSString stringWithFormat:@"%@//%@",[listItems objectAtIndex:0],[listItems objectAtIndex:2]];
    return str;
}

@end