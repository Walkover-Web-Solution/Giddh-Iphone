//
//  CreditCardVC.h
//  Giddh
//
//  Created by Admin on 07/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Accounts.h"

@interface CreditCardVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSUserDefaults *userDef;
    IBOutlet UITextField *txtCreditName;
    IBOutlet UITextField *txtOpeningBal;
    
    IBOutlet UITableView *tableViewCredit;
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

@end
