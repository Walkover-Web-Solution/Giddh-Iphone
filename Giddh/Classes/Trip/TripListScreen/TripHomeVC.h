//
//  TripHomeVC.h
//  Giddh
//
//  Created by Admin on 21/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Companies.h"
@interface TripHomeVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UITableView *tableViewTrips;
    NSMutableArray *arrTableData;
    int selTripId,selCompanyId,ifOwner;
    NSString *selTripName;
    NSUserDefaults *userDef;
    
    //sync data
    NSArray *arrAccounts;
    IBOutlet UILabel *lblMessage;
    IBOutlet UIButton *btnSync;
}
@property (strong,nonatomic) Companies *companies;

- (IBAction)addTripAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)syncAction:(id)sender;
@property (nonatomic) int globalCompanyId;
@end
