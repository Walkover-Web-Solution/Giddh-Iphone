//
//  LedgerTypeViewController.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 19/06/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Companies.h"

@interface LedgerTypeViewController : UIViewController
@property (strong, nonatomic) Companies *companies;
@property (strong, nonatomic) NSString *accountId;

@end
