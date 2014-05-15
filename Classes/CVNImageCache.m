//
//  CVNImageCache.m
//  Pods
//
//  Created by Kerem Karatal on 5/10/14.
//
//

#import "CVNImageCache.h"

@implementation CVNImageCache

static inline NSString * ImageCacheKeyFromURLRequest(NSURLRequest *request) {
  return [[request URL] absoluteString];
}

- (UIImage *) cachedImageForRequest:(NSURLRequest *)request {
  switch ([request cachePolicy]) {
    case NSURLRequestReloadIgnoringCacheData:
    case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
      return nil;
    default:
      break;
  }
  
	return [self objectForKey:ImageCacheKeyFromURLRequest(request)];
}

- (void) cacheImage:(UIImage *)image
         forRequest:(NSURLRequest *)request {
  if (image && request) {
    [self setObject:image forKey:ImageCacheKeyFromURLRequest(request)];
  }
}

@end
