//
//  User.h
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic, strong) NSNumber * userId;
@property (nonatomic, strong) NSString * nameSurname, *accesstoken, *accesstokensecret;
@property (nonatomic, strong) NSString * imageUrl,* profileUrl;
@end