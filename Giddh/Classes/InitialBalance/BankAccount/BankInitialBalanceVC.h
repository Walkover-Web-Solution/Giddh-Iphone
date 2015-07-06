//
//  BankInitialBalanceVC.h
//  Giddh
//
//  Created by Admin on 15/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankInitialBalanceVC : UIViewController <UITextFieldDelegate>
{
    IBOutlet UILabel *lblHeader;
    IBOutlet UIView *contentView;
    IBOutlet UIButton *btnDone;
    IBOutlet UITextField *txtAmount;
    IBOutlet UITextField *txtBankName;
    IBOutlet UILabel *lblWarning;
}
- (IBAction)doneButtonAction:(id)sender;
@property (nonatomic) int companyId;
@property (strong,nonatomic) NSString *companyName;
@end
