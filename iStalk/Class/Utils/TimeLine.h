//
//  TimeLine.h
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeLine : NSObject

+ (instancetype)facebookTimeLine:(id)params;
+ (instancetype)twitterTimeLine:(id)params;
+ (instancetype)foursquareTimeLine:(id)params;
+ (instancetype)instagramTimeLine:(id)params;

@property (nonatomic, strong) NSURL * imageUrl, * profileImageUrl, * link;
@property (nonatomic, strong) NSString * likes, * retweetUserName, * nameSurname, * userName, * likesCount, * commentsCount, * retweetsCount, * favsCount, * text, * errorMessage, * objectId,* address;
@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) NSMutableArray * commentsArray;
@property (nonatomic) BOOL retweet;

@end

