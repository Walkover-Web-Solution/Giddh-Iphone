//
//  FinalTransactionViewController.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 22/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntriesTemp.h"
#import "Companies.h"
@interface FinalTransactionViewController : UIViewController
@property (strong, nonatomic) EntriesTemp *entriesTemp;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) Companies *companies;
//@property (assign, nonatomic) BOOL isCredit;
//@property (strong, nonatomic) NSString *accName;
//
@end
