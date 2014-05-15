//
//  CVNImage.h
//  Pods
//
//  Created by Kerem Karatal on 5/15/14.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
  CVNNetworkSourced,
  CVNLocalFileSourced,
  CVNMemorySourced
} CVNImageSource;

@class CVNImage;
typedef void(^CVNImageBlock)(CVNImage *image);

@interface CVNImage : NSObject
@property(nonatomic, assign) CVNImageSource imageSource;

+ (instancetype) imageWithBlock:(CVNImageBlock) block;
- (UIImage *) image;
@end
