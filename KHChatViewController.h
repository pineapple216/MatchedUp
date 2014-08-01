//
//  KHChatViewController.h
//  MatchedUp
//
//  Created by Koen Hendriks on 28/07/14.
//  Copyright (c) 2014 Koen Hendriks. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface KHChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) PFObject *chatRoom;


@end
