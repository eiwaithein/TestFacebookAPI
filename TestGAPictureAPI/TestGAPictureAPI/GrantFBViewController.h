//
//  GrantFBViewController.h
//  TestGAPictureAPI
//
//  Created by Ei Wai Wai Thein on 26/8/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface GrantFBViewController : UIViewController

@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *llbName;

- (IBAction)accessUserInfo:(id)sender;
- (IBAction)accessUserEvents:(id)sender;
- (IBAction)postAnObject:(id)sender;
- (IBAction)deleteAnObject:(id)sender;
- (IBAction)postAnOGStory:(id)sender;








@end
