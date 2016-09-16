//
//  ViewController.m
//  InstagramDownloader
//
//  Created by Jonathan Natale on 10/18/15.
//  Copyright © 2015 Jon Natale. All rights reserved.
//

#import "ViewController.h"
//@import AssetsLibrary;
@import Photos;

@interface ViewController ()<UIGestureRecognizerDelegate> {
    NSString *videoUrl;
    NSString *imageUrl;
    NSData *thumbImageData;
    BOOL isArabic;
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
@end

@implementation ViewController

-(IBAction)downloadTapped:(id)sender
{
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
                    if (isArabic) {
                        errorTitle = @"خطأ";
                        errorMessage = @"كان هناك خطأ في تحميل الصورة. تحقق من عنوان URL";
                        dismiss = @"إغلاق";
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
                    if (isArabic) {
                        strMessage = @"تم تحميل الصورة الى البوم الكاميرا";
                    }
                    if(videoUrl) {
                        strMessage = @"The video was downloaded to your camera roll.";
                        if (isArabic) {
                            strMessage = @"تم تحميل الفيديو إلى البوم الكاميرا";
                        }
                    }
                    
                    NSString *alertTitle = @"Success";
                    NSString *action = @"Dismiss";
                    if (isArabic) {
                        alertTitle = @"أكتمل";
                        action = @"إغلاق";
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
    NSString *strTitle = @"How to Download an Image";
    NSString *strMessage = @"1) View an image in the Instagram app\n2) Click the button (•••)\n3)Tap \"Copy Share URL\"\n4)Paste it here";
    
    if (isArabic){
        strTitle = @"كيفية تحميل الصور والفيديو";
        strMessage = @"1) عرض الصورة أو الفيديو دخل تطبيق انستقرام\n2) الضغط على زر (•••)\n3)النقر \"على زر Copy Share URL\"\n4)الصقة هنا";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:strTitle
                                                                   message:strMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *actionTitle = @"Dismiss";
    if (isArabic) {
        actionTitle = @"إغلاق";
    }
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:actionTitle
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bannerView.adUnitID = @"ca-app-pub-5722562744549789/4221694555";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoPasteUrl) name:@"enterforeground" object:nil];
    [self autoPasteUrl];
    // Set up the view
    [_urlEntry becomeFirstResponder]; // Bring up the keyboard as soon as the app opens
    _imageView.alpha = 0.0;           // Hide the image view until an image is downloaded
    
    videoUrl = nil;
    isArabic = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChangeLanguage)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    if(!isArabic) {
        //isArabic = YES;
        [_languageImageView setImage: [UIImage imageNamed:@"english"]];
    } else {
        //isArabic = NO;
        [_languageImageView setImage: [UIImage imageNamed:@"Arabic"]];
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
    NSLog(@"%@", pasteboardString);
    _urlEntry.text = pasteboardString;
}

- (void)handleChangeLanguage {
    if(!isArabic) {
        isArabic = YES;
        [_languageImageView setImage: [UIImage imageNamed:@"Arabic"]];
    } else {
        isArabic = NO;
        [_languageImageView setImage: [UIImage imageNamed:@"english"]];
    }
    [self updateUIbyLanguage];
}

- (void)updateUIbyLanguage {
    if(isArabic) {
        [self.helpButton setTitle:@"مساعدة" forState:UIControlStateNormal];
        [self.downloadButton setTitle:@"تـحــمـيـل" forState:UIControlStateNormal];
        [self.urlEntry setPlaceholder:@"الصق الرابط هنا"];
    } else {
        [self.helpButton setTitle:@"Help" forState:UIControlStateNormal];
        [self.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
        [self.urlEntry setPlaceholder:@"paste url here"];
    }
}
- (IBAction)BackGroundTapp:(id)sender {
    
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn : (UITextField *) textField {
    
    [textField resignFirstResponder];
    return YES;
}

@end
