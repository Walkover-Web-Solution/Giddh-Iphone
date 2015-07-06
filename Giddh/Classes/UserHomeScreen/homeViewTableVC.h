//
//  homeViewTableVC.h
//  Giddh
//
//  Created by Admin on 16/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface homeViewTableVC : UITableViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSUserDefaults *userDef;
    NSMutableArray *arrTableData;
    NSString *strCompanyName;
}
- (IBAction)tripAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
