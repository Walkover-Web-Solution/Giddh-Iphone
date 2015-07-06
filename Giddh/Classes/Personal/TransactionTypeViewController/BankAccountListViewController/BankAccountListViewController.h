//
//  BankAccountListViewController.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 29/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntriesTemp.h"
#import "Companies.h"
@interface BankAccountListViewController : UIViewController
@property (strong, nonatomic) EntriesTemp *entriesTemp;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) Companies *companies;

@end
