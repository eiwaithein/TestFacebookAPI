//
//  ViewController.h
//  TestGAPictureAPI
//
//  Created by Ei Wai Wai Thein on 25/8/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ViewController : UIViewController <FBLoginViewDelegate>
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;


- (IBAction)loginWithFacebook:(id)sender;


@end
