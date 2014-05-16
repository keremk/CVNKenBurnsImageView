//
//  CVNKenBurnsImageViewTests.m
//  CVNKenBurnsImageViewDemo
//
//  Created by Kerem Karatal on 5/15/14.
//  Copyright (c) 2014 CodingVentures. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CVNKenBurnsImageView/CVNKenBurnsImageView.h>
#define EXP_SHORTHAND YES

#import "Expecta.h"

#define EXPECTA_TEST_TIMEOUT 200

@interface CVNKenBurnsImageView(Tests)
- (CGSize) resizeImageWithSize:(CGSize) imageSize enlargeRatio:(CGFloat) enlargeRatio;

@end

@interface CVNKenBurnsImageViewTests : XCTestCase

@end

@implementation CVNKenBurnsImageViewTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void) testImageSizing {
  CGRect frame = CGRectMake(0, 0, 100.0f, 100.0f);
  CVNKenBurnsImageView *imageView = [[CVNKenBurnsImageView alloc] initWithFrame:frame];
  
  // width > frameW, height < frameH, widthDiff > heightDiff
  CGSize newSize = [imageView resizeImageWithSize:CGSizeMake(120.0f, 90.0f) enlargeRatio:1.0f];
  expect(newSize.width).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.height).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.width / newSize.height).to.beCloseToWithin(120.0f/90.0f, 0.5f);

  // width > frameW, height < frameH, widthDiff < heightDiff
  newSize = [imageView resizeImageWithSize:CGSizeMake(105.0f, 90.0f) enlargeRatio:1.0f];
  expect(newSize.width).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.height).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.width / newSize.height).to.beCloseToWithin(105.0f/90.0f, 0.5f);

  // width < frameW, height > frameH, widthDiff > heightDiff
  newSize = [imageView resizeImageWithSize:CGSizeMake(80.0f, 110.0f) enlargeRatio:1.0f];
  expect(newSize.width).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.height).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.width / newSize.height).to.beCloseToWithin(80.0f/110.0f, 0.5f);

  // width < frameW, height > frameH, widthDiff < heightDiff
  newSize = [imageView resizeImageWithSize:CGSizeMake(80.0f, 140.0f) enlargeRatio:1.0];
  expect(newSize.width).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.height).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.width / newSize.height).to.beCloseToWithin(80.0f/140.0f, 0.5f);

  // width > frameW, height > frameH, widthDiff > heightDiff
  newSize = [imageView resizeImageWithSize:CGSizeMake(200.0f, 150.0f) enlargeRatio:1.0f];
  expect(newSize.width).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.height).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.width / newSize.height).to.beCloseToWithin(200.0f/150.0f, 0.5f);

  // width > frameW, height > frameH, widthDiff < heightDiff
  newSize = [imageView resizeImageWithSize:CGSizeMake(150.0f, 200.0f) enlargeRatio:1.0f];
  expect(newSize.width).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.height).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.width / newSize.height).to.beCloseToWithin(150.0f/200.0f, 0.5f);

  // width < frameW, height < frameH, widthDiff > heightDiff
  newSize = [imageView resizeImageWithSize:CGSizeMake(50.0f, 80.0f) enlargeRatio:1.0f];
  expect(newSize.width).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.height).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.width / newSize.height).to.beCloseToWithin(50.0f/80.0f, 0.5f);

  // width < frameW, height < frameH, widthDiff < heightDiff
  newSize = [imageView resizeImageWithSize:CGSizeMake(80.0f, 50.0f) enlargeRatio:1.0f];
  expect(newSize.width).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.height).to.beGreaterThanOrEqualTo(100.0f);
  expect(newSize.width / newSize.height).to.beCloseToWithin(80.0f/50.0f, 0.5f);

}

@end
