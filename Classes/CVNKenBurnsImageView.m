//
//  CVNKenBurnsImageView.m
//  Pods
//
//  Created by Kerem Karatal on 5/10/14.
//
//

#import "CVNKenBurnsImageView.h"
#import "CVNImageCache.h"
#import "AFNetworking.h"



@interface CVNKenBurnsImageView()
@property(nonatomic, strong) NSMutableArray *imageList;
@property(nonatomic, strong) NSMutableArray *imageRequestOperations;
@end

@implementation CVNKenBurnsImageView

+ (id <CVNImageCache>) sharedImageCache {
  static CVNImageCache *_defaultImageCache = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _defaultImageCache = [[CVNImageCache alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
      [_defaultImageCache removeAllObjects];
    }];
  });
  
  return _defaultImageCache;
}

+ (NSOperationQueue *) sharedImageRequestOperationQueue {
  static NSOperationQueue *_sharedImageRequestOperationQueue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
    _sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
  });
  
  return _sharedImageRequestOperationQueue;
}


- (instancetype) initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
      // Initialization code
  }
  return self;
}

- (instancetype) initWithCoder:(NSCoder *) aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    // Initialization code
  }
  return self;
}

- (instancetype) initWithAnimationImages:(NSArray *)animationImages {
  self = [super init];
  if (self) {
    self.animationImages = animationImages;
    [self commonInit];
  }
  return self;
}

- (void) commonInit {
  self.imageList = [NSMutableArray array];
  self.imageRequestOperations = [NSMutableArray array];
}

- (void) startAnimating {
  
}

- (void) stopAnimating {
  
}

- (void) setAnimationImages:(NSArray *) animationImages {
  if (_animationImages != animationImages) {
    _animationImages = [NSArray arrayWithArray:animationImages];
    [self addToImageListFromImages:animationImages];
  }
}

- (BOOL) isAnimating {
  BOOL isAnimating = NO;
  
  return isAnimating;
}

- (void) cancelLoadingImages {
  [self.imageRequestOperations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    AFHTTPRequestOperation *operation  = (AFHTTPRequestOperation *) obj;
    [operation cancel];
  }];
  self.imageRequestOperations = [NSMutableArray array];
}

#pragma mark - Handle Animation Images

- (void) addToImageListFromImages:(NSArray *) images {
  [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([[obj class] isSubclassOfClass:[NSURL class]]) {
      NSURL *url = (NSURL *) obj;
      if ([url isFileURL]) {
        NSString *path = [url path];
        [self addToFileOperationQueueWithPath:path];
      } else {
        [self addToNetworkQueueWithURL:url];
      }
    } else if ([[obj class] isSubclassOfClass:[NSString class]]) {
      [self addToFileOperationQueueWithPath:obj];
    } else if ([[obj class] isSubclassOfClass:[UIImage class]]) {
      [self.imageList addObject:obj];
    }
  }];
}

- (void) addToNetworkQueueWithURL:(NSURL *) imageURL {
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
  [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
  
  UIImage *cachedImage = [[[self class] sharedImageCache] cachedImageForRequest:request];
  if (cachedImage) {
    [self.imageList addObject:cachedImage];
  } else {
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __weak __typeof(self) weakSelf = self;
    requestOperation.responseSerializer = [self imageResponseSerializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
      __strong __typeof(weakSelf) strongSelf = weakSelf;
      [strongSelf removeImageRequestOperation:requestOperation];
      [strongSelf.imageList addObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
    [[[self class] sharedImageRequestOperationQueue] addOperation:requestOperation];
    [self.imageRequestOperations addObject:requestOperation];
  }
  
}

- (void) removeImageRequestOperation:(AFHTTPRequestOperation *) operation {
  [self.imageRequestOperations removeObject:operation];
}

- (id <AFURLResponseSerialization>) imageResponseSerializer {
  static id <AFURLResponseSerialization> _defaultImageResponseSerializer = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _defaultImageResponseSerializer = [AFImageResponseSerializer serializer];
  });

  return _defaultImageResponseSerializer;
}

- (void) addToFileOperationQueueWithPath:(NSString *) path {
  
  
}

@end
