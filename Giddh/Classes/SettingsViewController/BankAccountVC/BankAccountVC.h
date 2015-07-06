//
//  BankAccountVC.h
//  Giddh
//
//  Created by Admin on 06/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Accounts.h"
#import "Companies.h"
@interface BankAccountVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSUserDefaults *userDef;
    IBOutlet UITextField *txtAccountName;
    IBOutlet UITextField *txtOpeningBal;
    
    IBOutlet UITableView *tableViewAccounts;
    BOOL updateFlag;
    
    NSString *oldAccountName,*oldUniqueName;
    NSNumber *accountID;
    IBOutlet UIBarButtonItem *btnClear;
    IBOutlet UIBarButtonItem *btnSave;
}
@property (nonatomic) NSMutableArray *arrAccounts;
@property (nonatomic) int globalCompanyId;
@property (nonatomic,strong) NSString *globalCompanyName;
- (IBAction)saveAction:(id)sender;
- (IBAction)clearTextAction:(id)sender;
@property (strong, nonatomic) Companies *companies;

@end
