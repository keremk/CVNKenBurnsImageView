//
//  CVNKenBurnsImageView.h
//  Pods
//
//  Created by Kerem Karatal on 5/10/14.
//
//

#import <UIKit/UIKit.h>

@interface CVNKenBurnsImageView : UIView
@property(nonatomic, copy) NSArray *animationImages;
@property(nonatomic, assign) NSInteger animationRepeatCount;

- (instancetype) initWithAnimationImages:(NSArray *) animationImages;

- (void) startAnimating;
- (void) stopAnimating;
- (BOOL) isAnimating;
- (void) cancelLoadingImages;

@end
