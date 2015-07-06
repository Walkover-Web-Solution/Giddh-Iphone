//
//  TripSummaryVC.h
//  Giddh
//
//  Created by Admin on 22/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Companies.h"

@interface TripSummaryVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    NSMutableArray *arrTableData;
    IBOutlet UIBarButtonItem *btnEdit;
    IBOutlet UIBarButtonItem *btnRemove;
    
    NSUserDefaults *userDef;
    
    IBOutlet UITableView *tableViewSummary;
    IBOutlet UITextField *txtSummaryTitle;
    
    //edit summary title
    BOOL editTitleFlag;
    
    //show amount in table view cell
    float dispAmt,totalExpense,perHeadExpense;
    
    NSString *selectedUserEmail;
    IBOutlet UILabel *lblMessage;
    IBOutlet UIButton *btnSync;
    
}
@property (nonatomic) int selectedDbCompanyId;

@property (nonatomic) int selectedTripId;
@property (nonatomic) int selectedTripCompanyId;
@property (nonatomic) int ifTripOwner;
@property (nonatomic,strong) NSString *selectedTripName;
@property (strong, nonatomic) Companies *companies;
//- (IBAction)editAction:(id)sender;
- (IBAction)removeAction:(id)sender;
- (IBAction)syncAction:(id)sender;

@end
