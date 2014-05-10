//
//  CVNImageCache.h
//  Pods
//
//  Created by Kerem Karatal on 5/10/14.
//
//

#import <Foundation/Foundation.h>

@protocol CVNImageCache

/**
 Returns a cached image for the specififed request, if available.
 
 @param request The image request.
 @return The cached image.
 */
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;

/**
 Caches a particular image for the specified request.
 
 @param image The image to cache.
 @param request The request to be used as a cache key.
 */
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end


@interface CVNImageCache : NSCache <CVNImageCache>
@end
