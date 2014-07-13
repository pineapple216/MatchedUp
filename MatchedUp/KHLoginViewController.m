//
//  KHLoginViewController.m
//  MatchedUp
//
//  Created by Koen Hendriks on 11/07/14.
//  Copyright (c) 2014 Koen Hendriks. All rights reserved.
//

#import "KHLoginViewController.h"

@interface KHLoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation KHLoginViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)loginButtonPressed:(UIButton *)sender
{
    // Array containing the permissions we want from facebook
    //NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_friends"];
    NSArray *permissionsArray = @[ @"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];    
    
    
    // Login to facebook with the permissions set in the array above
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        // stop animation of activity indicator and hide it when the login completes
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        
        // If we have no user...
        if (!user) {
            // ... and no error
            if (!error) {
                // Show a UIAlertView
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Log In Error" message:@"The Facebook Login was Cancelled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alertView show];
            }
            // If there was an error, display a different alertView
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                
                [alert show];
            }
        }
        // If we did get back a user, call updateUserInformation and segue to the next VC
        else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToTabBarSegue" sender:self];
        }
        
    }];
    
    // Animate the activity indicator
    [self.activityIndicator startAnimating]; // Show loading indicator until login is finished
}

#pragma mark - Helper Methods

-(void)updateUserInformation
{
    // Send request to facebook for the current user's information
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        // If we don't get an error...
        if (!error) {
            // ...Cast the data we get back to a dictionary
            NSDictionary *userDictionary = (NSDictionary *)result;
            
            // create URL
            NSString *facebookID = userDictionary[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc]initWithCapacity:8];
            
            // Check if various keys exist in the userDictionary and add them to the userProfile
            if (userDictionary[@"name"]) {
                userProfile[kKHUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]) {
                userProfile[kKHUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]) {
                userProfile[kKHUserProfileLocation] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]) {
                userProfile[kKHUserProfileGender] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]) {
                userProfile[kKHUserProfileBirthday] = userDictionary[@"birthday"];
            }
            if (userDictionary[@"interested_in"]) {
                userProfile[kKHUserProfileInterestedIn] = userDictionary[@"interested_in"];
            }
            if ([pictureURL absoluteString]) {
                userProfile[kKHUserProfilePictureURL] = [pictureURL absoluteString];
            }
            
            // Get the PFObject for the current user,
            // add the userProfile dictionary to it and save it asynchronously
            [[PFUser currentUser] setObject:userProfile forKey:kKHUserProfileKey];
            [[PFUser currentUser]saveInBackground];
        }
        // If we do get an error...
        else {
            // Log it to the console
            NSLog(@"Error in Facebook request %@",error);
        }
    }];
}

// Method to upload a file to parse
-(void)uploadPFFileToParse:(UIImage *)image
{
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData) {
        NSLog(@"imageData was not found");
        return;
    }
    
    
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
