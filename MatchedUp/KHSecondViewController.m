//
//  KHSecondViewController.m
//  MatchedUp
//
//  Created by Koen Hendriks on 11/07/14.
//  Copyright (c) 2014 Koen Hendriks. All rights reserved.
//

#import "KHSecondViewController.h"

@interface KHSecondViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@end

@implementation KHSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Set the profile picture in the profilePictureImageView, using Parse
    PFQuery *query = [PFQuery queryWithClassName:kKHPhotoClassKey];
    // Get only the photo's for the current user
    [query whereKey:kKHPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0)
        {
            // Only get the first photo
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kKHPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                NSLog(@"got image");
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
        if (error) {
            NSLog(@"Error %@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
