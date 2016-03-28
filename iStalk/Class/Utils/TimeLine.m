//
//  TimeLine.m
//  iStalk
//
//  Created by Semih EKIZ on 06/01/16.
//  Copyright © 2016 Semih EKIZ. All rights reserved.
//

#import "TimeLine.h"

@implementation TimeLine

+ (instancetype)facebookTimeLine:(id)params {
    TimeLine *timeLine = [TimeLine new];
   
    
    return timeLine;
}

+ (instancetype)twitterTimeLine:(id)params {
    TimeLine *timeline = [TimeLine new];
    NSLog(@"%@",params);
    if ([params objectForKey:@"retweeted_status"]) {
        timeline.retweet = TRUE;
        timeline.profileImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@/profile_image?size=original",[[[params objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"]]];
        timeline.nameSurname = [[[params objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"name"];
        timeline.userName = [[[params objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"];
        timeline.text = [[params objectForKey:@"retweeted_status"] objectForKey:@"text"];
        timeline.retweetsCount = [[params objectForKey:@"retweeted_status"] objectForKey:@"retweet_count"];
        timeline.favsCount = [[params objectForKey:@"retweeted_status"] objectForKey:@"favorite_count"];
        timeline.retweetUserName = [[params objectForKey:@"user"] objectForKey:@"screen_name"];
    }else{
        timeline.retweet = FALSE;
        timeline.profileImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@/profile_image?size=original",[[params objectForKey:@"user"] objectForKey:@"screen_name"]]];
        timeline.nameSurname = [[params objectForKey:@"user"] objectForKey:@"name"];
        timeline.userName = [[params objectForKey:@"user"] objectForKey:@"screen_name"];
        timeline.text = [params objectForKey:@"text"];
        timeline.retweetsCount = [params objectForKey:@"retweet_count"];
        timeline.favsCount = [params objectForKey:@"favorite_count"];
        timeline.retweetUserName = [[params objectForKey:@"user"] objectForKey:@"screen_name"];
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE LLL dd HH:mm:ss ZZZ yyyy"];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSDate *date = [df dateFromString:[params objectForKey:@"created_at"]];
    timeline.createDate = date;
    return timeline;
}

+ (instancetype)foursquareTimeLine:(id)params {
    TimeLine *timeline = [TimeLine new];
    
    timeline.nameSurname = @"Semih EKİZ";
    NSLog(@"%@",[params objectForKey:@"shout"]);
    timeline.text = [NSString stringWithFormat:@"%@ at %@",[params objectForKey:@"shout"]?[params objectForKey:@"shout"] : @"", [[params objectForKey:@"venue"] objectForKey:@"name"]];
    timeline.address = [NSString stringWithFormat:@"%@ %@",[[[params objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"address"],[[[params objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"state"]];
//    timeline.profileImageUrl = [NSURL URLWithString:fsToken.imageUrl];
    timeline.likesCount = [[params objectForKey:@"likes"] objectForKey:@"count"];
    timeline.commentsCount = [[params objectForKey:@"comments"] objectForKey:@"count"];
    
    if ([[[params objectForKey:@"photos"] objectForKey:@"count"] integerValue]>0)
        timeline.imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@600x600%@",[[[[params objectForKey:@"photos"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"prefix"],[[[[params objectForKey:@"photos"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"suffix"]]];
    timeline.createDate = [NSDate dateWithTimeIntervalSince1970:[[params objectForKey:@"createdAt"] floatValue]];
    
    return timeline;
}

+ (instancetype)instagramTimeLine:(id)params {
    TimeLine *timeline = [TimeLine new];
    
    timeline = [TimeLine new];
    timeline.commentsArray = [NSMutableArray new];
    timeline.userName = [[params objectForKey:@"user"] objectForKey:@"username"];
    timeline.profileImageUrl = [NSURL URLWithString:[[params objectForKey:@"user"] objectForKey:@"profile_picture"]];
    timeline.link = [NSURL URLWithString:[params objectForKey:@"link"]];
    timeline.imageUrl = [NSURL URLWithString:[[[params objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"]];
    timeline.likesCount = [[params objectForKey:@"likes"] objectForKey:@"count"];
    timeline.createDate = [NSDate dateWithTimeIntervalSince1970:[[params objectForKey:@"created_time"] floatValue]];
    
    id dataLikes = [[params objectForKey:@"likes"] objectForKey:@"data"];
    if ([[[params objectForKey:@"likes"] objectForKey:@"count"] integerValue] != 0) {
        NSString *strLikes = @"";
        for (int z=0; z<[dataLikes count]; z++) {
            strLikes = [NSString stringWithFormat:@"%@, %@",strLikes, [[dataLikes objectAtIndex:z] objectForKey:@"username"]];
        }
        if ([timeline.likesCount integerValue] - [dataLikes count] != 0)
            strLikes = [NSString stringWithFormat:@"%@ %@ %ld %@",strLikes, [Utils localizedString:@"ITAnd"], [timeline.likesCount integerValue] - [dataLikes count], [Utils localizedString:@"ITLikesText"]];
        strLikes = [strLikes substringFromIndex:2];
        timeline.likes = strLikes;
    }else
        timeline.likes = [Utils localizedString:@"ITLikeDesc"];
    
    id dataComments = [[params objectForKey:@"comments"] objectForKey:@"data"];
    if ([[[params objectForKey:@"comments"] objectForKey:@"count"] integerValue] != 0) {
        timeline.commentsCount = [NSString stringWithFormat:@"%lu",[dataComments count] - [[[params objectForKey:@"comments"] objectForKey:@"count"] integerValue]];
        NSArray* dataCommentsReversed = [[dataComments reverseObjectEnumerator] allObjects];
        for (int z=0; z<[dataCommentsReversed count]; z++) {
            [timeline.commentsArray addObject:@{
                                                @"username":[[[dataCommentsReversed objectAtIndex:z] objectForKey:@"from"] objectForKey:@"username"],
                                                @"text":[[dataCommentsReversed objectAtIndex:z] objectForKey:@"text"]
                                                }];
        }
    }else
        timeline.commentsCount = @"0";
    
    if (![Utils stringIsEmpty:[NSString stringWithFormat:@"%@",[params objectForKey:@"caption"]]])
        [timeline.commentsArray addObject:@{
                                            @"username":[[[params objectForKey:@"caption"] objectForKey:@"from"] objectForKey:@"username"],
                                            @"text":[[params objectForKey:@"caption"] objectForKey:@"text"]
                                            }];

    return timeline;
}

@end