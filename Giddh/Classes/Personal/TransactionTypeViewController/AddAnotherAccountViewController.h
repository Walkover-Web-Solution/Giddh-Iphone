//
//  AddAnotherAccountViewController.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 21/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Companies.h"
#import "EntriesTemp.h"
#import "Companies.h"
#import "Accounts.h"
@protocol AddAnotherAccountViewControllerDelegate <NSObject>
-(void)refreshListWithAccount:(Accounts*)account;
-(void)loanEmailAdded;
@end
@interface AddAnotherAccountViewController : UIViewController
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *accType;
@property (assign, nonatomic) int groupId;
@property (strong, nonatomic) Companies *companies;
@property (strong, nonatomic) id <AddAnotherAccountViewControllerDelegate> delegate;
@property (strong, nonatomic) EntriesTemp *entriesTemp;

@end
