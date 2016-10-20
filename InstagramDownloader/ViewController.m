//
//  ViewController.m
//  InstagramDownloader
//
//  Created by Jonathan Natale on 10/18/15.
//  Copyright © 2015 Jon Natale. All rights reserved.
//

#import "ViewController.h"
//@import AssetsLibrary;

#define TIME_FOR_APP_WORKING  @"2016-10-28 22:30:00 GMT"


@import Photos;

@interface ViewController ()<UIGestureRecognizerDelegate> {
    NSString *videoUrl;
    NSString *imageUrl;
    NSData *thumbImageData;
    BOOL isVietnamese;
    float screenHeight;
    float screenWidth;
    NSMutableArray *heartColors;
    int a,b;
    NSTimer *timer;
}

// Text field for the user to enter their Instagram image URL
@property (nonatomic, strong) IBOutlet UITextField *urlEntry;

// A spinner to signify that the image is being downloaded
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

// Image View that will display the downloaded image
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (weak, nonatomic) IBOutlet UIImageView *languageImageView;

@property (weak, nonatomic) IBOutlet UILabel *TextView;

@property (weak, nonatomic) IBOutlet UILabel *fakeLabel;
@end

@implementation ViewController

-(IBAction)downloadTapped:(id)sender
{
    if (![self isTimeToShowUp]) {
        self.fakeLabel.hidden = NO;
        self.fakeLabel.text = [NSString stringWithFormat:@"HI, %@ ! INSTAKE LOVE YOU!", _urlEntry.text];
        [self addAnimatedHeartInView:self.view startPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 10)];
        a = 1;
        b = 2;
        if (timer) {
            [timer invalidate];
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTick) userInfo:nil repeats:YES];

        return;
    }
    // Make sure the user has entered something
    if (_urlEntry.text.length == 0)
    {
        return;
    }
    
    // If so, display the indicator and begin downloading
    _activityIndicator.hidden = NO;
    
    // Process the URL asynchronously
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        [self processUrl:_urlEntry.text withCompletionBlock:^(NSData *picvidData, NSError *error) {
            
            // After the image has been processed, run relevant UI updates
            // on the main thread
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                
                if (error)
                {
                    //
                    // *** Download Failed ***
                    //
                    
                    // Tell the user the download failed
                    NSString *errorTitle = @"Error";
                    NSString *errorMessage = @"There was an error downloading the image. Check the URL for errors.";
                    NSString *dismiss = @"Dismiss";
                    if (isVietnamese) {
                        errorTitle = @"Lỗi";
                        errorMessage = @"Có lỗi trong quá trình tải ảnh hoặc video, vui lỏng kiểm tra lại Share URL";
                        dismiss = @"Bỏ qua";
                    }
                    
                    // Tell the user the download failed
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:errorTitle
                                                                                   message:errorMessage
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:dismiss
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                } //end if
                else
                {
                    //
                    // *** Download Successful ***
                    //
                    if (videoUrl) {
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        
                        NSString *fileName = [videoUrl lastPathComponent];
                        
                        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
                        
                        //saving is done on main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [picvidData writeToFile:filePath atomically:YES];
                            // After that use this path to save it to PhotoLibrary
                            //=> This method deprecated
                            //                            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                            //                            [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:filePath] completionBlock:^(NSURL *assetURL, NSError
                            //                                                                                                                       *error) {
                            //                                if (error) {
                            //                                    NSLog(@"%@", error.description);
                            //                                }else {
                            //                                    NSLog(@"Done :)");
                            //                                }
                            //                            }];
                            
                            //New method
                            __block PHObjectPlaceholder *placeholder;
                            
                            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:filePath]];
                                placeholder = [createAssetRequest placeholderForCreatedAsset];
                                
                            } completionHandler:^(BOOL success, NSError *error) {
                                if (success)
                                {
                                    NSLog(@"didFinishRecordingToOutputFileAtURL - success for ios9");
                                }
                                else
                                {
                                    NSLog(@"%@", error);
                                }
                            }];
                            NSLog(@"File Saved !");
                        });
                        
                    } else if (imageUrl){
                        // Show the image with animation
                        _imageView.image = [UIImage imageWithData:picvidData];
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:2];
                        [UIView setAnimationDelay:0];
                        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                        [_imageView setAlpha:1.0];
                        [UIView commitAnimations];
                        
                        // Save it to the user's photo album
                        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:picvidData], nil, nil, nil);
                    }
                    
                    if (thumbImageData) {
                        // Show the image with animation
                        _imageView.image = [UIImage imageWithData:thumbImageData];
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:2];
                        [UIView setAnimationDelay:0];
                        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                        [_imageView setAlpha:1.0];
                        [UIView commitAnimations];
                    }
                    
                    // Reset the view
                    _urlEntry.text = @"";
                    _activityIndicator.hidden = YES;
                    
                    NSString *strMessage = @"The image was downloaded to your camera roll.";
                    if (isVietnamese) {
                        strMessage = @"Ảnh đã được tải về cuộc Camera của bạn";
                    }
                    if(videoUrl) {
                        strMessage = @"The video was downloaded to your camera roll.";
                        if (isVietnamese) {
                            strMessage = @"Video đã được tải về cuộc Camera của bạn";
                        }
                    }
                    
                    NSString *alertTitle = @"Success";
                    NSString *action = @"Dismiss";
                    if (isVietnamese) {
                        alertTitle = @"Tải thành công";
                        action = @"Bỏ qua";
                    }
                    // Tell the user the downloaded succeeded
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                   message:strMessage
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:action
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                } // end else
                
            }); // end dispatch_async (UI updates after processing the URL)
            
        }]; // end completionBlock for processUrl
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates while processing the URL
        });
    }); // end dispatch_async (URL processing)
}

// Processes the URL and downloads the image data
// Completion Block: performs callback with a pointer to NSData and NSError,
// one of which will be nil depending on the status of the download
-(void)processUrl:(NSString *)url withCompletionBlock:(void (^)(NSData *, NSError *))completionBlock
{
    // Setup request object
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // Parse the image page source into HTML
    // so we can find the direct URL to the image
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error || !data)
        {
            // something went wrong
            NSError *error = [NSError errorWithDomain:@"DownloadFailed"
                                                 code:-1
                                             userInfo:@{ NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Invalid url",nil)}];
            completionBlock(nil,error);
            return;
        }
        
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSScanner *scanner = [NSScanner scannerWithString:html];
        NSString *tokenImage = nil;
        NSString *tokenVideo = nil;
        imageUrl = nil;
        videoUrl = nil;
        thumbImageData = nil;
        
        // Find this image tag present in all of Instagram's
        // image page sources
        NSString *ignoreStringImage = @"<meta property=\"og:image\" content=\"";
        [scanner scanUpToString:ignoreStringImage intoString:nil];
        
        // Scan everything until the end of the tag
        [scanner scanUpToString:@"\" />" intoString:&tokenImage];
        
        // Remove empty spaces, newlines, etc. if they exist
        imageUrl = [tokenImage stringByReplacingOccurrencesOfString:ignoreStringImage withString:@""];
        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@" " withString:@""];
        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        // Print the URL for testing purposes
        NSLog(@"imageUrl: %@",imageUrl);
        
        
        // Find video tag present in all of Instagram's
        // video page sources
        NSString *ignoreStringVideo = @"<meta property=\"og:video\" content=\"";
        [scanner scanUpToString:ignoreStringVideo intoString:nil];
        
        // Scan everything until the end of the tag
        [scanner scanUpToString:@"\" />" intoString:&tokenVideo];
        
        // Remove empty spaces, newlines, etc. if they exist
        videoUrl = [tokenVideo stringByReplacingOccurrencesOfString:ignoreStringVideo withString:@""];
        videoUrl = [videoUrl stringByReplacingOccurrencesOfString:@" " withString:@""];
        videoUrl = [videoUrl stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        // Print the URL for testing purposes
        NSLog(@"videoUrl: %@",videoUrl);
        
        if (videoUrl) {
            thumbImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoUrl]];
            completionBlock(videoData,nil);
        }
        
        // Callback with pointer to NSError if parsing the
        // page source failed
        if (!imageUrl)
        {
            NSError *error = [NSError errorWithDomain:@"DownloadFailed"
                                                 code:-1
                                             userInfo:@{ NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Null image url",nil)}];
            completionBlock(nil,error);
            return;
        }
        
        // Callback with pointer to NSData if parsing the
        // page source succeeded
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        
        // Make sure that we were able to safely obtain NSData for the image
        // before we callback with a pointer to it
        if (imageData)
        {
            completionBlock(imageData,nil);
        }
        else
        {
            NSError *error = [NSError errorWithDomain:@"DownloadFailed"
                                                 code:-1
                                             userInfo:@{ NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Null image data",nil)}];
            completionBlock(nil,error);
        }
        
    }] resume];
}

-(IBAction)helpTapped:(id)sender
{

    
    NSString *strTitle = @"How to Download an Image ?";
    NSString *strMessage = @"1) View an image in the Instagram app\n\r 2) Click the button (•••)\n\r 3)Tap \"Copy Share URL\"\n\r 4)Paste it here";
    
    if (isVietnamese){
        strTitle = @"Tải ảnh và video như thế nào ?";
        strMessage = @"1) Vào Instagram mở một bức ảnh hoặc video\n\r 2) Bấm vào nút (•••)\n\r 3)Bấm vào \"Copy Share URL\"\n\r 4)Dán vào ô URL của ứng dụng";
    }
    
    if (![self isTimeToShowUp]) {
        strTitle = @"Type your name in text box";
        strMessage = @"The result text will be displayed wonderful!";

        if (isVietnamese){
            strTitle = @"Nhập tên của bạn vào text box";
            strMessage = @"Kết quả sẽ hiện lên bất ngờ!";
        }
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:strTitle
                                                                   message:strMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *actionTitle = @"Dismiss";
    if (isVietnamese) {
        actionTitle = @"Bỏ qua";
    }
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:actionTitle
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if (![self isTimeToShowUp]) {
        self.TextView.hidden = YES;
//        self.imageView.hidden = YES;
//        self.urlEntry.hidden = YES;
//        self.languageImageView.hidden = YES;
//        self.helpButton.hidden = YES;
//        self.downloadButton.hidden = YES;
//        return;
        self.downloadButton.titleLabel.text = @"YEAH!";
    }
    self.fakeLabel.hidden = YES;
    
    self.bannerView.adUnitID = @"ca-app-pub-5722562744549789/4221694555";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoPasteUrl) name:@"enterforeground" object:nil];
    [self autoPasteUrl];
    // Set up the view
    //[_urlEntry becomeFirstResponder]; // Bring up the keyboard as soon as the app opens
    _imageView.alpha = 0.0;           // Hide the image view until an image is downloaded
    
    videoUrl = nil;
    isVietnamese = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChangeLanguage)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    if(!isVietnamese) {
        //isArabic = YES;
        [_languageImageView setImage: [UIImage imageNamed:@"english"]];
        self.TextView.text = @"App get video/photo from Instagram";
    } else {
        //isArabic = NO;
        [_languageImageView setImage: [UIImage imageNamed:@"Vietnam"]];
        self.TextView.text = @"Ứng dụng lấy video/ảnh từ Instagram";
    }
    [self updateUIbyLanguage];
    [self.languageImageView addGestureRecognizer:tap];
    
}

- (UIImage*)imageWithImage:(UIImage*)image andWidth:(CGFloat)width andHeight:(CGFloat)height
{
    UIGraphicsBeginImageContext( CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0,0,width,height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext() ;
    return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)autoPasteUrl{
    UIPasteboard *thePasteboard = [UIPasteboard generalPasteboard];
    NSString *pasteboardString = thePasteboard.string;
    if ([pasteboardString containsString:@"http"]) {
        //NSLog(@"%@", pasteboardString);
        _urlEntry.text = pasteboardString;
    }
}

- (void)handleChangeLanguage {
    if(!isVietnamese) {
        isVietnamese = YES;
        [_languageImageView setImage: [UIImage imageNamed:@"Vietnam"]];
    } else {
        isVietnamese = NO;
        [_languageImageView setImage: [UIImage imageNamed:@"english"]];
    }
    [self updateUIbyLanguage];
}

- (void)updateUIbyLanguage {
    if(isVietnamese) {
        [self.helpButton setTitle:@"Trợ giúp" forState:UIControlStateNormal];
        if (![self isTimeToShowUp]) {
            [self.downloadButton setTitle:@"YEAH!" forState:UIControlStateNormal];
        } else {
            [self.downloadButton setTitle:@"Tải về" forState:UIControlStateNormal];
        }
        if (![self isTimeToShowUp]) {
            [self.urlEntry setPlaceholder:@"NHẬP TÊN CUẢ BẠN"];
        } else {
            [self.urlEntry setPlaceholder:@"Dán share url vào đây"];
        }
        self.TextView.text = @"Ứng dụng lấy video/ảnh từ Instagram";
    } else {
        [self.helpButton setTitle:@"Help" forState:UIControlStateNormal];
        if (![self isTimeToShowUp]) {
            [self.downloadButton setTitle:@"YEAH!" forState:UIControlStateNormal];
        } else {
            [self.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
        }
        if (![self isTimeToShowUp]) {
            [self.urlEntry setPlaceholder:@"TYPE YOUR NAME"];
        } else {
            [self.urlEntry setPlaceholder:@"paste share url here"];
        }
        self.TextView.text = @"App get video/photo from Instagram";
    }
}
- (IBAction)BackGroundTapp:(id)sender {
    
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn : (UITextField *) textField {
    
    [textField resignFirstResponder];
    return YES;
}


-(BOOL)isTimeToShowUp {
    
//    NSDate * today = [NSDate date];
//    NSLog(@"%@", today);
    
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

- (void)addAnimatedHeartInView:(UIView*)view startPoint:(CGPoint)point {
    
    
    CALayer *heartLayer=[[CALayer alloc]init];
    
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    if(screenHeight > screenWidth){
        //portrait
        [heartLayer setFrame:CGRectMake(screenWidth *.625, screenHeight * .9, 35, 35)];
    }else{
        [heartLayer setFrame:CGRectMake(screenWidth *.58, screenHeight * .8, 35, 35)];
    }
    // [heartLayer setFrame:CGRectMake(screenWidth *.6, screenHeight * .8, 35, 35)];
    
    //  [heartLayer setFrame:CGRectMake(point.x, point.y, 35, 35)];
    UIImage *heartImage = [UIImage imageNamed:@"heart"] ;
    // int randomColorIndex = arc4random() % heartColors.count;
    //heartImage = [heartImage imageWithColor:[heartColors objectAtIndex:randomColorIndex]];
    
    
    heartLayer.contents=(__bridge id _Nullable)([heartImage CGImage]);
    
    //[view.layer addSublayer:heartLayer];
    [view.layer insertSublayer:heartLayer atIndex:(int)[view.layer.sublayers count]];
    
    __weak CALayer *weakHeartLayer=heartLayer;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(){
        [weakHeartLayer removeFromSuperlayer];
    }];
    
    CAAnimationGroup *animation = [self getHeartAnimation:heartLayer.frame];
    animation.duration = 5 + (arc4random() % 5 - 2);
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [heartLayer addAnimation:animation forKey:nil];
    [CATransaction commit];
}

- (CAAnimationGroup *)getHeartAnimation:(CGRect)frame {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    
    int height = -200 + arc4random() % 40 - 20;
    int xOffset = frame.origin.x;
    int yOffset = frame.origin.y;
    int waveWidth = 70;
    CGPoint p1 = CGPointMake(xOffset, height * 0 + yOffset);
    CGPoint p2 = CGPointMake(xOffset, height * 1 + yOffset);
    CGPoint p3 = CGPointMake(xOffset, height * 2 + yOffset);
    CGPoint p4 = CGPointMake(xOffset, height * 2 + yOffset);
    //CGPoint p4 = CGPointMake(xOffset, screenHeight);
    CGPathMoveToPoint(path, NULL, p1.x,p1.y);
    
    if (arc4random() % 2) {
        CGPathAddQuadCurveToPoint(path, NULL, p1.x - arc4random() % waveWidth, p1.y + height / 2.0, p2.x, p2.y);
        CGPathAddQuadCurveToPoint(path, NULL, p2.x + arc4random() % waveWidth, p2.y + height / 2.0, p3.x, p3.y);
        CGPathAddQuadCurveToPoint(path, NULL, p3.x - arc4random() % waveWidth, p3.y + height / 2.0, p4.x, p4.y);
    } else {
        CGPathAddQuadCurveToPoint(path, NULL, p1.x + arc4random() % waveWidth, p1.y + height / 2.0, p2.x, p2.y);
        CGPathAddQuadCurveToPoint(path, NULL, p2.x - arc4random() % waveWidth, p2.y + height / 2.0, p3.x, p3.y);
        CGPathAddQuadCurveToPoint(path, NULL, p3.x + arc4random() % waveWidth, p3.y + height / 2.0, p4.x, p4.y);
    }
    animation.path = path;
    animation.calculationMode = kCAAnimationCubicPaced;
    CGPathRelease(path);
    
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @01.0f;
    opacityAnimation.toValue  = @0.0f;
    opacityAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @1.0f;
    scaleAnimation.toValue  = @0.5f;
    scaleAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = @[animation, opacityAnimation,scaleAnimation];
    return animGroup;
}

-(void)onTick {
    a++;
    b++;
    self.fakeLabel.text = [NSString stringWithFormat:@"You can see : %d+%d=%d",a,b,a+b ];
}


@end
