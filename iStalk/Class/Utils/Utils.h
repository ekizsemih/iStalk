//
//  Utils.h
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, DateFormat) {
    DateFormatOnlyDate = 0,
    DateFormatDateTime = 1,
    DateFormatOnlyHours = 2,
    DateFormatMatchDateTitle = 3,
    DateFormatDayName = 4,
    DateFormatDayNameShort = 5,
    DateFormatTwitter = 6
};

@interface Utils : NSObject
typedef enum {
    loginWithFb = 0,
    login = 1,
    checkuser = 2,
    createuser = 3,
    updatedevicetoken = 4,
    updateuser = 5,
    logout = 6,
    updatetoken = 7,
    getuseraccesstoken = 8
} Api;

+ (void)setRootViewController:(NSString *)identifier;
+ (id) objForPrefKey: (NSString *) key;
+ (void)setObject: (id) obj forPrefKey: (NSString *) key;
+ (void)synchronize;

+ (NSURL *)defaultApiBaseURL;
+ (NSString *)defaultApiBaseURLString;
+ (NSString *)localizedString: (NSString *) key;
+ (id) jsonWithData: (NSData *) data error: (NSError **) error;

+ (NSString *)getApiPath: (Api) api;
+ (NSDateComponents *)betweeTwoDates:(NSDate *)StartDate withEndDate:(NSDate *)EndDate;
+ (NSDateComponents *)getDateComponents:(NSDate *)date;
+ (NSString *)timeStringBetweenDates: (NSDate *) d1 : (NSDate *) d2;
+ (NSDate *) dateFromString: (NSString *) string;
+ (NSString *)stringFromDate: (NSDate *)date option: (DateFormat) option;
+ (NSString *)dateFormatterText:(NSDate *)date;

+ (NSOperation *)callApi:(NSString *)link params:(NSString *)params integer:(int)value withType:(int)type success: (void (^) (id responseObject)) success failure: (void (^) (NSError *error)) failure;
+ (NSOperation *)callPostApi:(Api)api params:(id)params integer:(int)value withType:(int)type progress:(void (^)(id))progress success:(void (^) (id responseObject)) success failure:(void (^)(NSError *error))failure;
+ (void)flurry:(NSString *)logEvent withlogError:(NSString *)logError;
+ (NSData *)imageDataSize:(UIImage *)image;
+ (NSData *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIView *)loadingFunction:(int)color;
+ (NSMutableArray *)loadingArray:(int)value;
+ (NSString*)deviceName;
@end

@interface Utils (String)

+ (BOOL) stringIsEmpty: (NSString *) string;
+ (NSString *)base64forData:(NSData*)theData;
+ (NSString *) trimString: (NSString *) string;
+ (BOOL) stringIsValidEmail:(NSString *)checkString;
+ (BOOL) stringIsValidPassword:(NSString *)password;
+ (NSString*) decodeURLString:(NSString *) string;

+ (float) screenWidth;
+ (float) screenHeight;

@end

@interface NSString (Custom)

- (BOOL) isEmpty;
- (NSString *) trimmed;
- (NSString *) encodedURLComponents;
- (NSString *) decodedURLComponents;
- (NSString *) urlEncodeUsingEncoding:(NSStringEncoding)encoding;

@end

@interface Utils (FileAndPaths)

+ (NSString *) documentsDirectory;
+ (NSString *) photosDirectory;
+ (NSString *) dataDirectory;
+ (NSString *) messageFilesDirectory;
+ (NSString *) footwallDirectory;

+ (void) deleteAllUserFiles;
+ (void)deleteAllObjects:(NSString *) entityDescription;
+ (void) writeDataToFile: (NSData *) data directory: (NSString *) dir name: (NSString *) fileName;

@end
@interface NSDate (Utils)

+(NSString *) dateFormatted:(NSDate *)date;

@end