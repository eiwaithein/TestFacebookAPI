//
//  ShareFBViewController.h
//  TestGAPictureAPI
//
//  Created by Ei Wai Wai Thein on 25/8/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ShareFBViewController : UIViewController

@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;

@property (weak, nonatomic) IBOutlet UIButton *btnShareLInkViaAPI;
@property (weak, nonatomic) IBOutlet UIButton *btnShareStatusViaAPI;
@property (weak, nonatomic) IBOutlet UIButton *btnShareOGStory;



- (IBAction)shareLinkviaDialog:(id)sender;
- (IBAction)shareStatusviaDialog:(id)sender;
- (IBAction)sharePhotoviaDialog:(id)sender;
- (IBAction)shareOGStoryviaDialog:(id)sender;


- (IBAction)shareLinkviaAPI:(id)sender;
- (IBAction)shareStatusviaAPI:(id)sender;
- (IBAction)shareOGStoryviaAPI:(id)sender;




@end
