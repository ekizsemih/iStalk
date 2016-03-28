//
//  Identity.h
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Identity : NSObject <NSCoding>
@property (nonatomic, strong) NSString *authtoken;
@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *nameSurname;
@property (nonatomic, strong) NSString *passWord;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *fbid,*twid,*fsid,*insid;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) NSString *fbToken;
@property (nonatomic, strong) NSString *fsToken;
@property (nonatomic, strong) NSString *insToken;
@property (nonatomic, strong) NSString *twToken,*twSecret;
@property (nonatomic, strong) NSNumber *loginFlag;
@property (nonatomic) BOOL reset_me;

@end