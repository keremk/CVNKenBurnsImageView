//
//  CVNKenBurnsImageView.m
//  Pods
//
//  Created by Kerem Karatal on 5/10/14.
//
//

#import "CVNKenBurnsImageView.h"
#import "CVNImageCache.h"
#import "CVNImage.h"
#import "AFNetworking.h"

@interface CVNImage(CVNKenBurnsImageView)
@property(nonatomic, copy) NSURLRequest *urlRequest;
@property(nonatomic, copy) NSString *fileSystemPath;
@property(nonatomic, strong) UIImage *loadedImage;
@end

@interface CVNKenBurnsImageView()
@property(nonatomic, strong) NSMutableArray *imageList;
@property(nonatomic, strong) NSMutableArray *imageRequestOperations;
@property(nonatomic, assign) NSInteger currentImageIndex;
@property(nonatomic, strong) NSTimer *nextImageTimer;
@end

static const CGFloat enlargeRatio = 1.1f;

typedef struct CVNKenBurnsStep {
  CGPoint   origin;
  CGVector  move;
  CGVector  zoom;
  CGFloat   rotation;
} CVNKenBurnsStep;

@implementation CVNKenBurnsImageView {
  BOOL    _isAnimating;
}

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


- (instancetype) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    [self commonInit];
  }
  return self;
}

- (instancetype) initWithCoder:(NSCoder *) aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    // Initialization code
    [self commonInit];
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
  _isAnimating = NO;
  _currentImageIndex = -1;
  _animationDuration = 1;
  _animationRepeatCount = -1;  // Always repeat
  self.imageList = [NSMutableArray array];
  self.imageRequestOperations = [NSMutableArray array];
}

- (void) startAnimating {
  if (!_isAnimating) {
    _isAnimating = YES;
    [self animateIfReady];
  }
}

- (void) stopAnimating {
  _isAnimating = NO;
}

- (void) setAnimationImages:(NSArray *) animationImages {
  if (_animationImages != animationImages) {
    _animationImages = [NSArray arrayWithArray:animationImages];
    [self addToImageListFromImages:animationImages];
  }
}

- (BOOL) isAnimating {
  return _isAnimating;
}

- (void) cancelLoadingImages {
  [self.imageRequestOperations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    AFHTTPRequestOperation *operation  = (AFHTTPRequestOperation *) obj;
    [operation cancel];
  }];
  self.imageRequestOperations = [NSMutableArray array];
}

- (UIImage *) currentImage {
  UIImage *image = nil;
  if (self.currentImageIndex < [self.imageList count]) {
    image = [self.imageList[self.currentImageIndex] image];
  }
  return image;
}

#pragma mark - Download/Find Animation Images

- (void) addToImageListFromImages:(NSArray *) images {
  [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([[obj class] isSubclassOfClass:[NSURL class]]) {
      NSURL *url = (NSURL *) obj;
      if ([url isFileURL]) {
        NSString *path = [url path];
        CVNImage *cvnImage = [CVNImage imageWithBlock:^(CVNImage *image) {
          image.imageSource = CVNLocalFileSourced;
          image.fileSystemPath = path;
        }];
        [self.imageList addObject:cvnImage];
      } else {
        [self addToNetworkQueueWithURL:url];
      }
    } else if ([[obj class] isSubclassOfClass:[NSString class]]) {
      CVNImage *cvnImage = [CVNImage imageWithBlock:^(CVNImage *image) {
        image.imageSource = CVNLocalFileSourced;
        image.fileSystemPath = obj;
      }];
      [self.imageList addObject:cvnImage];
    } else if ([[obj class] isSubclassOfClass:[UIImage class]]) {
      CVNImage *cvnImage = [CVNImage imageWithBlock:^(CVNImage *image) {
        image.imageSource = CVNMemorySourced;
        image.loadedImage = obj;
      }];
      [self.imageList addObject:cvnImage];
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
      CVNImage *cvnImage = [CVNImage imageWithBlock:^(CVNImage *image) {
        image.imageSource = CVNNetworkSourced;
        image.loadedImage = responseObject;
        image.urlRequest = request;
      }];
      [strongSelf.imageList addObject:cvnImage];
      [strongSelf animateIfReady];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
    [[[self class] sharedImageRequestOperationQueue] addOperation:requestOperation];
    [self.imageRequestOperations addObject:requestOperation];
  }
  
}

- (void) animateIfReady {
  if ([self.imageList count] > 2 && _isAnimating) {
    [self startAnimationSequence];
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

#pragma mark - Animation

// Ken Burns Animation is refactored/cleaned up from
// https://github.com/jberlana/JBKenBurns

- (CGSize) resizeImageWithSize:(CGSize) imageSize enlargeRatio:(CGFloat) enlargeRatio {
  CGFloat viewWidth = self.bounds.size.width;
  CGFloat viewHeight = self.bounds.size.height;
  
  // Keep aspect ratio
  CGFloat resizeRatio = MIN(viewWidth / imageSize.width, viewHeight / imageSize.height);
  return CGSizeMake(imageSize.width * resizeRatio * enlargeRatio,
                    imageSize.height * resizeRatio * enlargeRatio);
}

- (CVNKenBurnsStep) randomAnimationStepWithImageSize:(CGSize) newSize{
  CVNKenBurnsStep randomAnimation;
  CGFloat viewWidth = self.bounds.size.width;
  CGFloat viewHeight = self.bounds.size.height;
  
  CGFloat maxMoveX = newSize.width - viewWidth;
  CGFloat maxMoveY = newSize.height - viewHeight;

  randomAnimation.rotation = (arc4random() % 9) / 100;

  switch (arc4random() % 4) {
    case 0:
      randomAnimation.origin = CGPointZero;
      randomAnimation.zoom = CGVectorMake(1.25f, 1.25f);
      randomAnimation.move = CGVectorMake(-maxMoveX, -maxMoveY);
      break;
    case 1:
      randomAnimation.origin = CGPointMake(0.0f, viewHeight - newSize.height);
      randomAnimation.zoom = CGVectorMake(1.10f, 1.10f);
      randomAnimation.move = CGVectorMake(-maxMoveX, maxMoveY);
      break;
    case 2:
      randomAnimation.origin = CGPointMake(viewWidth - newSize.width, 0.0f);
      randomAnimation.zoom = CGVectorMake(1.30f, 1.30f);
      randomAnimation.move = CGVectorMake(maxMoveX, -maxMoveY);
      break;
    case 3:
      randomAnimation.origin = CGPointMake(viewWidth - newSize.width, viewHeight - newSize.height);
      randomAnimation.zoom = CGVectorMake(1.20f, 1.20f);
      randomAnimation.move = CGVectorMake(maxMoveX, maxMoveY);
      break;
  }

  return randomAnimation;
}

- (void) startAnimationSequence {
  self.currentImageIndex = -1;
  self.nextImageTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration + 2
                                                         target:self
                                                       selector:@selector(animateNextImage)
                                                       userInfo:nil
                                                        repeats:YES];
  [_nextImageTimer fire];
}

- (void) animateNextImage {
  self.currentImageIndex++;
  
  UIImage *image = self.currentImage;
  
  CGSize newSize = [self resizeImageWithSize:image.size enlargeRatio:enlargeRatio];
  CVNKenBurnsStep randomAnimation = [self randomAnimationStepWithImageSize:newSize];
  
  
  UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
  imageView.backgroundColor = [UIColor blackColor];
  
  //    NSLog(@"W: IW:%f OW:%f FW:%f MX:%f",image.size.width, optimusWidth, frameWidth, maxMoveX);
  //    NSLog(@"H: IH:%f OH:%f FH:%f MY:%f\n",image.size.height, optimusHeight, frameHeight, maxMoveY);
  
  CALayer *picLayer    = [CALayer layer];
  picLayer.contents    = (id)image.CGImage;
  picLayer.anchorPoint = CGPointMake(0, 0);
  picLayer.bounds      = CGRectMake(0, 0, newSize.width, newSize.height);
  picLayer.position    = randomAnimation.origin;
  
  [imageView.layer addSublayer:picLayer];
  
  CATransition *animation = [CATransition animation];
  [animation setDuration:1];
  [animation setType:kCATransitionFade];
  [[self layer] addAnimation:animation forKey:nil];
  
  // Remove the previous view
  if ([[self subviews] count] > 0){
    UIView *oldImageView = [[self subviews] objectAtIndex:0];
    [oldImageView removeFromSuperview];
    oldImageView = nil;
  }
  
  [self addSubview:imageView];
  
  // Generates the animation
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:self.animationDuration + 2];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  CGAffineTransform rotate    = CGAffineTransformMakeRotation(randomAnimation.rotation);
  CGAffineTransform moveRight = CGAffineTransformMakeTranslation(randomAnimation.move.dx,
                                                                 randomAnimation.move.dy);
  CGAffineTransform combo1    = CGAffineTransformConcat(rotate, moveRight);
  CGAffineTransform zoomIn    = CGAffineTransformMakeScale(randomAnimation.zoom.dx,
                                                           randomAnimation.zoom.dy);
  CGAffineTransform transform = CGAffineTransformConcat(zoomIn, combo1);
  imageView.transform = transform;
  [UIView commitAnimations];
  
  [self incrementCurrentImageIndex];
}

- (void) incrementCurrentImageIndex {
  BOOL areAllImagesAvailable = [self.imageList count] == [self.animationImages count];
  if (self.currentImageIndex == [self.imageList count] - 1) {
    if (self.animationRepeatCount == -1 || !areAllImagesAvailable) {
      // If all images are not downloaded it will repeat through the downloaded ones.
      self.currentImageIndex = -1;
    } else {
      [self.nextImageTimer invalidate];
    }
  }
}

@end
