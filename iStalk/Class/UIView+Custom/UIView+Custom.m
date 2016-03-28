#import "UIView+Custom.h"
#import <objc/runtime.h>

NSString * const kTPViewFontNameKey = @"kTPViewFontNameKey";
NSString * const kTPViewFontSizeKey = @"kTPViewFontSizeKey";
NSString * const kTPViewDelayedTouch = @"kTPViewDelayedTouch";

@implementation UIView (Custom)

@dynamic fontName;
@dynamic fontSize;
@dynamic localized;

#pragma mark Proterties

- (NSNumber *)delayedTouch {
  return objc_getAssociatedObject(self, (__bridge const void *)(kTPViewDelayedTouch));
}

- (void)setDelayedTouch:(NSNumber *)delayedTouch {
  objc_setAssociatedObject(self, (__bridge const void *)(kTPViewDelayedTouch), delayedTouch, OBJC_ASSOCIATION_COPY);
}

- (void)setFontName:(NSString *)fontName {
  objc_setAssociatedObject(self, (__bridge const void *)(kTPViewFontNameKey), fontName, OBJC_ASSOCIATION_COPY);
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    UIFont * f = [UIFont fontWithName: fontName size: [[self fontSize] floatValue]];
    [self applyFont: f];
  });
}

- (NSString *)fontName {
  return objc_getAssociatedObject(self, (__bridge const void *)(kTPViewFontNameKey));
}

- (NSString *) defaultFontName {
  return [UIFont systemFontOfSize:0].fontName;
}

- (void)setFontSize:(NSNumber *)fontSize {
  objc_setAssociatedObject(self, (__bridge const void *)(kTPViewFontSizeKey), fontSize, OBJC_ASSOCIATION_COPY);
}

- (NSNumber *)fontSize {
  return objc_getAssociatedObject(self, (__bridge const void *)(kTPViewFontSizeKey));
}

- (NSNumber *) defaultFontSize {
  if ([self respondsToSelector:@selector(font)]) {
    UIFont *font = [self performSelector:@selector(font)];
    return @(font.pointSize);
  }
  
  return @(13);
}

#pragma mark -

- (UIFont *) getFont: (UIFont *) inheritedFont {
  NSString *viewFontName = [self fontName];
  
  if (viewFontName == nil) {
    viewFontName = [inheritedFont fontName];
  }
  
  if (viewFontName == nil) {
    if ([self respondsToSelector:@selector(font)]) {
      viewFontName = [[self performSelector:@selector(font)] fontName];
    }
  }
  
  if (viewFontName == nil) {
    viewFontName = [self defaultFontName];
  }
  
  NSNumber *viewFontSize = [self fontSize];
  
  if (viewFontSize == nil) {
    viewFontSize = @([inheritedFont pointSize]);
  }
  
  if (viewFontSize == nil || viewFontSize.integerValue == 0) {
    if ([self respondsToSelector:@selector(font)]) {
      viewFontSize = @([[self performSelector:@selector(font)] pointSize]);
    }
  }
  
  if (viewFontSize == nil) {
    viewFontSize = [self defaultFontSize];
  }
  
  return [UIFont fontWithName: viewFontName size:  [viewFontSize floatValue] ];
}

- (void) applyFont {
  [self applyFontToView:self inheritedFont: nil];
}

- (void) applyFont: (UIFont *) inheritedFont {
  [self applyFontToView:self inheritedFont: inheritedFont];
}

- (void) applyFontToView: (UIView *) view inheritedFont: (UIFont *) inheritedFont {
  UIFont *font =  [self getFont: inheritedFont];
  
  if ([view respondsToSelector:@selector(setFont:)]) {
    UIFont *f = [view performSelector:@selector(font)];
    [view performSelector:@selector(setFont:) withObject: [UIFont fontWithName:font.fontName size:  f.pointSize] ];
  }
  
  for (UIView *subview in [view subviews]) {
    [self applyFontToView:subview inheritedFont: font];
  }
}

- (void)setLocalized:(BOOL)localized {
  [self prepareForLocalization];
}

- (void) prepareForLocalization {
  id responder =  (id)self;
  if ([self respondsToSelector:@selector(setText:)] && [self respondsToSelector:@selector(text)]) {
    NSString *text = [responder text];
    NSString *localizedString = [Utils localizedString: text];
    [responder setText:localizedString];
  }
  
  if ([self respondsToSelector:@selector(setTitle:forState:)]) {
    NSString *text = [responder titleForState:[(UIControl *)responder state]];
    NSString *localizedString = [Utils localizedString: text];
    [responder setTitle:localizedString forState:[(UIControl *)responder state]];
  }
  
  if ([self respondsToSelector:@selector(setPlaceholder:)] && [self respondsToSelector:@selector(placeholder)]) {
    NSString *placeholder = [responder placeholder];
    NSString *localizedString = [Utils localizedString: placeholder];
    [responder setPlaceholder:localizedString];
  }
}

/*
- (void) prepareForLocalization {
    id responder =  (id)self;
    if ([self respondsToSelector:@selector(setText:)] && [self respondsToSelector:@selector(text)]) {
        NSString *text = [responder text];
        if ([text hasPrefix:@":AX"]) {
            NSString *locStringKey =[NSString stringWithFormat:@"%@%@",[[tempUD valueForKey:@"language"] uppercaseString],[text substringFromIndex:1]];
            NSString *loalizedString = NSLocalizedString(locStringKey, Nil);
            
            [responder setText:loalizedString];
        }
    } else if ([self respondsToSelector:@selector(setTitle:forState:)]) {
        UIButton *b = (UIButton *)responder;
        NSString *text = [responder titleForState:[b state]];
        
        if ([text hasPrefix:@":AX"]) {
            NSString *locStringKey =[NSString stringWithFormat:@"%@%@",[[tempUD valueForKey:@"language"] uppercaseString],[text substringFromIndex:1]];
            NSString *loalizedString = NSLocalizedString(locStringKey, Nil);
            
            [responder setTitle:loalizedString forState:[b state]];
        }
    }
 
}
 */

@end
