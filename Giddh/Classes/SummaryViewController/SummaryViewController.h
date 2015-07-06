//
//  SummaryViewController.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 30/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Companies.h"
@interface SummaryViewController : UIViewController
@property (strong, nonatomic) Companies *companies;
@property (assign, nonatomic) BOOL isFirstTime;
@end
