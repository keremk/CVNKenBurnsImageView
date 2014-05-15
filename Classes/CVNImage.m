//
//  CVNImage.m
//  Pods
//
//  Created by Kerem Karatal on 5/15/14.
//
//

#import "CVNImage.h"

@interface CVNImage()
@property(nonatomic, copy) NSURLRequest *urlRequest;
@property(nonatomic, copy) NSString *fileSystemPath;
@property(nonatomic, strong) UIImage *loadedImage;
@end

@implementation CVNImage

+ (instancetype) imageWithBlock:(CVNImageBlock)block {
  NSParameterAssert(block);
  CVNImage *image = [[self alloc] init];
  block(image);
  return image;
}

- (UIImage *) image{
  UIImage *image = nil;
  switch (self.imageSource) {
    case CVNNetworkSourced:
    case CVNMemorySourced:
      image = self.loadedImage;
      break;
    case CVNLocalFileSourced:
      image = [UIImage imageWithContentsOfFile:self.fileSystemPath];
      break;
    default:
      break;
  }
  return image;
}

@end
