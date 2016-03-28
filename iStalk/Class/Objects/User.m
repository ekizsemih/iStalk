//
//  User.m
//  iStalk
//
//  Created by Semih EKIZ on 06/01/16.
//  Copyright © 2016 Semih EKIZ. All rights reserved.
//

#import "User.h"

@implementation User
- (id) init{
    if (self = [super init]){
        
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_userId forKey:@"userId"];
    [aCoder encodeObject:_nameSurname forKey:@"nameSurname"];
    [aCoder encodeObject:_accesstoken forKey:@"accessToken"];
    [aCoder encodeObject:_accesstokensecret forKey:@"accessTokenSecret"];
    [aCoder encodeObject:_imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:_profileUrl forKey:@"profileUrl"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _userId = [aDecoder decodeObjectForKey:@"userId"];
        _nameSurname = [aDecoder decodeObjectForKey:@"nameSurname"];
        _accesstoken = [aDecoder decodeObjectForKey:@"accessToken"];
        _accesstokensecret = [aDecoder decodeObjectForKey:@"accessTokenSecret"];
        _imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
        _profileUrl = [aDecoder decodeObjectForKey:@"profileUrl"];
    }
    return self;
}

@end