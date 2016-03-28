//
//  UIImageView+DownloadProgress.h
//
//
//  Created by Martin Pilch on 3/29/13.
//
//

#import "UIImageView+AFNetworking.h"

@interface UIImageView (DownloadProgress)

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, UIImage *))success
                       failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure
         downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock;

@end