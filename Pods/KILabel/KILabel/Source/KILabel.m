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

#import "KILabel.h"

NSString * const KILabelLinkTypeKey = @"linkType";
NSString * const KILabelRangeKey = @"range";
NSString * const KILabelLinkKey = @"link";

#pragma mark - Private Interface

@interface KILabel()
@property (nonatomic, retain) NSLayoutManager *layoutManager;
@property (nonatomic, retain) NSTextContainer *textContainer;
@property (nonatomic, retain) NSTextStorage *textStorage;
@property (nonatomic, copy) NSArray *linkRanges;
@property (nonatomic, assign) BOOL isTouchMoved;
@property (nonatomic, assign) NSRange selectedRange;
@end

#pragma mark - Implementation

@implementation KILabel
{
    NSMutableDictionary *_linkTypeAttributes;
}

#pragma mark - Construction

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupTextSystem];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupTextSystem];
    }
    
    return self;
}

- (void)setupTextSystem {
    _textContainer = [[NSTextContainer alloc] init];
    _textContainer.lineFragmentPadding = 0;
    _textContainer.maximumNumberOfLines = self.numberOfLines;
    _textContainer.lineBreakMode = self.lineBreakMode;
    _textContainer.size = self.frame.size;
    
    _layoutManager = [[NSLayoutManager alloc] init];
    _layoutManager.delegate = self;
    [_layoutManager addTextContainer:_textContainer];
    [_textContainer setLayoutManager:_layoutManager];
    self.userInteractionEnabled = YES;
    _automaticLinkDetectionEnabled = YES;
    _linkDetectionTypes = KILinkTypeOptionAll;
    _linkTypeAttributes = [NSMutableDictionary dictionary];
    _systemURLStyle = NO;
    _selectedLinkBackgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:0.95 alpha:1.0];
    [self updateTextStoreWithText];
}

#pragma mark - Text and Style management

- (void)setAutomaticLinkDetectionEnabled:(BOOL)decorating
{
    _automaticLinkDetectionEnabled = decorating;
    [self updateTextStoreWithText];
}

- (void)setLinkDetectionTypes:(KILinkTypeOption)linkDetectionTypes
{
    _linkDetectionTypes = linkDetectionTypes;
    [self updateTextStoreWithText];
}

- (NSDictionary *)linkAtPoint:(CGPoint)location
{
    if (_textStorage.string.length == 0)
    {
        return nil;
    }
    
    CGPoint textOffset = [self calcGlyphsPositionInView];
    
    location.x -= textOffset.x;
    location.y -= textOffset.y;
    
    NSUInteger touchedChar = [_layoutManager glyphIndexForPoint:location inTextContainer:_textContainer];
    
    NSRange lineRange;
    CGRect lineRect = [_layoutManager lineFragmentUsedRectForGlyphAtIndex:touchedChar effectiveRange:&lineRange];
    if (CGRectContainsPoint(lineRect, location) == NO)
        return nil;
    
    for (NSDictionary *dictionary in self.linkRanges)
    {
        NSRange range = [[dictionary objectForKey:KILabelRangeKey] rangeValue];
        
        if ((touchedChar >= range.location) && touchedChar < (range.location + range.length))
        {
            return dictionary;
        }
    }
    
    return nil;
}

- (void)setSelectedRange:(NSRange)range
{
    if (self.selectedRange.length && !NSEqualRanges(self.selectedRange, range))
    {
        [_textStorage removeAttribute:NSBackgroundColorAttributeName range:self.selectedRange];
    }
    if (range.length && _selectedLinkBackgroundColor != nil)
    {
        [_textStorage addAttribute:NSBackgroundColorAttributeName value:_selectedLinkBackgroundColor range:range];
    }
    _selectedRange = range;
    
    [self setNeedsDisplay];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    [super setNumberOfLines:numberOfLines];
    
    _textContainer.maximumNumberOfLines = numberOfLines;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    if (!text)
    {
        text = @"";
    }
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self attributesFromProperties]];
    [self updateTextStoreWithAttributedString:attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    
    [self updateTextStoreWithAttributedString:attributedText];
}

- (void)setSystemURLStyle:(BOOL)systemURLStyle
{
    _systemURLStyle = systemURLStyle;
    self.text = self.text;
}

- (NSDictionary*)attributesForLinkType:(KILinkType)linkType
{
    UIColor * otherColor = [UIColor colorWithRed:24.0/255.0 green:121.0/255.0 blue:142.0/255.0 alpha:0.6];
    UIColor * linkColor = [UIColor colorWithRed:0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:0.75];
    UIColor * usernameColor = [UIColor colorWithRed:24.0/255.0 green:121.0/255.0 blue:142.0/255.0 alpha:1];
    UIFont * commentsFont = [UIFont fontWithName:@"verdana" size:15];
    UIFont * commentsFontBold = [UIFont fontWithName:@"verdana" size:15];
    
    NSDictionary *attributes = _linkTypeAttributes[@(linkType)];
    
    if (!attributes)
    {
        if(linkType == 0)
            attributes = @{NSForegroundColorAttributeName : otherColor,NSFontAttributeName:commentsFont};
        else if (linkType == 1)
            attributes = @{NSForegroundColorAttributeName : otherColor,NSFontAttributeName:commentsFont};
        else if (linkType == 2)
            attributes = @{NSForegroundColorAttributeName : linkColor,NSFontAttributeName:commentsFontBold};
        else if(linkType == 3)
            attributes = @{NSForegroundColorAttributeName : usernameColor,NSFontAttributeName:commentsFontBold};
    }
    return attributes;
}

- (void)setAttributes:(NSDictionary*)attributes forLinkType:(KILinkType)linkType
{
    if (attributes)
    {
        _linkTypeAttributes[@(linkType)] = attributes;
    }
    else
    {
        [_linkTypeAttributes removeObjectForKey:@(linkType)];
    }
    
    self.text = self.text;
}

#pragma mark - Text Storage Management

- (void)updateTextStoreWithText
{
    if (self.attributedText)
    {
        [self updateTextStoreWithAttributedString:self.attributedText];
    }
    else if (self.text)
    {
        [self updateTextStoreWithAttributedString:[[NSAttributedString alloc] initWithString:self.text attributes:[self attributesFromProperties]]];
    }
    else
    {
        [self updateTextStoreWithAttributedString:[[NSAttributedString alloc] initWithString:@"" attributes:[self attributesFromProperties]]];
    }
    
    [self setNeedsDisplay];
}

- (void)updateTextStoreWithAttributedString:(NSAttributedString *)attributedString
{
    if (attributedString.length != 0)
    {
        attributedString = [KILabel sanitizeAttributedString:attributedString];
    }
    
    if (self.isAutomaticLinkDetectionEnabled && (attributedString.length != 0))
    {
        self.linkRanges = [self getRangesForLinks:attributedString];
        attributedString = [self addLinkAttributesToAttributedString:attributedString linkRanges:self.linkRanges];
    }
    else
    {
        self.linkRanges = nil;
    }
    
    if (_textStorage)
    {
        [_textStorage setAttributedString:attributedString];
    }
    else
    {
        _textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager setTextStorage:_textStorage];
    }
}

- (NSDictionary *)attributesFromProperties
{
    NSShadow *shadow = shadow = [[NSShadow alloc] init];
    if (self.shadowColor)
    {
        shadow.shadowColor = self.shadowColor;
        shadow.shadowOffset = self.shadowOffset;
    }
    else
    {
        shadow.shadowOffset = CGSizeMake(0, -1);
        shadow.shadowColor = nil;
    }
    
    UIColor *color = self.textColor;
    if (!self.isEnabled)
    {
        color = [UIColor lightGrayColor];
    }
    else if (self.isHighlighted)
    {
        color = self.highlightedTextColor;
    }
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = self.textAlignment;
    
    NSDictionary *attributes = @{NSFontAttributeName : self.font,
                                 NSForegroundColorAttributeName : color,
                                 NSShadowAttributeName : shadow,
                                 NSParagraphStyleAttributeName : paragraph,
                                 };
    return attributes;
}

- (NSArray *)getRangesForLinks:(NSAttributedString *)text
{
    NSMutableArray *rangesForLinks = [[NSMutableArray alloc] init];
    
    if (self.linkDetectionTypes & KILinkTypeOptionUserHandle)
    {
        [rangesForLinks addObjectsFromArray:[self getRangesForUserHandles:text.string]];
    }
    
    if (self.linkDetectionTypes & KILinkTypeOptionUsername)
    {
        [rangesForLinks addObjectsFromArray:[self getRangesForUsername:text.string]];
    }
    
    if (self.linkDetectionTypes & KILinkTypeOptionHashtag)
    {
        [rangesForLinks addObjectsFromArray:[self getRangesForHashtags:text.string]];
    }
    
    if (self.linkDetectionTypes & KILinkTypeOptionURL)
    {
        [rangesForLinks addObjectsFromArray:[self getRangesForURLs:self.attributedText]];
    }
    
    return rangesForLinks;
}

- (NSArray *)getRangesForUserHandles:(NSString *)text
{
    NSMutableArray *rangesForUserHandles = [[NSMutableArray alloc] init];
    
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [[NSRegularExpression alloc] initWithPattern:@"(?<!\\w)@([\\w\\_]+)?" options:0 error:&error];
    });
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        NSString *matchString = [text substringWithRange:matchRange];
        if (![self ignoreMatch:matchString])
        {
            [rangesForUserHandles addObject:@{KILabelLinkTypeKey : @(KILinkTypeUserHandle),
                                              KILabelRangeKey : [NSValue valueWithRange:matchRange],
                                              KILabelLinkKey : matchString
                                              }];
        }
    }
    
    return rangesForUserHandles;
}

- (NSArray *)getRangesForUsername:(NSString *)text
{
    NSMutableArray *rangesForUserHandles = [[NSMutableArray alloc] init];
    
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [[NSRegularExpression alloc] initWithPattern:@"(?<!\\w)\a([\\w\\_]+)?" options:0 error:&error];
    });
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        NSString *matchString = [text substringWithRange:matchRange];
        
        if (![self ignoreMatch:matchString])
        {
            NSString *newStr = [matchString substringFromIndex:1];
            [rangesForUserHandles addObject:@{KILabelLinkTypeKey : @(KILinkTypeUsername),
                                              KILabelRangeKey : [NSValue valueWithRange:matchRange],
                                              KILabelLinkKey : newStr
                                              }];
        }
    }
    
    return rangesForUserHandles;
}

- (NSArray *)getRangesForHashtags:(NSString *)text
{
    NSMutableArray *rangesForHashtags = [[NSMutableArray alloc] init];
    
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [[NSRegularExpression alloc] initWithPattern:@"(?<!\\w)#([\\w\\_]+)?" options:0 error:&error];
    });
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        NSString *matchString = [text substringWithRange:matchRange];
        
        if (![self ignoreMatch:matchString])
        {
            [rangesForHashtags addObject:@{KILabelLinkTypeKey : @(KILinkTypeHashtag),
                                           KILabelRangeKey : [NSValue valueWithRange:matchRange],
                                           KILabelLinkKey : matchString,
                                           }];
        }
    }
    
    return rangesForHashtags;
}


- (NSArray *)getRangesForURLs:(NSAttributedString *)text
{
    NSMutableArray *rangesForURLs = [[NSMutableArray alloc] init];;
    
    NSError *error = nil;
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
    
    NSString *plainText = text.string;
    
    NSArray *matches = [detector matchesInString:plainText
                                         options:0
                                           range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        
        NSString *realURL = [text attribute:NSLinkAttributeName atIndex:matchRange.location effectiveRange:nil];
        if (realURL == nil)
            realURL = [plainText substringWithRange:matchRange];
        
        if (![self ignoreMatch:realURL])
        {
            if ([match resultType] == NSTextCheckingTypeLink)
            {
                [rangesForURLs addObject:@{KILabelLinkTypeKey : @(KILinkTypeURL),
                                           KILabelRangeKey : [NSValue valueWithRange:matchRange],
                                           KILabelLinkKey : realURL,
                                           }];
            }
        }
    }
    
    return rangesForURLs;
}

- (BOOL)ignoreMatch:(NSString*)string
{
    return [_ignoredKeywords containsObject:[string lowercaseString]];
}

- (NSAttributedString *)addLinkAttributesToAttributedString:(NSAttributedString *)string linkRanges:(NSArray *)linkRanges
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    
    for (NSDictionary *dictionary in linkRanges)
    {
        NSRange range = [[dictionary objectForKey:KILabelRangeKey] rangeValue];
        KILinkType linkType = [dictionary[KILabelLinkTypeKey] unsignedIntegerValue];
        
        NSDictionary *attributes = [self attributesForLinkType:linkType];
        [attributedString addAttributes:attributes range:range];
        
        if (_systemURLStyle && ((KILinkType)[dictionary[KILabelLinkTypeKey] unsignedIntegerValue] == KILinkTypeURL))
        {
            [attributedString addAttribute:NSLinkAttributeName value:dictionary[KILabelLinkKey] range:range];
        }
    }
    return attributedString;
}

#pragma mark - Layout and Rendering

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGSize savedTextContainerSize = _textContainer.size;
    NSInteger savedTextContainerNumberOfLines = _textContainer.maximumNumberOfLines;
    
    _textContainer.size = bounds.size;
    _textContainer.maximumNumberOfLines = numberOfLines;
    
    CGRect textBounds = [_layoutManager usedRectForTextContainer:_textContainer];
    
    textBounds.origin = bounds.origin;
    textBounds.size.width = ceil(textBounds.size.width);
    textBounds.size.height = ceil(textBounds.size.height);
    
    if (textBounds.size.height < bounds.size.height)
    {
        CGFloat offsetY = (bounds.size.height - textBounds.size.height) / 2.0;
        textBounds.origin.y += offsetY;
    }
    
    _textContainer.size = savedTextContainerSize;
    _textContainer.maximumNumberOfLines = savedTextContainerNumberOfLines;
    
    return textBounds;
}

- (void)drawTextInRect:(CGRect)rect
{
    NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
    CGPoint glyphsPosition = [self calcGlyphsPositionInView];
    
    [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:glyphsPosition];
    [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:glyphsPosition];
}

- (CGPoint)calcGlyphsPositionInView
{
    CGPoint textOffset = CGPointZero;
    
    CGRect textBounds = [_layoutManager usedRectForTextContainer:_textContainer];
    textBounds.size.width = ceil(textBounds.size.width);
    textBounds.size.height = ceil(textBounds.size.height);
    
    if (textBounds.size.height < self.bounds.size.height)
    {
        CGFloat paddingHeight = (self.bounds.size.height - textBounds.size.height) / 2.0;
        textOffset.y = paddingHeight;
    }
    
    return textOffset;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _textContainer.size = self.bounds.size;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    _textContainer.size = self.bounds.size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _textContainer.size = self.bounds.size;
}

- (void)setIgnoredKeywords:(NSSet *)ignoredKeywords
{
    NSMutableSet *set = [NSMutableSet setWithCapacity:ignoredKeywords.count];
    
    [ignoredKeywords enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [set addObject:[obj lowercaseString]];
    }];
    
    _ignoredKeywords = [set copy];
}

#pragma mark - Interactions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isTouchMoved = NO;
    
    NSDictionary *touchedLink;
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    touchedLink = [self linkAtPoint:touchLocation];
    
    if (touchedLink)
    {
        self.selectedRange = [[touchedLink objectForKey:KILabelRangeKey] rangeValue];
    }
    else
    {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    _isTouchMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_isTouchMoved)
    {
        self.selectedRange = NSMakeRange(0, 0);
        
        return;
    }
    
    // Get the info for the touched link if there is one
    NSDictionary *touchedLink;
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    touchedLink = [self linkAtPoint:touchLocation];
    
    if (touchedLink)
    {
        NSRange range = [[touchedLink objectForKey:KILabelRangeKey] rangeValue];
        NSString *touchedSubstring = [touchedLink objectForKey:KILabelLinkKey];
        KILinkType linkType = (KILinkType)[[touchedLink objectForKey:KILabelLinkTypeKey] intValue];
        
        [self receivedActionForLinkType:linkType string:touchedSubstring range:range];
    }
    else
    {
        [super touchesBegan:touches withEvent:event];
    }
    
    self.selectedRange = NSMakeRange(0, 0);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    self.selectedRange = NSMakeRange(0, 0);
}

- (void)receivedActionForLinkType:(KILinkType)linkType string:(NSString*)string range:(NSRange)range
{
    switch (linkType)
    {
        case KILinkTypeUserHandle:
            if (_userHandleLinkTapHandler)
            {
                _userHandleLinkTapHandler(self, string, range);
            }
            break;
            
        case KILinkTypeHashtag:
            if (_hashtagLinkTapHandler)
            {
                _hashtagLinkTapHandler(self, string, range);
            }
            break;
            
        case KILinkTypeURL:
            if (_urlLinkTapHandler)
            {
                _urlLinkTapHandler(self, string, range);
            }
        case KILinkTypeUsername:
            if (_usernameLinkTapHandler)
            {
                _usernameLinkTapHandler(self, string, range);
            }
            break;
    }
}

#pragma mark - Layout manager delegate

-(BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex
{
    NSRange range;
    NSURL *linkURL = [layoutManager.textStorage attribute:NSLinkAttributeName atIndex:charIndex effectiveRange:&range];
    
    return !(linkURL && (charIndex > range.location) && (charIndex <= NSMaxRange(range)));
}

+ (NSAttributedString *)sanitizeAttributedString:(NSAttributedString *)attributedString
{
    NSRange range;
    NSParagraphStyle *paragraphStyle = [attributedString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:&range];
    
    if (paragraphStyle == nil)
    {
        return attributedString;
    }
    
    NSMutableParagraphStyle *mutableParagraphStyle = [paragraphStyle mutableCopy];
    mutableParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSMutableAttributedString *restyled = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    [restyled addAttribute:NSParagraphStyleAttributeName value:mutableParagraphStyle range:NSMakeRange(0, restyled.length)];
    
    return restyled;
}

@end