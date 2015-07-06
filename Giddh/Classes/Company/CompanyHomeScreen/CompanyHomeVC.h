//
//  CompanyHomeVC.h
//  Giddh
//
//  Created by Admin on 16/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyHomeVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate>
{
    //picker view properties
    UIDatePicker *picView;
    UIButton *btnCancel,*btnDone;
    IBOutlet UIButton *btnDate;
    
    //date format as per API
    NSString *strAPIDate;
    IBOutlet UITableView *tableViewAccount;
    
    //array items for parsing
    NSMutableArray *arrGroupName,*arrGroupClosingBal,*arrayGroup;
    NSDictionary *currentDict;
    
    //Search bar
    BOOL searchFlag,goFlag;
    NSString *textSearch;
    NSUserDefaults *userDef;
    IBOutlet UILabel *lblMessage;
    IBOutlet UIButton *btnSync;
}

@property (strong , nonatomic) NSString *companyName;
@property (nonatomic) int companyId;
- (IBAction)dateAction:(id)sender;
- (IBAction)goAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)syncAction:(id)sender;
@property (strong , nonatomic) NSString *globalDate;
@end
