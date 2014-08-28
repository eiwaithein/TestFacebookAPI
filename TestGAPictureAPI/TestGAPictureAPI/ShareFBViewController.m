//
//  ShareFBViewController.m
//  TestGAPictureAPI
//
//  Created by Ei Wai Wai Thein on 25/8/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import "ShareFBViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ShareFBViewController () <FBLoginViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

{
    int sharetype; // share type is button's tag.
}

@end


@implementation ShareFBViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.btnShareLInkViaAPI.hidden = YES;
    self.btnShareStatusViaAPI.hidden = YES;
    self.btnShareOGStory.hidden = YES;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBLogin Delegate function

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    self.btnShareLInkViaAPI.hidden = NO;
    self.btnShareStatusViaAPI.hidden = NO;
    self.btnShareOGStory.hidden = NO;
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    self.btnShareLInkViaAPI.hidden = YES;
    self.btnShareStatusViaAPI.hidden = YES;
    self.btnShareOGStory.hidden = YES;

}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}








#pragma mark - Facebook Share Functions

- (IBAction)shareLinkviaDialog:(id)sender {
    sharetype = 1;
    [self fshareLinkviaDialog];
}

- (IBAction)shareStatusviaDialog:(id)sender {
    sharetype = 2;
    [self fshareStatusviaDialog];
}

- (IBAction)sharePhotoviaDialog:(id)sender {
    sharetype = 3;
    [self fsharePhotoviaDialog];
}

- (IBAction)shareOGStoryviaDialog:(id)sender {
    sharetype = 7;
    [self fshareOGStoryviaDialog];
}

- (IBAction)shareLinkviaAPI:(id)sender {
    sharetype = 4;
    [self fshareLinkviaAPI];
}

- (IBAction)shareStatusviaAPI:(id)sender {
    sharetype = 5;
    [self fshareStatusviaAPI];
}

- (IBAction)shareOGStoryviaAPI:(id)sender {
    sharetype = 6;
    [self fshareOGStoryviaAPI];
}


#pragma mark - private functions

- (void)showAlert : (NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share To Facebook" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)fshareLinkviaDialog{
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Sharing Tutorial", @"name",
                                       @"Build great social apps and get more installs.", @"caption",
                                       @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                       @"https://developers.facebook.com/docs/ios/share/", @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

- (void)fshareStatusviaDialog{
    
    // Check if the Facebook app is installed and we can present the share dialog
    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:nil
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

- (void)fsharePhotoviaDialog{
    // If the Facebook app is installed and we can present the share dialog
    if([FBDialogs canPresentShareDialogWithPhotos]) {
        NSLog(@"canPresent");
        // Retrieve a picture from the device's photo library
        /*
         NOTE: SDK Image size limits are 480x480px minimum resolution to 12MB maximum file size.
         In this app we're not making sure that our image is within those limits but you should.
         Error code for images that go below or above the size limits is 102.
         */
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [imagePicker setDelegate:self];
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    } else {
        //The user doesn't have the Facebook for iOS app installed, so we can't present the Share Dialog
        /*Fallback: You have two options
         1. Share the photo as a Custom Story using a "share a photo" Open Graph action, and publish it using API calls.
         See our Custom Stories tutorial: https://developers.facebook.com/docs/ios/open-graph
         2. Upload the photo making a requestForUploadPhoto
         See the reference: https://developers.facebook.com/docs/reference/ios/current/class/FBRequest/#requestForUploadPhoto:
         */
    }

}



- (void)fshareLinkviaAPI{
    // We will post on behalf of the user, these are the permissions we need:
    NSArray *permissionsNeeded = @[@"publish_actions"];
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  
                                  // Check if all the permissions we need are present in the user's current permissions
                                  // If they are not present add them to the permissions to be requested
                                  for (NSString *permission in permissionsNeeded){
                                      if (![currentPermissions objectForKey:permission]){
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  // If we have permissions to request
                                  if ([requestPermissions count] > 0){
                                      // Ask for the missing permissions
                                      [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                                            defaultAudience:FBSessionDefaultAudienceFriends
                                                                          completionHandler:^(FBSession *session, NSError *error) {
                                                                              if (!error) {
                                                                                  // Permission granted, we can request the user information
                                                                                  [self makeRequestToShareLink];
                                                                              } else {
                                                                                  // An error occurred, handle the error
                                                                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                                                  NSLog(@"%@", error.description);
                                                                              }
                                                                          }];
                                  } else {
                                      // Permissions are present, we can request the user information
                                      [self makeRequestToShareLink];
                                  }
                                  
                              } else {
                                  // There was an error requesting the permission information
                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"%@", error.description);
                              }
                          }];
}

- (void)fshareStatusviaAPI{
    // We will post on behalf of the user, these are the permissions we need:
    NSArray *permissionsNeeded = @[@"publish_actions"];
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  
                                  // Check if all the permissions we need are present in the user's current permissions
                                  // If they are not present add them to the permissions to be requested
                                  for (NSString *permission in permissionsNeeded){
                                      if (![currentPermissions objectForKey:permission]){
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  // If we have permissions to request
                                  if ([requestPermissions count] > 0){
                                      // Ask for the missing permissions
                                      [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                                            defaultAudience:FBSessionDefaultAudienceFriends
                                                                          completionHandler:^(FBSession *session, NSError *error) {
                                                                              if (!error) {
                                                                                  // Permission granted, we can request the user information
                                                                                  [self makeRequestToUpdateStatus];
                                                                              } else {
                                                                                  // An error occurred, handle the error
                                                                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                                                  NSLog(@"%@", error.description);
                                                                              }
                                                                          }];
                                  } else {
                                      // Permissions are present, we can request the user information
                                      [self makeRequestToUpdateStatus];
                                  }
                                  
                              } else {
                                  // There was an error requesting the permission information
                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"%@", error.description);
                              }
                          }];
}

- (void)fshareOGStoryviaAPI {
    // Check for publish permissions
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSDictionary *permissions= [(NSArray *)[result data] objectAtIndex:0];
                                  if (![permissions objectForKey:@"publish_actions"]){
                                      // Permission hasn't been granted, so ask for publish_actions
                                      [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                                            defaultAudience:FBSessionDefaultAudienceFriends
                                                                          completionHandler:^(FBSession *session, NSError *error) {
                                                                              if (!error) {
                                                                                  if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound){
                                                                                      // Permission not granted, tell the user we will not share to Facebook
                                                                                      NSLog(@"Permission not granted, we will not share to Facebook.");
                                                                                      
                                                                                  } else {
                                                                                      // Permission granted, publish the OG story
                                                                                      [self pickImageAndPublishStory];
                                                                                  }
                                                                                  
                                                                              } else {
                                                                                  // An error occurred, we need to handle the error
                                                                                  // See: https://developers.facebook.com/docs/ios/errors
                                                                                  NSLog(@"Encountered an error requesting permissions: %@", error.description);
                                                                              }
                                                                          }];
                                      
                                  } else {
                                      // Permissions present, publish the OG story
                                      [self pickImageAndPublishStory];
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"Encountered an error checking permissions: %@", error.description);
                              }
                          }];
}



- (void)fshareOGStoryviaDialog {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];

}


// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)makeRequestToShareLink {
    
    // NOTE: pre-filling fields associated with Facebook posts,
    // unless the user manually generated the content earlier in the workflow of your app,
    // can be against the Platform policies: https://developers.facebook.com/policy
    
    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Sharing Tutorial", @"name",
                                   @"Build great social apps", @"caption",
                                   @"Allow your users to share stories on Facebook from your app using the iOS SDK.Allow your users to share stories on Facebook from your app using the iOS SDK.Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                   @"https://developers.facebook.com/docs/ios/share/", @"link",
                                   @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                   nil];
    
    // Make the request
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Link posted successfully to Facebook
                                  NSLog(@"result: %@", result);
                                  [self showAlert:@"Your post has been shared on facebook."];
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"%@", error.description);
                              }
                          }];
}

- (void)makeRequestToUpdateStatus {
    
    // NOTE: pre-filling fields associated with Facebook posts,
    // unless the user manually generated the content earlier in the workflow of your app,
    // can be against the Platform policies: https://developers.facebook.com/policy
    
    [FBRequestConnection startForPostStatusUpdate:@"User-generated status update."
                                completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                    if (!error) {
                                        // Status update posted successfully to Facebook
                                        NSLog(@"result: %@", result);
                                    } else {
                                        // An error occurred, we need to handle the error
                                        // See: https://developers.facebook.com/docs/ios/errors
                                        NSLog(@"%@", error.description);
                                    }
                                }];
}

- (void)pickImageAndPublishStory
{
    // Retrieve a picture from the device's photo library
    /*
     NOTE: SDK Image size limits are 480x480px minimum resolution to 12MB maximum file size.
     In this app we're not making sure that our image is within those limits but you should.
     Error code for images that go below or above the size limits is 102.
     */
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)postOGStoryviaAPI : (UIImage*)image{
    // stage an image
    [FBRequestConnection startForUploadStagingResourceWithImage:image completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error) {
            NSLog(@"Successfuly staged image with staged URI: %@", [result objectForKey:@"uri"]);
            
            // instantiate a Facebook Open Graph object
            NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
            
            // specify that this Open Graph object will be posted to Facebook
            object.provisionedForPost = YES;
            
            // for og:title
            object[@"title"] = @"Roasted pumpkin seeds";
            
            // for og:type, this corresponds to the Namespace you've set for your app and the object type name
            object[@"type"] = @"fbogtestgapicture:meal";
            
            // for og:description
            object[@"description"] = @"Crunchy pumpkin seeds roasted in butter and lightly salted.";
            
            // for og:url, we cover how this is used in the "Deep Linking" section below
            object[@"url"] = @"https://www.google.com/";
            
            // for og:image we assign the uri of the image that we just staged
            object[@"image"] = @[@{@"url": [result objectForKey:@"uri"], @"user_generated" : @"false" }];
            
            NSLog(@"object - %@",object);
            
            // Post custom object
            [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(!error) {
                    // get the object ID for the Open Graph object that is now stored in the Object API
                    NSString *objectId = [result objectForKey:@"id"];
                    NSLog(@"object id: %@", objectId);
                    
                    // create an Open Graph action
                    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
                    //[action setObject:objectId forKey:@"dish"];
                    [action setObject:objectId forKey:@"meal"];
                    
                    // create action referencing user owned object
                    //[FBRequestConnection startForPostWithGraphPath:@"/me/fbogsample:eat" graphObject:action
                    [FBRequestConnection startForPostWithGraphPath:@"/me/fbogtestgapicture:eat" graphObject:action
                                                 completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if(!error) {
                            NSLog(@"OG story posted, story id: %@", [result objectForKey:@"id"]);
                            [[[UIAlertView alloc] initWithTitle:@"OG story posted"
                                                        message:@"Check your Facebook profile or activity log to see the story."
                                                       delegate:self
                                              cancelButtonTitle:@"OK!"
                                              otherButtonTitles:nil] show];
                        } else {
                            // An error occurred, we need to handle the error
                            // See: https://developers.facebook.com/docs/ios/errors
                            NSLog(@"Encountered an error posting to Open Graph: %@", error.description);
                        }
                    }];
                    
                } else {
                    // An error occurred, we need to handle the error
                    // See: https://developers.facebook.com/docs/ios/errors
                    NSLog(@"Encountered an error posting to Open Graph: %@", error.description);
                }
            }];
            
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            NSLog(@"Error staging an image: %@", error.description);
        }
    }];
}


- (void)postOGStoryviaDialog : (UIImage*)img{
    /// Package the image inside a dictionary
    NSArray* image = @[@{@"url": img, @"user_generated": @"true"}];
    
    // Create an object
    id<FBGraphObject> object =
    [FBGraphObject openGraphObjectForPostWithType:@"fbogtestgapicture:meal"
                                            title:@"Roasted pumpkin seeds"
                                            image:@"http://i.imgur.com/g3Qc1HN.png"
                                              url:@"http://example.com/roasted_pumpkin_seeds"
                                      description:@"Crunchy pumpkin seeds roasted in butter and lightly salted."];
    
    // Create an action
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    
    // Set image on the action
    [action setObject:image forKey:@"image"];
    
    // Link the object to the action
    [action setObject:object forKey:@"meal"];
    
    // Tag one or multiple users using the users' ids
    //[action setTags:@[<user-ids>]];
    
    // Tag a place using the place's id
    id<FBGraphPlace> place = (id<FBGraphPlace>)[FBGraphObject graphObject];
    //[place setId:@"141887372509674"]; // Facebook Seattle
    [place setObjectID:@"141887372509674"];
    [action setPlace:place];
    
    // Dismiss the image picker off the screen
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
    params.action = action;
    params.actionType = @"fbogtestgapicture:eat";
    
    // If the Facebook app is installed and we can present the share dialog
    if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
        // Show the share dialog
        [FBDialogs presentShareDialogWithOpenGraphAction:action
                                              actionType:@"fbogtestgapicture:eat"
                                     previewPropertyName:@"meal"
                                                 handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                     if(error) {
                                                         // An error occurred, we need to handle the error
                                                         // See: https://developers.facebook.com/docs/ios/errors
                                                         NSLog(@"Error publishing story: %@", error.description);
                                                     } else {
                                                         // Success
                                                         NSLog(@"result %@", results);
                                                         [self postCommentForobjectId:[results objectForKey:@"postId"]];
                                                     }
                                                 }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Roasted pumpkin seeds", @"name",
                                       @"Healthy snack.", @"caption",
                                       @"Crunchy pumpkin seeds roasted in butter and lightly salted.", @"description",
                                       @"http://example.com/roasted_pumpkin_seeds", @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
        
    }
}

- (void)postCommentForobjectId : (NSString*)objectId{
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"This is testing comment for object graph", @"message", @"Your api's access Token",@"access_token",nil];
    NSString *commentURL = [NSString stringWithFormat:@"%@/comments",objectId];
    [FBRequestConnection startWithGraphPath:commentURL parameters:res HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error)
        {
            NSLog(@"error: %@", error.localizedDescription);
        }
        else
        {
            NSLog(@"ok!!");
        }
    }];
}




#pragma mark - UI ImageNavigation Delegate
// When the user is done picking the image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (sharetype == 6)
    {
        // Dismiss the image picker off the screen
        [self dismissViewControllerAnimated:YES completion:nil];
        [self postOGStoryviaAPI:img];
    }
    else if (sharetype ==7)
    {
        
        [self postOGStoryviaDialog:img];
         
    }
    else
    {
    
    FBPhotoParams *params = [[FBPhotoParams alloc] init];
    params.photos = @[img];
    
    [FBDialogs presentShareDialogWithPhotoParams:params
                                     clientState:nil
                                         handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                             if (error) {
                                                 NSLog(@"Error: %@", error.description);
                                             } else {
                                                 NSLog(@"Success!");
                                             }
                                         }];
    }
    
}

@end
