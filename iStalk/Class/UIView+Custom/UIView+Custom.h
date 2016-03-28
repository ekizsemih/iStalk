#import <UIKit/UIKit.h>

@interface UIView (Custom)
@property (nonatomic, assign) BOOL localized;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) NSNumber *fontSize;
@property (nonatomic, assign) NSNumber *delayedTouch;
@end
