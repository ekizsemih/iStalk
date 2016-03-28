//
//  Timeline.h
//  iStalk
//
//  Created by Semih EKIZ on 06/01/16.
//  Copyright © 2016 Semih EKIZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timeline : NSObject
@property (nonatomic, strong) NSURL * imageUrl, * profileImageUrl, * link;
@property (nonatomic, strong) NSString * likes, * retweetUserName, * nameSurname, * userName, * likesCount, * commentsCount, * retweetsCount, * favsCount, * text, * errorMessage, * objectId,* address;
@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) NSMutableArray * commentsArray;
@property (nonatomic) BOOL retweet;
@end