//
//  SocialPluginViewController.m
//  TestGAPictureAPI
//
//  Created by Ei Wai Wai Thein on 28/8/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import "SocialPluginViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SocialPluginViewController ()

@end

@implementation SocialPluginViewController

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
    [self addLikeButton];
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

- (void)addLikeButton{
    [FBSettings enableBetaFeature:FBBetaFeaturesLikeButton];
    [FBSettings enablePlatformCompatibility:NO];
    FBLikeControl *likeControl = [[FBLikeControl alloc] init];
    likeControl.objectID = @"http://shareitexampleapp.parseapp.com/photo1/";
    likeControl.likeControlHorizontalAlignment=FBLikeControlHorizontalAlignmentLeft;
    likeControl.likeControlStyle=FBLikeControlStyleBoxCount;
    [self.likeView addSubview:likeControl];
}

@end
