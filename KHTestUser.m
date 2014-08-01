//
//  KHTestUser.m
//  MatchedUp
//
//  Created by Koen Hendriks on 26/07/14.
//  Copyright (c) 2014 Koen Hendriks. All rights reserved.
//

#import "KHTestUser.h"

@implementation KHTestUser

+(void)saveTestUserToParse
{
    // Create a new user
    PFUser *newUser = [PFUser user];
    
    // Give the new user a username and a password
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Create a user Profile
            NSDictionary *profile = @{@"age" : @24, @"birthday" : @"11/22/1990", @"firstName" : @"Julie", @"gender" : @"female", @"location" : @"Berlin, Germany", @"name" : @"Julie Adams"};
            [newUser setObject:profile forKey:@"profile"];
            
            // Save the new User and give the user a profile image, after saving
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                UIImage *profileImage = [UIImage imageNamed:@"profileImage1.jpg"];
                NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                PFFile *photoFile = [PFFile fileWithData:imageData];
                
                // Save the photoFile to Parse and assign it to the new user we just created
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        PFObject *photo = [PFObject objectWithClassName:kKHPhotoClassKey];
                        [photo setObject:newUser forKey:kKHPhotoUserKey];
                        [photo setObject:photoFile forKey:kKHPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"Test User photo saved succesfully!");
                            if (error) {
                                NSLog(@"Error saving photo: %@", error);
                            }
                        }];
                    }
                }];
            }];
        }
    }];
}

@end
