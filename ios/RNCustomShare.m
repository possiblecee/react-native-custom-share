//
//  Created by Rafael Nascimento on 25/07/17.
//  Copyright © 2017. All rights reserved.
//

#import "RNCustomShare.h"
#import "RCTBridge.h"
#import "AQSInstagramActivity.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#include "Constants.h"
#import "RCTConvert.h"
#import "RCTLog.h"
#import "RCTUIManager.h"
#import "RCTUtils.h"
@import Photos;

@implementation RNCustomShare

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

# pragma mark - Is installed

- (NSDictionary *)constantsToExport {
    return @{
             @"instagram":[[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: kInstagramURLScheme]] ? @(YES) : @(NO),
             @"whatsapp":[[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kWhatsappURLScheme]] ? @(YES) : @(NO),
             @"twitter": [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kTwitterURLScheme]] ? @(YES) : @(NO),
             @"facebook": [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kFacebookURLScheme]] ? @(YES) : @(NO)
             };
}


# pragma mark - General sharing

RCT_EXPORT_METHOD(share:(NSString *)base64Image copy:(NSString *)copy andUrl:(NSString *)url) {
    
    UIImage *image = [UIImage imageWithData: [[NSData alloc]initWithBase64EncodedString:base64Image options:NSDataBase64DecodingIgnoreUnknownCharacters]];
    
    if (!image) {
        return;
    }
    
    AQSInstagramActivity *activity = [[AQSInstagramActivity alloc] init];
    NSArray *items = @[copy, [[NSURL alloc]initWithString:url], image];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[activity]];
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeCopyToPasteboard, UIActivityTypeOpenInIBooks];
    
    UIViewController *rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootController presentViewController:activityController animated:YES completion:NULL];
}

# pragma mark - Sharing WITH callback

RCT_EXPORT_METHOD(shareOnInstagramWithCallback:(NSString *)base64Image
                  failureCallback:(RCTResponseErrorBlock)failureCallback
                  successCallback:(RCTResponseSenderBlock)successCallback) {
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kInstagramURLScheme]]) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusDenied) {
            [self savePicAndOpenInstagram: base64Image
                          failureCallback: failureCallback
                          successCallback: successCallback];;
        }
        else if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self savePicAndOpenInstagram: base64Image
                                  failureCallback: failureCallback
                                  successCallback: successCallback];;
                }
            }];
        }
    } else {
        NSString *errorMessage = @"Not installed";
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
        NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];
        failureCallback(error);
    }
}

RCT_EXPORT_METHOD(shareOnTwitterWithCallback:(NSString *)copy andUrl:(NSString *)url
                  failureCallback:(RCTResponseErrorBlock)failureCallback
                  successCallback:(RCTResponseSenderBlock)successCallback) {
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kTwitterURLScheme]]) {
        SLComposeViewController *twPostSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twPostSheet setInitialText:copy];
        [twPostSheet addURL:[NSURL URLWithString:url]];
        
        UIViewController *controller = RCTPresentedViewController();
        twPostSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone) {
                successCallback(@[]);
            } else {
                NSString *errorMessage = @"Cancelled";
                NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
                NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];
                failureCallback(error);
            }
        };
        [controller presentViewController:twPostSheet animated:YES completion:nil];
    } else {
        NSString *errorMessage = @"Not installed";
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
        NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];
        failureCallback(error);
    }
}

RCT_EXPORT_METHOD(shareOnWhatsappWithCallback:(NSString *)copy andUrl:(NSString *)url
                  failureCallback:(RCTResponseErrorBlock)failureCallback
                  successCallback:(RCTResponseSenderBlock)successCallback) {
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kWhatsappURLScheme]]) {
        copy = [copy stringByAppendingString:@" "];
        copy = [copy stringByAppendingString:url];
        copy = [copy stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:kWhatsappSendTextURLScheme, copy]];
        [[UIApplication sharedApplication] openURL:whatsappURL];
        successCallback(@[]);
        
    } else {
        NSString *errorMessage = @"Not installed";
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
        NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];
        failureCallback(error);
    }
}

RCT_EXPORT_METHOD(shareOnFacebookWithCallback:(NSString *)copy andUrl:(NSString *)url
                  failureCallback:(RCTResponseErrorBlock)failureCallback
                  successCallback:(RCTResponseSenderBlock)successCallback) {
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kFacebookURLScheme]]) {
        SLComposeViewController *fbPostSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbPostSheet setInitialText:copy];
        [fbPostSheet addURL:[NSURL URLWithString:url]];
        
        UIViewController *controller = RCTPresentedViewController();
        fbPostSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone) {
                successCallback(@[]);
            } else {
                NSString *errorMessage = @"Cancelled";
                NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
                NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];
                failureCallback(error);
            }
        };
        [controller presentViewController:fbPostSheet animated:YES completion:nil];
        
    } else {
        NSString *errorMessage = @"Not installed";
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
        NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];
        failureCallback(error);
    }
}

# pragma mark - Sharing WITHOUT callback

RCT_EXPORT_METHOD(shareOnInstagram:(NSString *)base64Image) {
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kInstagramURLScheme]]) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusDenied) {
            [self savePicAndOpenInstagram: base64Image
                          failureCallback: NULL
                          successCallback: NULL];
        }
        else if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self savePicAndOpenInstagram: base64Image
                                  failureCallback: NULL
                                  successCallback: NULL];;
                }
            }];
        }
    }
}

RCT_EXPORT_METHOD(shareOnWhatsapp:(NSString *)copy andUrl:(NSString *)url) {
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kWhatsappURLScheme]]) {
        copy = [copy stringByAppendingString:@" "];
        copy = [copy stringByAppendingString:url];
        copy = [copy stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:kWhatsappSendTextURLScheme, copy]];
        [[UIApplication sharedApplication] openURL:whatsappURL options:@{} completionHandler:NULL];
    }
}

RCT_EXPORT_METHOD(shareOnFacebook:(NSString *)copy andUrl:(NSString *)url) {
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kFacebookURLScheme]]) {
        SLComposeViewController *fbPostSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbPostSheet setInitialText:copy];
        [fbPostSheet addURL:[NSURL URLWithString:url]];
        UIViewController *rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootController presentViewController:fbPostSheet animated:YES completion:NULL];
    }
}

RCT_EXPORT_METHOD(shareOnTwitter:(NSString *)copy andUrl:(NSString *)url) {
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kTwitterURLScheme]]) {
        SLComposeViewController *twPostSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twPostSheet setInitialText:copy];
        [twPostSheet addURL:[NSURL URLWithString:url]];
        UIViewController *rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootController presentViewController:twPostSheet animated:YES completion:NULL];
    }
}

# pragma mark - Helpers

-(void)savePicAndOpenInstagram:(NSString*)base64Image
               failureCallback:(RCTResponseErrorBlock)failureCallback
               successCallback:(RCTResponseSenderBlock)successCallback {
    UIImage *image = [UIImage imageWithData: [[NSData alloc]initWithBase64EncodedString:base64Image options:NSDataBase64DecodingIgnoreUnknownCharacters]];
    
    if (!image) {
        return;
    }
    
    NSURL *URL = [self nilOrFileURLWithImageDataTemporary:UIImageJPEGRepresentation(image, 0.9)];
    
    __block PHAssetChangeRequest *_mChangeRequest = nil;
    __block PHObjectPlaceholder *placeholder;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        NSData *pngData = [NSData dataWithContentsOfURL:URL];
        UIImage *image = [UIImage imageWithData:pngData];
        
        _mChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        placeholder = _mChangeRequest.placeholderForCreatedAsset;
        
    } completionHandler:^(BOOL success, NSError *error) {
        
        if (success) {
            NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:kInstagramLibraryURLScheme, [placeholder localIdentifier]]];
            
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                [[UIApplication sharedApplication] openURL:instagramURL options:@{} completionHandler:NULL];
                if (successCallback != NULL) {
                    successCallback(@[]);
                }
            }
        }
        else {
            if (failureCallback != NULL) {
                failureCallback(error);
            }
            
            NSLog(@"write error : %@",error);
        }
    }];
}

- (NSURL *)nilOrFileURLWithImageDataTemporary:(NSData *)data {
    NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:kInstagramPath];
    if (![data writeToFile:writePath atomically:YES]) {
        return nil;
    }
    
    return [NSURL fileURLWithPath:writePath];
}

- (UIDocumentInteractionController *)documentInteractionControllerForInstagramWithFileURL:(NSURL *)URL withCaptionText:(NSString *)textOrNil {
    UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:URL];
    [controller setUTI:kInstagramUTI];
    if (textOrNil == nil) {
        textOrNil = @"";
    }
    controller.delegate = self;
    return controller;
}

@end

