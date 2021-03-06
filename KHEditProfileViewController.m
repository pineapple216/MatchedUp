//
//  KHEditProfileViewController.m
//  MatchedUp
//
//  Created by Koen Hendriks on 15/07/14.
//  Copyright (c) 2014 Koen Hendriks. All rights reserved.
//

#import "KHEditProfileViewController.h"

@interface KHEditProfileViewController ()

@property (strong, nonatomic) IBOutlet UITextView *tagLineTextView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;

@end

@implementation KHEditProfileViewController

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
    
    // Get the picture of ourselves, the current user and show it on the imageView
    PFQuery *query = [PFQuery queryWithClassName:kKHPhotoClassKey];
    [query whereKey:kKHPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0 ) {
            // Get the photo object from the objects array
            PFObject *photo = objects[0];
            // Get the actual picture
            PFFile *pictureFile = photo[kKHPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
    self.tagLineTextView.text = [[PFUser currentUser] objectForKey:kKHUserTagLineKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)saveBarButtonItemPressed:(UIBarButtonItem *)sender
{
    // Save the text in the tagline textview to Parse and pop the current VC
    [[PFUser currentUser] setObject:self.tagLineTextView.text forKey:kKHUserTagLineKey];
    [[PFUser currentUser]saveInBackground];
    [self.navigationController popViewControllerAnimated:YES];
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
