//
//  CVNViewController.m
//  CVNKenBurnsImageViewDemo
//
//  Created by Kerem Karatal on 5/10/14.
//  Copyright (c) 2014 CodingVentures. All rights reserved.
//

#import "CVNViewController.h"
#import <CVNKenBurnsImageView/CVNKenBurnsImageView.h>

@interface CVNViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet CVNKenBurnsImageView *imageView;

@end

@implementation CVNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  NSArray *imageURLs = @[@"http://www.goldenstreetapartments.com/wp-content/uploads/2013/08/istanbulbg-01.jpg",
                         @"http://somosolimpicos.com/wp-content/uploads/2013/09/estambul.jpg",
                         @"http://www.priorityonejets.com/wp-content/uploads/2013/04/jet-charter-to-istanbul.jpg",
                         @"http://istanbulstreets.files.wordpress.com/2010/10/istanbul_through_my_eyes-5.jpg",
                         @"http://medicatrans.com/wp-content/uploads/2013/10/istanbul2.jpg",
                         @"http://www.semesteratsea.org/wp-content/uploads/2012/08/001.jpg"
                         ];
  self.imageView.animationImages = imageURLs;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startAnimation:(id)sender {
  [self.imageView startAnimating];
}
- (IBAction)stopAnimation:(id)sender {
  [self.imageView stopAnimating];
}

@end
