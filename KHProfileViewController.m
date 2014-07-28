//
//  KHProfileViewController.m
//  MatchedUp
//
//  Created by Koen Hendriks on 16/07/14.
//  Copyright (c) 2014 Koen Hendriks. All rights reserved.
//

#import "KHProfileViewController.h"

@interface KHProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;

@end

@implementation KHProfileViewController

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
    // Do any additional setup after loading the view.
    
    PFFile *pictureFile = self.photo[kKHPhotoPictureKey];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        // Set the imageView's image to be the data that we get back from Parse
        self.profilePictureImageView.image = [UIImage imageWithData:data];
    }];
    // Create a new user object; the user that belongs to the photo and update the labels
    PFUser *user = self.photo[kKHPhotoUserKey];
    self.locationLabel.text = user[kKHUserProfileKey][kKHUserProfileLocation];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kKHUserProfileKey][kKHUserProfileAgeKey]];
    self.statusLabel.text = user[kKHUserProfileKey][kKHUserProfileRelationshipStatusKey];
    self.tagLineLabel.text = user[kKHUserTagLineKey];
    
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

@end
