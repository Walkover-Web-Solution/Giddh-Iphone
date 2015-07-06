//
//  SubGroupAccountVC.h
//  Giddh
//
//  Created by Admin on 18/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubGroupAccountVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrSubGroups,*arrClosingBal,*arrGroupDetails,*arrAccounts,*arrAccName,*arrAccBalance,*arrayGlobal;
    IBOutlet UITableView *tableViewSubGroup;
    BOOL firstReload;
    NSUserDefaults *userDef;
}

@property (strong,nonatomic) NSDictionary *accountDictionary;
- (IBAction)backAction:(id)sender;

@end
