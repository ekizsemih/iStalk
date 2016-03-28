/***********************************************************************************
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Matthew Styles
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 ***********************************************************************************/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KILinkType)
{
    KILinkTypeUserHandle,
    KILinkTypeHashtag,
    KILinkTypeURL,
    KILinkTypeUsername
};

typedef NS_OPTIONS(NSUInteger, KILinkTypeOption)
{
    KILinkTypeOptionNone = 0,
    KILinkTypeOptionUserHandle = 1 << KILinkTypeUserHandle,
    KILinkTypeOptionHashtag = 1 << KILinkTypeHashtag,
    KILinkTypeOptionURL = 1 << KILinkTypeURL,
    KILinkTypeOptionUsername = 2 << KILinkTypeUsername,
    KILinkTypeOptionAll = NSUIntegerMax,
};


@class KILabel;
typedef void (^KILinkTapHandler)(KILabel *label, NSString *string, NSRange range);

extern NSString * const KILabelLinkTypeKey;
extern NSString * const KILabelRangeKey;
extern NSString * const KILabelLinkKey;

IB_DESIGNABLE
@interface KILabel : UILabel <NSLayoutManagerDelegate>
@property (nonatomic, assign, getter = isAutomaticLinkDetectionEnabled) IBInspectable BOOL automaticLinkDetectionEnabled;
@property (nonatomic, assign) IBInspectable KILinkTypeOption linkDetectionTypes;
@property (nullable, nonatomic, strong) NSSet *ignoredKeywords;
@property (nullable, nonatomic, copy) IBInspectable UIColor *selectedLinkBackgroundColor;
@property (nonatomic, assign) IBInspectable BOOL systemURLStyle;
- (nullable NSDictionary*)attributesForLinkType:(KILinkType)linkType;
- (void)setAttributes:(nullable NSDictionary*)attributes forLinkType:(KILinkType)linkType;
@property (nullable, nonatomic, copy) KILinkTapHandler userHandleLinkTapHandler;
@property (nullable, nonatomic, copy) KILinkTapHandler hashtagLinkTapHandler;
@property (nullable, nonatomic, copy) KILinkTapHandler urlLinkTapHandler;
@property (nullable, nonatomic, copy) KILinkTapHandler usernameLinkTapHandler;
- (nullable NSDictionary*)linkAtPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END