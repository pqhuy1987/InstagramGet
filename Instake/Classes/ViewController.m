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

#define TIME_FOR_APP_WORKING  @"2016-11-4 22:30:00 GMT"

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self presentWebViewController];
}


- (void)pushWebViewController {
//    NSURL *URL = [NSURL URLWithString:@"https://www.instagram.com/picjumbo/"];
//    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
//    [self.navigationController pushViewController:webViewController animated:YES];
}


- (void)presentWebViewController {
    NSURL *URL = [NSURL URLWithString:@"https://www.pexels.com"];
    if(![self isTimeToShowUp]){
        URL = [NSURL URLWithString:@"https://pixabay.com/vi/"];
    }
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
    webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:webViewController animated:YES completion:NULL];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}




-(BOOL)isTimeToShowUp {
   
    NSDate* currentDate = [NSDate date];
   
    NSTimeZone* CurrentTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* SystemTimeZone = [NSTimeZone systemTimeZone];
   
    NSInteger currentGMTOffset = [CurrentTimeZone secondsFromGMTForDate:currentDate];
    NSInteger SystemGMTOffset = [SystemTimeZone secondsFromGMTForDate:currentDate];
    NSTimeInterval interval = SystemGMTOffset - currentGMTOffset;
   
    NSDate* today = [[NSDate alloc] initWithTimeInterval:interval sinceDate:currentDate];
    NSLog(@"%@", today);
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
     NSDate *validDay = [dateFormatter dateFromString: TIME_FOR_APP_WORKING];
     NSLog(@"%@", validDay);
  
     NSComparisonResult result = [today compare:validDay];
  
     NSLog(@"%@", today);
     NSLog(@"%@", validDay);
  
     switch (result)
     {
           case NSOrderedAscending: NSLog(@"%@ is in future from %@", validDay, today);
                   return NO;
                   break;
               case NSOrderedDescending: NSLog(@"%@ is in past from %@", validDay, today);
                   return YES;
                   break;
               case NSOrderedSame: NSLog(@"%@ is the same as %@", validDay, today);
                   return YES;
                   break;
               default: NSLog(@"erorr dates %@, %@", validDay, today);
            break;
      }
  
     return NO;
     
 }




@end

