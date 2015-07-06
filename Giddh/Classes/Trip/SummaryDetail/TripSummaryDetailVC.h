//
//  TripSummaryDetailVC.h
//  Giddh
//
//  Created by Admin on 22/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCMoreOptionTableViewCell.h"
#import "MSCMoreOptionTableViewCellDelegate.h"
#import "Companies.h"

@interface TripSummaryDetailVC : UIViewController<UITableViewDataSource,UITableViewDelegate,MSCMoreOptionTableViewCellDelegate>
{
    IBOutlet UITableView *tableViewDetails;
    NSMutableArray *arrTableData,*arrAccounts,*arrSummaryEntry,*arrAllEntries;//arrSummaryDetail
    NSArray *arrResult,*arrayUniqueDate;
    NSUserDefaults *userDef;
    
    IBOutlet UILabel *lblMessage;
    
}
@property (strong,nonatomic) NSString *tripEmail;
@property (nonatomic) int selectedTripId;
@property (nonatomic) int selectedTripCompanyId;
@property (nonatomic,strong) NSString *selectedTripName;
@property (strong, nonatomic) Companies *companies;

@end
