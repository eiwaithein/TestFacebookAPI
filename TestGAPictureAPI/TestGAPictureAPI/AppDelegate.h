//
//  AppDelegate.h
//  TestGAPictureAPI
//
//  Created by Ei Wai Wai Thein on 25/8/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareFBViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSDictionary *refererAppLink;

@property (strong, nonatomic) ShareFBViewController *shareViewController;


@end
