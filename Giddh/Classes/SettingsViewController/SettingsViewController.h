//
//  SettingsViewController.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 01/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Companies.h"
@interface SettingsViewController : UIViewController<UITableViewDelegate,UITextFieldDelegate,UIPickerViewDelegate>
{
    NSUserDefaults *userDef;
    IBOutlet UIButton *btnSave;
    NSString *strUserName,*strDateTime;
    UITextField *txtUserName;
    UILabel *lblEmail;
    
    //sync accounts
    NSArray *arrAccounts;
    NSMutableArray *arrBankAcc,*arrCreditCards;
    int selectedIndex;
    
    //picker view properties
    UIPickerView *picView;
    UIButton *btnCancel,*btnDone;
   
}
@property (nonatomic) int globalCompanyId;
@property (nonatomic,strong) NSString *globalCompanyName;
@property (nonatomic,strong) NSString *globalCompanyEmail;
@property (strong, nonatomic) Companies *companies;

@end
