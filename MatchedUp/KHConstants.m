//
//  KHConstants.m
//  MatchedUp
//
//  Created by Koen Hendriks on 12/07/14.
//  Copyright (c) 2014 Koen Hendriks. All rights reserved.
//

#import "KHConstants.h"

@implementation KHConstants

#pragma mark - User Class

NSString *const kKHUserTagLineKey                   = @"tagLine";

NSString *const kKHUserProfileKey                   = @"profile";
NSString *const kKHUserProfileNameKey               = @"name";
NSString *const kKHUserProfileFirstNameKey          = @"firstName";
NSString *const kKHUserProfileLocation              = @"location";
NSString *const kKHUserProfileGender                = @"gender";
NSString *const kKHUserProfileBirthday              = @"birthday";
NSString *const kKHUserProfileInterestedIn          = @"interestedIn";
NSString *const kKHUserProfilePictureURL            = @"pictureURL";
NSString *const kKHUserProfileRelationshipStatusKey = @"relationshipStatus";
NSString *const kKHUserProfileAgeKey                = @"age";


#pragma mark - Photo Class

NSString *const kKHPhotoClassKey            = @"Photo";
NSString *const kKHPhotoUserKey             = @"user";
NSString *const kKHPhotoPictureKey          = @"image";

#pragma mark - Activity Class

NSString *const kKHActivityClassKey         = @"Activity";
NSString *const kKHActivityTypeKey          = @"type";
NSString *const kKHActivityFromUserKey      = @"fromUser";
NSString *const kKHActivityToUserKey        = @"toUser";
NSString *const kKHActivityPhotoKey         = @"photo";
NSString *const kKHActivityTypeLikeKey      = @"like";
NSString *const kKHActivityTypeDislikeKey   = @"dislike";


@end
