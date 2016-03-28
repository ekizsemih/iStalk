//
//  UIImageView+DownloadProgress.m
//
//
//  Created by Martin Pilch on 3/29/13.
//
//

#import "UIImageView+DownloadProgress.h"

@implementation UIImageView (DownloadProgress)

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, UIImage *))success
                       failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure
         downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock {
    
    [self setImageWithURLRequest:urlRequest placeholderImage:placeholderImage success:success failure:failure];
    
    if ( [self respondsToSelector:@selector(af_imageRequestOperation)] ) {
        [[self performSelector:@selector(af_imageRequestOperation)] setDownloadProgressBlock:downloadProgressBlock];
    }
    
}

@end