//
//  UserHomeVC.h
//  Giddh
//
//  Created by Admin on 06/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserHomeVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    IBOutlet UITableView *tableViewUser;
    NSUserDefaults *userDef;
    NSMutableArray *arrTableData;
    NSString *strCompanyName,*strGlobalDate;
    int companyId;
}
- (IBAction)logout:(id)sender;
@end
