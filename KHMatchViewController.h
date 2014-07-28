//
//  KHMatchViewController.h
//  MatchedUp
//
//  Created by Koen Hendriks on 27/07/14.
//  Copyright (c) 2014 Koen Hendriks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KHMatchViewControllerDelegate <NSObject>

-(void)presentMatchesViewController;

@end


@interface KHMatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak, nonatomic) id <KHMatchViewControllerDelegate> delegate;

@end
