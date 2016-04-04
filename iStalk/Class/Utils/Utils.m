//
//  Utils.m
//  iStalk
//
//  Created by Semih EKIZ on 30/11/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "Utils.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "AFNetworking.h"
#import <sys/utsname.h>

extern NSManagedObjectContext *getDBCtx();
@implementation Utils
static const char * const apiPaths [] = {
    "loginwithfb.php",
    "login.php",
    "checkuser.php",
    "createuser.php",
    "updatedevicetoken.php",
    "updateuser.php",
    "logout.php",
    "updatetoken.php",
    "getuseraccesstoken.php"
};

+ (BOOL)stringIsValidEmail:(NSString *)checkString {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject: checkString];
    
}

+ (BOOL)stringIsValidPassword:(NSString *)password{
    NSCharacterSet * characterSet = [NSCharacterSet uppercaseLetterCharacterSet] ;
    NSRange range = [password rangeOfCharacterFromSet:characterSet] ;
    if (range.location == NSNotFound) {
        return NO ;
    }
    characterSet = [NSCharacterSet lowercaseLetterCharacterSet] ;
    range = [password rangeOfCharacterFromSet:characterSet] ;
    if (range.location == NSNotFound) {
        return NO ;
    }
    
    characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"] ;
    for (NSUInteger i = 0; i < [password length]; ++i) {
        unichar uchar = [password characterAtIndex:i] ;
        if (![characterSet characterIsMember:uchar]) {
            return NO ;
        }
    }
    return YES ;
}

+ (NSString*)base64forData:(NSData*)theData {
    return [theData base64EncodedStringWithOptions: 0];
}

+ (void)synchronize {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setObject: (id) obj forPrefKey: (NSString *) key {
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey: key];
}

+ (id)objForPrefKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (NSString *)localizedString:(NSString *)key {
    return NSLocalizedString(key, nil);
}

+ (NSString *)trimString:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
}

+ (BOOL)stringIsEmpty:(NSString *)string {
    return [[NSNull null] isEqual: string] || string == nil || [[self trimString:string] isEqualToString:@""] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"] || [string isEqualToString:@"-"];
}

+ (NSString*)decodeURLString:(NSString *) string {
    if (![string isKindOfClass: [NSString class]] || !string || [[NSNull null] isEqual: string])
        return @"";
    else
    return (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(__bridge CFStringRef) string,
                                                                                         CFSTR(""),
                                                                                         kCFStringEncodingUTF8);
}

+ (id)jsonWithData:(NSData *)data error: (NSError **) error {
    return [NSJSONSerialization JSONObjectWithData: data options:0 error:error];
}

+ (NSDateComponents *)betweeTwoDates:(NSDate *)StartDate withEndDate:(NSDate *)EndDate {
    return [[NSCalendar currentCalendar] components: NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate: StartDate toDate:EndDate options: 0];
}

+ (NSDateComponents *)getDateComponents:(NSDate *)date {
   return [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
}

+ (NSString *) timeStringBetweenDates: (NSDate *) d1 : (NSDate *) d2 {
    NSInteger timeInterval = [d2 timeIntervalSinceDate: d1];
    NSInteger seconds = timeInterval % 60;
    NSInteger total_mins = (NSInteger)(timeInterval/60.0);
    NSInteger mins =  total_mins % 60;
    NSInteger total_hours =  (NSInteger)(total_mins / 60.0);
    NSInteger hours  = total_hours % 24;
    NSInteger total_days = (NSInteger)((total_hours - hours)/24.0);
    NSInteger days = total_days % 7;
    NSInteger weeks = (NSInteger)((total_days - days)/7.0);
    
    NSString * timeString = @"";
    if (weeks > 0)
        timeString = [NSString stringWithFormat:[Utils localizedString:@"ITWeek"], (long)weeks];
    else if (days > 0)
        timeString = [NSString stringWithFormat:[Utils localizedString:@"ITDay"], (long)days];
    else if (hours > 0)
        timeString = [NSString stringWithFormat:[Utils localizedString:@"ITHour"], (long)hours];
    else if (mins > 0)
        timeString = [NSString stringWithFormat:[Utils localizedString:@"ITMinute"], (long)mins];
    else if (seconds > 0)
        timeString = [NSString stringWithFormat:[Utils localizedString:@"ITSecond"], (long)seconds];
    
    return timeString;
}

+ (NSString *)dateFormatted:(NSDate *)date{
    NSCalendar *miladi = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour;
    
    NSDateComponents *ageCalc = [miladi components:unitFlags fromDate:date];
    
    NSString *output = [NSString stringWithFormat:@"%.2ld.%.2ld.%.4ld",(long)[ageCalc day],(long)[ageCalc month],(long)[ageCalc year]];
    return output;
}

+ (NSDate *)dateFromString:(NSString *)string {
    if ([Utils stringIsEmpty: string])
        return nil;
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setTimeZone: [NSTimeZone timeZoneWithName:@"UTC"]];
    [df setLocale: [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [df setDateFormat: @"yyyy-MM-dd hh:mm:ss a z"];
    
    NSDate *date = [df dateFromString: string];
    df = nil;
    return date;
}

+ (NSString *)stringFromDate: (NSDate *)date option: (DateFormat) option {
    NSArray * const formatOptions = @[@"dd.MM.yyyy", @"dd.MM.yyyy HH:mm", @"HH:mm", @"dd MMMM EEEE", @"EEEE", @"EEE",@"EEE LLL dd HH:mm:ss ZZZ yyyy"];
    NSDateFormatter *df = [NSDateFormatter new];
    
    [df setLocale: [[NSCalendar currentCalendar] locale]];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    [df setDateFormat: [formatOptions objectAtIndex: option]];
    
    NSString *dateString = [df stringFromDate: date];
    
    df = nil;
    
    return dateString;
}

+ (NSString *)dateFormatterText:(NSDate *)date{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"tr_TR"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = locale;
    [formatter setDateFormat:@"dd MMMM yyyy, HH:mm"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

+ (NSData *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    CGFloat compression = 0.5f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 250*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    return imageData;
}

+ (NSData *)imageDataSize:(UIImage *)image{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.9;
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return imageData;
    
}

+ (NSOperation *)callPostApi:(Api)api params:(id)params integer:(int)value withType:(int)type progress:(void (^)(id))progress success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    if (type == 0)
        [LoadingView show];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@",[self defaultApiBaseURL],[self getApiPath:api]] parameters:params error:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSLog(@"Link:%@",operation.request.URL.absoluteString);
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        if (progress) {
            id prgrss = @{@"bytesWritten":@(bytesWritten),
                          @"totalBytesWritten":@(totalBytesWritten),
                          @"totalBytesExpectedToWrite":@(totalBytesExpectedToWrite)
                          };
            progress(prgrss);
        }
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success){
            if (type == 0)
                [LoadingView hide];
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (type == 0)
            [LoadingView hide];
        if (failure) {
            failure(error);
            if (value == 1) {
                return;
            }
            if (error.code == -1009) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Utils localizedString:@"ITAttention"]
                                                                message:[Utils localizedString:@"ITAttention_Message_1"]
                                                               delegate:self
                                                      cancelButtonTitle:[Utils localizedString:@"ITOk"]
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
            else if (error.code == -1012) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:[Utils localizedString:@"ITAttention_Message_2"]
                                                               delegate:self
                                                      cancelButtonTitle:[Utils localizedString:@"ITOk"]
                                                      otherButtonTitles:nil, nil];
                alert.tag = 1;
                [alert show];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:[Utils localizedString:@"ITAttention_Message_3"]
                                                               delegate:self
                                                      cancelButtonTitle:[Utils localizedString:@"ITOk"]
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
    }];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [operation start];
    });
    
    return operation;
}

+ (NSOperation *)callApi:(NSString *)link params:(NSString *)params integer:(int)value withType:(int)type success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    if (type == 0)
        [LoadingView show];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    NSMutableURLRequest *request = [serializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat:@"%@%@",link,params] parameters:nil error:nil];
    [request setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *operation =  [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success){
            if (type == 0)
                [LoadingView hide];
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (type == 0)
            [LoadingView hide];
        if (failure) {
            failure(error);
            if (value == 1) {
                return;
            }
            if (error.code == -1009) {
                //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Utils localizedString:@"ITAttention"]
                //                                                                message:[Utils localizedString:@"ITAttention_Message_1"]
                //                                                               delegate:self
                //                                                      cancelButtonTitle:[Utils localizedString:@"ITOk"]
                //                                                      otherButtonTitles:nil, nil];
                //                [alert show];
            }
            else if (error.code == -1012) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:[Utils localizedString:@"ITAttention_Message_2"]
                                                               delegate:self
                                                      cancelButtonTitle:[Utils localizedString:@"ITOk"]
                                                      otherButtonTitles:nil, nil];
                alert.tag = 1;
                [alert show];
            }
            //            else{
            //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
            //                                                                message:[Utils localizedString:@"ITAttention_Message_3"]
            //                                                               delegate:self
            //                                                      cancelButtonTitle:[Utils localizedString:@"ITOk"]
            //                                                      otherButtonTitles:nil];
            //                [alert show];
            //                return;
            //            }
        }
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
    }];
    
    NSLog(@"%@",operation.request.URL.absoluteString);
    
    [operation start];
    return operation;
}

+ (void)flurry:(NSString *)logEvent withlogError:(NSString *)logError{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [Flurry logEvent:logEvent timed:YES];
        [Flurry logError:logError message:@"ERROR_MESSAGE" exception:nil];
    });
}

+ (NSString *)getApiPath: (Api) api {
    return  [NSString stringWithCString:apiPaths [(int)api] encoding: NSUTF8StringEncoding];
}

+ (NSString *)defaultApiBaseURLString{
    return appWebServiceBaseUrl;
}

+ (NSURL *)defaultApiBaseURL{
    return [NSURL URLWithString:[self defaultApiBaseURLString]];
}

+ (void)setRootViewController:(NSString *)identifier{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UINavigationController *navigationController = (UINavigationController *)[keyWindow rootViewController];
    UIStoryboard *mainStoryboard = [navigationController storyboard];
    
    if ([identifier isEqualToString:@"mainlogincontroller"]) {
        LoginViewController *maincontroller = [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
        navigationController.viewControllers = @[maincontroller];
        return;
    }
    
    UIViewController *maincontroller = [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
    navigationController.viewControllers = @[maincontroller];
}

+ (float)screenHeight{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    return screenHeight;
}

+ (float)screenWidth{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    return screenWidth;
}

+ (UIView *)loadingFunction:(int)color{
    UIView *DisabledView = [[UIView alloc] initWithFrame:CGRectMake(([Utils screenWidth]-100)/2, ([Utils screenHeight]-100)/2-49, 100.0, 100.0)];
    DisabledView.layer.cornerRadius = 5;
    DisabledView.layer.masksToBounds = YES;
    [DisabledView setBackgroundColor:COLOR_RGBA(color, color, color, 0.5)];
    
    UIActivityIndicatorView *SearchBarIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(75/2, 30, 25.0f, 25.0f)];
    [SearchBarIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [DisabledView addSubview:SearchBarIndicator];
    [SearchBarIndicator startAnimating];
    
    UILabel *labelLoading = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 100, 20)];
    labelLoading.backgroundColor = [UIColor clearColor];
    labelLoading.textColor = [UIColor whiteColor];
    labelLoading.text = @"Yükleniyor...";
    // labelLoading.font = [UIFont fontWithName:@"Europe" size:16];
    labelLoading.textAlignment = NSTextAlignmentCenter;
    [DisabledView addSubview:labelLoading];
    
    
    DisabledView.tag = 10000;
    return DisabledView;
}

+ (NSMutableArray *)loadingArray:(int)value{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 1; i < 23; i++) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.%d",value,i]];
        [images addObject:img];
    }
    return images;
}

+ (NSString*)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSDictionary *commonNamesDictionary =
    @{
      @"i386":     @"iPhone Simulator",
      @"x86_64":   @"iPad Simulator",
      
      @"iPhone1,1":    @"iPhone",
      @"iPhone1,2":    @"iPhone 3G",
      @"iPhone2,1":    @"iPhone 3GS",
      @"iPhone3,1":    @"iPhone 4",
      @"iPhone3,2":    @"iPhone 4(Rev A)",
      @"iPhone3,3":    @"iPhone 4(CDMA)",
      @"iPhone4,1":    @"iPhone 4S",
      @"iPhone5,1":    @"iPhone 5(GSM)",
      @"iPhone5,2":    @"iPhone 5(GSM+CDMA)",
      @"iPhone5,3":    @"iPhone 5c(GSM)",
      @"iPhone5,4":    @"iPhone 5c(GSM+CDMA)",
      @"iPhone6,1":    @"iPhone 5s(GSM)",
      @"iPhone6,2":    @"iPhone 5s(GSM+CDMA)",
      
      @"iPhone7,1":    @"iPhone 6+ (GSM+CDMA)",
      @"iPhone7,2":    @"iPhone 6 (GSM+CDMA)",
      
      @"iPhone8,1":    @"iPhone 6S (GSM+CDMA)",
      @"iPhone8,2":    @"iPhone 6S+ (GSM+CDMA)",
      
      @"iPad1,1":  @"iPad",
      @"iPad2,1":  @"iPad 2(WiFi)",
      @"iPad2,2":  @"iPad 2(GSM)",
      @"iPad2,3":  @"iPad 2(CDMA)",
      @"iPad2,4":  @"iPad 2(WiFi Rev A)",
      @"iPad2,5":  @"iPad Mini 1G (WiFi)",
      @"iPad2,6":  @"iPad Mini 1G (GSM)",
      @"iPad2,7":  @"iPad Mini 1G (GSM+CDMA)",
      @"iPad3,1":  @"iPad 3(WiFi)",
      @"iPad3,2":  @"iPad 3(GSM+CDMA)",
      @"iPad3,3":  @"iPad 3(GSM)",
      @"iPad3,4":  @"iPad 4(WiFi)",
      @"iPad3,5":  @"iPad 4(GSM)",
      @"iPad3,6":  @"iPad 4(GSM+CDMA)",
      
      @"iPad4,1":  @"iPad Air(WiFi)",
      @"iPad4,2":  @"iPad Air(GSM)",
      @"iPad4,3":  @"iPad Air(GSM+CDMA)",
      
      @"iPad5,3":  @"iPad Air 2 (WiFi)",
      @"iPad5,4":  @"iPad Air 2 (GSM+CDMA)",
      
      @"iPad4,4":  @"iPad Mini 2G (WiFi)",
      @"iPad4,5":  @"iPad Mini 2G (GSM)",
      @"iPad4,6":  @"iPad Mini 2G (GSM+CDMA)",
      
      @"iPad4,7":  @"iPad Mini 3G (WiFi)",
      @"iPad4,8":  @"iPad Mini 3G (GSM)",
      @"iPad4,9":  @"iPad Mini 3G (GSM+CDMA)",
      
      @"iPod1,1":  @"iPod 1st Gen",
      @"iPod2,1":  @"iPod 2nd Gen",
      @"iPod3,1":  @"iPod 3rd Gen",
      @"iPod4,1":  @"iPod 4th Gen",
      @"iPod5,1":  @"iPod 5th Gen",
      @"iPod7,1":  @"iPod 6th Gen",
      };
    
    NSString *deviceName = commonNamesDictionary[machineName];
    
    if (deviceName == nil) {
        deviceName = machineName;
    }
    
    return deviceName;
}
@end

@implementation Utils (FileAndPaths)

+ (NSString *)documentsDirectory{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

+ (NSString *)photosDirectory {
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSString *photoPath = [[self documentsDirectory] stringByAppendingPathComponent:@"/photos"];
    
    if (![fileMngr fileExistsAtPath:photoPath]) {
        [fileMngr createDirectoryAtPath:photoPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return photoPath;
}

+ (NSString *)footwallDirectory {
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSString *photoPath = [[self documentsDirectory] stringByAppendingPathComponent:@"/fwall"];
    
    if (![fileMngr fileExistsAtPath:photoPath]) {
        [fileMngr createDirectoryAtPath:photoPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return photoPath;
}

+ (NSString *)dataDirectory {
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSString *dataPath = [[self documentsDirectory] stringByAppendingPathComponent:@"/data"];
    
    if (![fileMngr fileExistsAtPath:dataPath]) {
        [fileMngr createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return dataPath;
}

+ (NSString *)messageFilesDirectory {
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSString *dataPath = [[self documentsDirectory] stringByAppendingPathComponent:@"/msg"];
    
    if (![fileMngr fileExistsAtPath:dataPath]) {
        [fileMngr createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return dataPath;
}

+ (void)writeDataToFile:(NSData *)data directory:(NSString *)dir name:(NSString *)fileName {
    NSString *fullFileName = [dir stringByAppendingPathComponent: fileName];
    [data writeToFile:fullFileName atomically:YES];
}

+ (void)deleteAllUserFiles {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    id directories = @[ [self messageFilesDirectory],  [self dataDirectory], [self photosDirectory] ];
    for (id dir in directories) {
        NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath: dir  error:nil];
        for (NSString *filename in fileArray)  {
            [fileMgr removeItemAtPath:[dir stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}

+ (void)deleteAllObjects:(NSString *) entityDescription{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:getDBCtx()];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [getDBCtx() executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [getDBCtx() deleteObject:managedObject];
    }
    if (![getDBCtx() save:&error]) {
    }
}

@end


@implementation NSString (Custom)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (BOOL) isEmpty {
    return [Utils stringIsEmpty: self];
}

- (NSString *) trimmed {
    return [Utils trimString: self];
}

- (NSString *) encodedURLComponents {
    return nil;
}

- (NSString *) decodedURLComponents {
    return nil;
}

@end
