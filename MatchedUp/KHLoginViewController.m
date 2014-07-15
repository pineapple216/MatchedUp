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

// Check is the user is already logged in and if so, skip directly to the tab bar VC
-(void)viewDidAppear:(BOOL)animated
{
    // Check is the user is already cached and linked to Facebook
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // If the user has changed information on facebook, reflect it in the application
        [self updateUserInformation];
        NSLog(@"The user is already signed in");
        [self performSegueWithIdentifier:@"loginToTabBarSegue" sender:self];
    }
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
            
            // URL to get a picture from Facebook
            NSURL *pictureURL = [NSURL URLWithString: [NSString
            stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
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
            
            NSLog(@"User information updated");
            
            // Call the method request image to get an image for the user
            [self requestImage];
        }
        // If we do get an error...
        else {
            // Log it to the console
            NSLog(@"Error in Facebook request %@",error);
        }
    }];
}

// Helper Method to upload a UIImage file to parse
-(void)uploadPFFileToParse:(UIImage *)image
{
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData) {
        NSLog(@"imageData was not found");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    // Save the file to Parse
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded succesfully");
            // kKHPhotoClassKey == "Photo"
            PFObject *photo = [PFObject objectWithClassName:kKHPhotoClassKey];
            
            // Setup a key-value pair so the photo object knows which user belongs to it
            [photo setObject:[PFUser currentUser] forKey:kKHPhotoUserKey];
            
            [photo setObject:photoFile forKey:kKHPhotoPictureKey];
            
            // Save the photo
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Photo saved succesfully");
            }];
        }
        if (error) {
            NSLog(@"Error uploading image to Parse: %@", error);
        }
    }];
}

// Helper method to hit the URL and get a photo from Parse
-(void)requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kKHPhotoClassKey];
    // Only get the photo from the current user
    [query whereKey:kKHPhotoUserKey equalTo:[PFUser currentUser]];
    
    // Check is the user already has a photo saved, by counting the objects in the query object
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0)
        {
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc]init];
            
            // Create the profilePictureURL from the user dictionary
            NSURL *profilePictureURL = [NSURL URLWithString:user[kKHUserProfileKey][kKHUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            
            // Run the request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
            
            // If we did not get an url connection...
            if (!urlConnection) {
                NSLog(@"Failed to Download Picture");
            }
        }
    }];
}

#pragma mark - NSURLConnectionDataDelegate

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

// Set the image once the downloading of the image is complete
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // All data has been downloaded, now we can set the image in the header image view
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    
    // Save the image to Parse
    [self uploadPFFileToParse:profileImage];
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
