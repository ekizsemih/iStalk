//
//  Identity.m
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "Identity.h"
#import "User.h"

@implementation Identity

- (void)setAuthtoken:(NSString *)authtoken {
    _authtoken = authtoken;
    _reset_me = YES;
}

- (void)setUserid:(NSNumber *)userid {
    _userid = userid;
    _reset_me = YES;
}

- (void)setFbid:(NSString *)fbid {
    _fbid = fbid;
    _reset_me = YES;
}

- (void)setInsid:(NSString *)insid {
    _insid = insid;
    _reset_me = YES;
}

- (void)setFsid:(NSString *)fsid {
    _fsid = fsid;
    _reset_me = YES;
}

- (void)setTwid:(NSString *)twid {
    _twid = twid;
    _reset_me = YES;
}

- (void)setUsername:(NSString *)username {
    _username = username;
    _reset_me = YES;
}

- (void)setNameSurname:(NSString *)nameSurname {
    _nameSurname = nameSurname;
    _reset_me = YES;
}

- (void)setPassWord:(NSString *)passWord{
    _passWord = passWord;
    _reset_me = YES;
}

- (void)setGender:(NSNumber *)gender {
    _gender = gender;
    _reset_me = YES;
}

- (void)setEmail:(NSString *)email {
    _email = email;
    _reset_me = YES;
}

- (void)setImagePath:(NSString *)imagePath {
    _imagePath = imagePath;
    _reset_me = YES;
}

- (void)setImageData:(NSData *)imageData {
    _imageData = imageData;
    _reset_me = YES;
}

- (void)setFbToken:(NSString *)fbToken {
    _fbToken = fbToken;
    _reset_me = YES;
}

- (void)setTwToken:(NSString *)twToken {
    _twToken = twToken;
    _reset_me = YES;
}

- (void)setTwSecret:(NSString *)twSecret {
    _twSecret = twSecret;
    _reset_me = YES;
}

- (void)setFsToken:(NSString *)fsToken {
    _fsToken = fsToken;
    _reset_me = YES;
}

- (void)setInsToken:(NSString *)insToken {
    _insToken = insToken;
    _reset_me = YES;
}

- (void)setUserToken:(NSString *)userToken {
    _userToken = userToken;
    _reset_me = YES;
}

- (void)setLoginFlag:(NSNumber *)loginFlag{
    _loginFlag = loginFlag;
    _reset_me = YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.authtoken forKey: @"p0"];
    [aCoder encodeObject:self.userid forKey:@"p1"];
    [aCoder encodeObject:self.username forKey:@"p2"];
    [aCoder encodeObject:self.gender forKey:@"p3"];
    [aCoder encodeObject:self.email forKey:@"p4"];
    [aCoder encodeObject:self.imagePath forKey:@"p5"];
    [aCoder encodeObject:self.passWord forKey:@"p6"];
    [aCoder encodeObject:self.imageData forKey:@"p7"];
    [aCoder encodeObject:self.fbToken forKey:@"p8"];
    [aCoder encodeObject:self.twToken forKey:@"p9"];
    [aCoder encodeObject:self.twSecret forKey:@"p10"];
    [aCoder encodeObject:self.userToken forKey:@"p11"];
    [aCoder encodeObject:self.loginFlag forKey:@"p12"];
    [aCoder encodeObject:self.nameSurname forKey:@"p13"];
    [aCoder encodeObject:self.fsToken forKey:@"p14"];
    [aCoder encodeObject:self.insToken forKey:@"p15"];
    [aCoder encodeObject:self.fbid forKey:@"p16"];
    [aCoder encodeObject:self.fsid forKey:@"p17"];
    [aCoder encodeObject:self.twid forKey:@"p18"];
    [aCoder encodeObject:self.insid forKey:@"p19"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super init])) {
        self.authtoken = [aDecoder decodeObjectForKey:@"p0"];
        self.userid = [aDecoder decodeObjectForKey:@"p1"];
        self.username = [aDecoder decodeObjectForKey:@"p2"];
        self.gender = [aDecoder decodeObjectForKey:@"p3"];
        self.email = [aDecoder decodeObjectForKey:@"p4"];
        self.imagePath = [aDecoder decodeObjectForKey:@"p5"];
        self.passWord = [aDecoder decodeObjectForKey:@"p6"];
        self.imageData = [aDecoder decodeObjectForKey:@"p7"];
        self.fbToken = [aDecoder decodeObjectForKey:@"p8"];
        self.twToken = [aDecoder decodeObjectForKey:@"p9"];
        self.twSecret = [aDecoder decodeObjectForKey:@"p10"];
        self.userToken = [aDecoder decodeObjectForKey:@"p11"];
        self.loginFlag = [aDecoder decodeObjectForKey:@"p12"];
        self.nameSurname = [aDecoder decodeObjectForKey:@"p13"];
        self.fsToken = [aDecoder decodeObjectForKey:@"p14"];
        self.insToken = [aDecoder decodeObjectForKey:@"p15"];
        self.fbid = [aDecoder decodeObjectForKey:@"p16"];
        self.fsid = [aDecoder decodeObjectForKey:@"p17"];
        self.twid = [aDecoder decodeObjectForKey:@"p18"];
        self.insid = [aDecoder decodeObjectForKey:@"p19"];
        
        
        self.reset_me = NO;
    }
    return self;
}
@end
