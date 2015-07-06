//
//  WalletInitialBalanceVC.h
//  Giddh
//
//  Created by Admin on 15/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalletInitialBalanceVC : UIViewController
{
    IBOutlet UILabel *lblHeader;
    IBOutlet UIView *contentView;
    IBOutlet UIButton *btnDone;
    IBOutlet UITextField *txtAmount;
    IBOutlet UILabel *lblWarning;
}
- (IBAction)doneButtonAction:(id)sender;
@property (nonatomic) int companyId;
@property (strong,nonatomic) NSString *companyName;
@end
