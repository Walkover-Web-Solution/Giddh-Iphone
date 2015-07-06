//
//  PersonalHomeVC.h
//  Giddh
//
//  Created by Admin on 16/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Companies.h"
@interface PersonalHomeVC : UIViewController

@property (strong , nonatomic) NSString *companyName;
@property (strong, nonatomic) Companies *companies;
@end
