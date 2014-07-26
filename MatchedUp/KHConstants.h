//
//  KHConstants.h
//  MatchedUp
//
//  Created by Koen Hendriks on 12/07/14.
//  Copyright (c) 2014 Koen Hendriks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHConstants : NSObject

#pragma mark - User Class

extern NSString *const kKHUserTagLineKey;

extern NSString *const kKHUserProfileKey;
extern NSString *const kKHUserProfileNameKey;
extern NSString *const kKHUserProfileFirstNameKey;
extern NSString *const kKHUserProfileLocation;
extern NSString *const kKHUserProfileGender;
extern NSString *const kKHUserProfileBirthday;
extern NSString *const kKHUserProfileInterestedIn;
extern NSString *const kKHUserProfilePictureURL;
extern NSString *const kKHUserProfileRelationshipStatusKey;
extern NSString *const kKHUserProfileAgeKey;


#pragma mark - Photo Class

extern NSString *const kKHPhotoClassKey;
extern NSString *const kKHPhotoUserKey;
extern NSString *const kKHPhotoPictureKey;

#pragma mark - Activity Class

extern NSString *const kKHActivityClassKey;
extern NSString *const kKHActivityTypeKey;
extern NSString *const kKHActivityFromUserKey;
extern NSString *const kKHActivityToUserKey;
extern NSString *const kKHActivityPhotoKey;
extern NSString *const kKHActivityTypeLikeKey;
extern NSString *const kKHActivityTypeDislikeKey;

@end
