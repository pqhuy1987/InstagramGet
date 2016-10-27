//
//  RootViewController.m
//  SVWebViewController
//
//  Created by Sam Vermette on 21.02.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "ViewController.h"
#import "SVWebViewController.h"
#import "SVModalWebViewController.h"

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self pushWebViewController];
}


- (void)pushWebViewController {
    NSURL *URL = [NSURL URLWithString:@"https://www.instagram.com/picjumbo/"];
	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
	[self.navigationController pushViewController:webViewController animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


@end

