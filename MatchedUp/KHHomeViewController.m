//
//  KHHomeViewController.m
//  MatchedUp
//
//  Created by Koen Hendriks on 15/07/14.
//  Copyright (c) 2014 Koen Hendriks. All rights reserved.
//

#import "KHHomeViewController.h"
#import "KHTestUser.h"

@interface KHHomeViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;

// Properties to track if the current user likes or dislikes a photo
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;


@end

@implementation KHHomeViewController

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
    
    // Save a new test user to Parse
    //[KHTestUser saveTestUserToParse];
    
    // Don't allow the user to immediately press the 3 buttons
    self.likeButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    
    // Set the current photoIndex to 0, so we always see the first photo
    self.currentPhotoIndex = 0;
    
    // Get all the objects saved to the photo class
    PFQuery *query = [PFQuery queryWithClassName:kKHPhotoClassKey];
    
    // Exclude photos from the current User; we don't want to like/dislike ourselves
    [query whereKey:kKHPhotoUserKey notEqualTo:[PFUser currentUser]];
    
    // Also download the user object executing the query
    [query includeKey:kKHPhotoUserKey];
    
    // Get the objects in the background using a block
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            self.photos = objects;
            [self queryForCurrentPhotoIndex];
        }
        else{
            // Log error to console
            NSLog(@"Error getting photo's: %@", error);
        }
    }];
    
    // Do additional stuff
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)likeButtonPressed:(UIButton *)sender
{
    [self checkLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender
{
    [self checkDislike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender
{
    
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender
{
    
}

- (IBAction)chatBarButtonItempressed:(UIBarButtonItem *)sender
{
    
}

#pragma mark - Helper Methods

// Helper method to query for the current photoIndex
-(void)queryForCurrentPhotoIndex
{
    if ([self.photos count] > 0) {
        // Update the photo property
        self.photo = self.photos[self.currentPhotoIndex];
        // Get the value for the key image from the photo object
        PFFile *file = self.photo[kKHPhotoPictureKey];
        
        // Download the file
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                // Convert the NSData object we get back to a UIImage
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                // Update the view
                [self updateView];
            }
            else{
                NSLog(@"Error downloading image: %@", error);
            }
        }];
        
        // Check if we already have likes in our Activity class
        PFQuery *queryForLike = [PFQuery queryWithClassName:kKHActivityClassKey];
        [queryForLike whereKey:kKHActivityTypeKey equalTo:kKHActivityTypeLikeKey];
        [queryForLike whereKey:kKHActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kKHActivityFromUserKey equalTo:[PFUser currentUser]];
        
        // Check if we already have dislikes in our Activity class
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kKHActivityClassKey];
        [queryForLike whereKey:kKHActivityTypeKey equalTo:kKHActivityTypeDislikeKey];
        [queryForLike whereKey:kKHActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kKHActivityFromUserKey equalTo:[PFUser currentUser]];
        
        // Create a query of both the dislike and the like query
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                self.activities = [objects mutableCopy];
                
                // If we get no objects back, the current user hasn't liked or disliked the photo
                if ([self.activities count] == 0) {
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                }
                else{
                    PFObject *activity = self.activities[0];
                    
                    if ([activity[kKHActivityTypeKey] isEqualToString:kKHActivityTypeLikeKey]) {
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    }
                    else if ([activity[kKHActivityTypeKey] isEqualToString:kKHActivityTypeDislikeKey]){
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    }
                    else{
                        // Some other type of activity
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
            }
        }];
    }
}

// Helper method to update the labels
-(void)updateView
{
    self.firstNameLabel.text = self.photo[kKHPhotoUserKey][kKHUserProfileKey][kKHUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",self.photo[kKHPhotoUserKey][kKHUserProfileKey][kKHUserProfileAgeKey]];
    self.tagLineLabel.text = [NSString stringWithFormat:@"%@",self.photo[kKHUserProfileKey][kKHUserProfileKey][kKHUserTagLineKey]];
}

// Helper method to go to the next photo
-(void)setupNextPhoto
{
    // Check if the next index exist
    if (self.currentPhotoIndex +1 < self.photos.count) {
        // Add 1 to the current Index and call the method queryForCurerntPhotoIndex to get the next photo
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No more users to view" message:@"Check back later for more people!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

// Helper method to save a like
-(void)saveLike
{
    // New Parse object to save the likes in
    PFObject *likeActivity = [PFObject objectWithClassName:kKHActivityClassKey];
    [likeActivity setObject:kKHActivityTypeLikeKey forKey:kKHActivityTypeKey];
    // Link that the photo is liked by the current user
    [likeActivity setObject:[PFUser currentUser] forKey:kKHActivityFromUserKey];
    // Which user owns the photo? Save the user that we liked
    [likeActivity setObject:[self.photo objectForKey:kKHPhotoUserKey] forKey:kKHActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kKHPhotoClassKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // After saving...
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        
        // Add the activity to the activities array and setup the next photo
        [self.activities addObject:likeActivity];
        [self setupNextPhoto];
    }];
}

// Helper method to save a dislike
-(void)saveDislike
{
    PFObject *dislikeActivity = [PFObject objectWithClassName:kKHActivityClassKey];
    [dislikeActivity setObject:kKHActivityTypeDislikeKey forKey:kKHActivityTypeKey];
    
    // Save the user that likes the photo, the user that owns the photo and the photo itself
    [dislikeActivity setObject:[PFUser currentUser] forKey:kKHActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kKHPhotoUserKey] forKey:kKHActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kKHPhotoClassKey];
    
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject: dislikeActivity];
        [self setupNextPhoto];
    }];
}

-(void)checkLike
{
    // If a user liked a photo, show the next photo and return
    if (self.isLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    // If a user disliked a photo at first, but likes it now
    // delete the dislike from the activities object in Parse
    else if (self.isLikedByCurrentUser){
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        // Delete the last added activity object from our array
        [self.activities removeLastObject];
        // Save the like using the saveLike method
        [self saveLike];
    }
    else{
        [self saveLike];
    }
    
}


-(void)checkDislike
{
    if (self.isDislikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    // If the user has liked a photo first, but now dislikes it
    // delete the like from the activities object in Parse
    else if (self.isLikedByCurrentUser){
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else{
        [self saveDislike];
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
