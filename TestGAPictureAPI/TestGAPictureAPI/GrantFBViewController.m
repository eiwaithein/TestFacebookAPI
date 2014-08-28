//
//  GrantFBViewController.m
//  TestGAPictureAPI
//
//  Created by Ei Wai Wai Thein on 26/8/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import "GrantFBViewController.h"

@interface GrantFBViewController () <FBLoginViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

{
    
}
@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (strong, nonatomic) NSString *objectID;

@end

@implementation GrantFBViewController

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
    self.fbLoginView.readPermissions = @[@"public_profile"];
    self.fbLoginView.delegate = self;
    _objectID = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - FBLogin Delegate function

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    self.profilePicture.profileID = [user objectID];
    self.llbName.text = [user name];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    self.profilePicture.profileID = nil;
    self.llbName.text = @"";
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


#pragma mark - Facebook Grant Access Information

- (IBAction)accessUserInfo:(id)sender {
    // We will request the user's public picture and the user's birthday
    // These are the permissions we need:
    NSArray *permissionsNeeded = @[@"public_profile", @"user_birthday"];
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  // These are the current permissions the user has
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  
                                  // We will store here the missing permissions that we will have to request
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
                                      [FBSession.activeSession
                                       requestNewReadPermissions:requestPermissions
                                       completionHandler:^(FBSession *session, NSError *error) {
                                           if (!error) {
                                               // Permission granted, we can request the user information
                                               [self makeRequestForUserData];
                                           } else {
                                               // An error occurred, we need to handle the error
                                               // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                               NSLog(@"error %@", error.description);
                                           }
                                       }];
                                  } else {
                                      // Permissions are present
                                      // We can request the user information
                                      [self makeRequestForUserData];
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
    

}

// ------------> Code for requesting user events starts here <------------

/*
 This function asks for the user's (upcoming) events, and for those events retrieves the name, the start_time and the cover picture.
 It first checks for the existence of the public_profile and user_events permissions
 If the permissions are not present, it requests them
 If/once the permissions are present, it makes the user events request with field expansion for name, start_time and cover picture.
 */



- (IBAction)accessUserEvents:(id)sender {
    // We will request the user's events
    // These are the permissions we need:
    NSArray *permissionsNeeded = @[@"user_events"];
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  NSLog(@"current permissions %@", currentPermissions);
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
                                      [FBSession.activeSession requestNewReadPermissions:requestPermissions
                                                                       completionHandler:^(FBSession *session, NSError *error) {
                                                                           if (!error) {
                                                                               // Permission granted
                                                                               NSLog(@"new permissions %@", [FBSession.activeSession permissions]);
                                                                               // We can request the user information
                                                                               [self makeRequestForUserEvents];
                                                                           } else {
                                                                               // An error occurred, we need to handle the error
                                                                               // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                                                               NSLog(@"error %@", error.description);
                                                                           }
                                                                       }];
                                  } else {
                                      // Permissions are present
                                      // We can request the user information
                                      [self makeRequestForUserEvents];
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
}

- (IBAction)postAnObject:(id)sender {
    
    // We will post an object on behalf of the user
    // These are the permissions we need:
    NSArray *permissionsNeeded = @[@"publish_actions"];
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  NSLog(@"current permissions %@", currentPermissions);
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
                                                                                  // Permission granted
                                                                                  NSLog(@"new permissions %@", [FBSession.activeSession permissions]);
                                                                                  // We can request the user information
                                                                                  [self makeRequestToPostObject];
                                                                              } else {
                                                                                  // An error occurred, we need to handle the error
                                                                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                                                                  NSLog(@"error %@", error.description);
                                                                              }
                                                                          }];
                                  } else {
                                      // Permissions are present
                                      // We can request the user information
                                      [self makeRequestToPostObject];
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
}

- (IBAction)deleteAnObject:(id)sender {
    __block NSString *objectID = _objectID;
    if(!objectID){
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Can't delete an object because there's no object! Please tap the \"Post an object\" button first to create an object, then you can click on this button to delete it."
                                   delegate:self
                          cancelButtonTitle:@"OK!"
                          otherButtonTitles:nil] show];
    } else {
        //Make an HTTP DELETE request with the OG object's ID
        [FBRequestConnection startForDeleteObject:objectID
                                completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                    NSString *alertText;
                                    NSString *alertTitle;
                                    if (error) {
                                        // An error occurred, we need to handle the error
                                        // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                        NSLog(@"error %@", error.description);
                                    } else {
                                        // The object has been removed
                                        NSLog(@"The object with id %@ has been deleted", objectID);
                                        alertTitle = @"Object successfully deleted";
                                        alertText = [NSString stringWithFormat:@"The object with id %@ has been deleted", objectID];
                                        [[[UIAlertView alloc] initWithTitle:alertTitle
                                                                    message:alertText
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK!"
                                                          otherButtonTitles:nil] show];
                                        objectID =  nil;
                                    }
                                }];
        _objectID = objectID;
        
    }
}

- (IBAction)postAnOGStory:(id)sender {
    // We will post a story on behalf of the user
    // These are the permissions we need:
    NSArray *permissionsNeeded = @[@"publish_actions"];
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  NSLog(@"current permissions %@", currentPermissions);
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
                                                                                  // Permission granted
                                                                                  NSLog(@"new permissions %@", [FBSession.activeSession permissions]);
                                                                                  // We can request the user information
                                                                                  [self makeRequestToPostStory];
                                                                              } else {
                                                                                  // An error occurred, we need to handle the error
                                                                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                                                                  NSLog(@"error %@", error.description);
                                                                              }
                                                                          }];
                                  } else {
                                      // Permissions are present
                                      // We can request the user information
                                      [self makeRequestToPostStory];
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];

}

#pragma mark - private function
- (void) makeRequestForUserData
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
        } else {
            // An error occurred, we need to handle the error
            // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
            NSLog(@"error %@", error.description);
        }
    }];
}

- (void)makeRequestForUserEvents
{
    [FBRequestConnection startWithGraphPath:@"me/events?fields=cover,name,start_time"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Success! Include your code to handle the results here
                                  NSLog(@"user events: %@", result);
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
}

- (void)makeRequestToPostObject
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

- (void)makeRequestToPostStory
{
    if(!_objectID){
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please tap the \"Post an object\" button first to create an object, then you can click on this button to like it."
                                   delegate:self
                          cancelButtonTitle:@"OK!"
                          otherButtonTitles:nil] show];
    } else {
        // Create a like action
        id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
        
        // Link that like action to the restaurant object that we have created
        [action setObject:_objectID forKey:@"object"];
        
        // Post the action to Facebook
        [FBRequestConnection startForPostWithGraphPath:@"me/og.likes"
                                           graphObject:action
                                     completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                         __block NSString *alertText;
                                         __block NSString *alertTitle;
                                         if (!error) {
                                             // Success, the restaurant has been liked
                                             NSLog(@"Posted OG action, id: %@", [result objectForKey:@"id"]);
                                             alertText = [NSString stringWithFormat:@"Posted OG action, id: %@", [result objectForKey:@"id"]];
                                             alertTitle = @"Success";
                                             [[[UIAlertView alloc] initWithTitle:alertTitle
                                                                         message:alertText
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK!"
                                                               otherButtonTitles:nil] show];
                                         } else {
                                             // An error occurred, we need to handle the error
                                             // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                             NSLog(@"error %@", error.description);
                                         }
                                     }];
        
    }
}

#pragma mark - UINavigationDelegate Methods.
// When the user is done picking the image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the UIImage
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // Dismiss the image picker off the screen
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // stage the image
    [FBRequestConnection startForUploadStagingResourceWithImage:image completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        __block NSString *alertText;
        __block NSString *alertTitle;
        if(!error) {
            NSLog(@"Successfuly staged image with staged URI: %@", [result objectForKey:@"uri"]);
            
            // Package image inside a dictionary, inside an array like we'll need it for the object
            NSArray *image = @[@{@"url": [result objectForKey:@"uri"], @"user_generated" : @"true" }];
            
            // Create an object
            NSMutableDictionary<FBOpenGraphObject> *restaurant = [FBGraphObject openGraphObjectForPost];
            
            // specify that this Open Graph object will be posted to Facebook
            restaurant.provisionedForPost = YES;
            
            // Add the standard object properties
            restaurant[@"og"] = @{ @"title":@"mytitle", @"type":@"restaurant.restaurant", @"description":@"my description", @"image":image };
            
            // Add the properties restaurant inherits from place
            restaurant[@"place"] = @{ @"location" : @{ @"longitude": @"-58.381667", @"latitude":@"-34.603333"} };
            
            // Add the properties particular to the type restaurant.restaurant
            restaurant[@"restaurant"] = @{@"category": @[@"Mexican"],
                                          @"contact_info": @{@"street_address": @"123 Some st",
                                                             @"locality": @"Menlo Park",
                                                             @"region": @"CA",
                                                             @"phone_number": @"555-555-555",
                                                             @"website": @"http://www.example.com"}};
            
            // Make the Graph API request to post the object
            FBRequest *request = [FBRequest requestForPostWithGraphPath:@"me/objects/restaurant.restaurant"
                                                            graphObject:@{@"object":restaurant}];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // Success! Include your code to handle the results here
                    NSLog(@"result: %@", result);
                    _objectID = [result objectForKey:@"id"];
                    alertTitle = @"Object successfully created";
                    alertText = [NSString stringWithFormat:@"An object with id %@ has been created", _objectID];
                    [[[UIAlertView alloc] initWithTitle:alertTitle
                                                message:alertText
                                               delegate:self
                                      cancelButtonTitle:@"OK!"
                                      otherButtonTitles:nil] show];
                } else {
                    // An error occurred, we need to handle the error
                    // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                    NSLog(@"error %@", error.description);
                }
            }];
        } else {
            // An error occurred, we need to handle the error
            // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
            NSLog(@"error %@", error.description);
        }
    }];
}



@end
