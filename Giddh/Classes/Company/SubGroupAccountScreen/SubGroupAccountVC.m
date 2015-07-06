//
//  SubGroupAccountVC.m
//  Giddh
//
//  Created by Admin on 18/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "SubGroupAccountVC.h"

@interface SubGroupAccountVC ()

@end

@implementation SubGroupAccountVC
@synthesize accountDictionary;

- (void)viewDidLoad
{
    [super viewDidLoad];
    userDef = [NSUserDefaults standardUserDefaults];
    
    
    
    firstReload = true;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    tableViewSubGroup.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    arrSubGroups = [NSMutableArray array];
    arrClosingBal = [NSMutableArray array];
    arrGroupDetails = [NSMutableArray array];
    arrAccounts = [NSMutableArray array];
    arrAccName = [NSMutableArray array];
    arrAccBalance = [NSMutableArray array];
    arrayGlobal = [NSMutableArray array];
    
    self.navigationItem.title = [accountDictionary valueForKey:@"groupName"];
    
    //[arrSubGroups removeAllObjects];
    //[arrAccounts removeAllObjects];
    //[arrAccName removeAllObjects];
    //[arrAccBalance removeAllObjects];
    /*
    if (firstReload)
    {
       [arrayGlobal addObject:accountDictionary];
    }
    */
    
    arrGroupDetails = [accountDictionary valueForKey:@"subGroupDetails"];
    
    arrAccounts = [accountDictionary valueForKey:@"accountDetails"];
    
    for (NSMutableDictionary *dictAccount in arrAccounts)
    {
        int strLen = (int)[NSString stringWithFormat:@"%@",[dictAccount valueForKey:@"accountName"]].length;
        if (strLen > 0)
        {
            [arrAccName addObject:[dictAccount valueForKey:@"accountName"]];
            [arrAccBalance addObject:[dictAccount valueForKey:@"openingBalance"]];
        }
    }
    for (NSMutableDictionary *dictGroup in arrGroupDetails)
    {
        int strLen = (int)[NSString stringWithFormat:@"%@",[dictGroup valueForKey:@"groupName"]].length;
        if (strLen > 0)
        {
            [arrSubGroups addObject:[dictGroup valueForKey:@"groupName"]];
            [arrClosingBal addObject:[dictGroup valueForKey:@"closingBalance"]];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        //sub group section
        return arrSubGroups.count;
    }
    else
    {
        //accounts section
        return arrAccounts.count;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Sub Groups";
    if(section == 1)
        return @"Accounts";
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableViewSubGroup dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    //Configure the cell...
//    cell.textLabel.text = arrGroupName[indexPath.row];
//    double closingBal = [arrGroupClosingBal[indexPath.row] doubleValue];
//    double tempBal = fabs(closingBal);
//    if (closingBal > 0)
//    {
//        cell.detailTextLabel.textColor = [UIColor colorWithRed:9.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
//    }
//    else
//    {
//        cell.detailTextLabel.textColor = [UIColor redColor];
//    }
//    
//    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",[userDef valueForKey:@"currencySymbol"],strVal];
//    
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f",[userDef valueForKey:@"currencySymbol"],tempBal];
//    
    if (indexPath.section == 0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%d. %@",indexPath.row+1,arrSubGroups[indexPath.row]];
        double closingBal = [arrClosingBal[indexPath.row] doubleValue];
        double tempBal = fabs(closingBal);
        if (closingBal > 0)
        {
            cell.detailTextLabel.textColor = [UIColor colorWithRed:9.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
        }
        else
        {
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
        
        //NSString *strVal = [self formatToTwoDigitValueForNumber:closingBal];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f",[userDef valueForKey:@"currencySymbol"],tempBal];
       // cell.detailTextLabel.text = [NSString stringWithFormat:@"\u20B9 %@",arrClosingBal[indexPath.row]];
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%d. %@",indexPath.row+1,arrAccName[indexPath.row]];
        double closingBal = [arrAccBalance[indexPath.row] doubleValue];
        double tempBal = fabs(closingBal);
        if (closingBal > 0)
        {
            cell.detailTextLabel.textColor = [UIColor colorWithRed:9.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
        }
        else
        {
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
        
        //NSString *strVal = [self formatToTwoDigitValueForNumber:closingBal];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",tempBal];
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"\u20B9 %@",arrAccBalance[indexPath.row]];
    }
    
    
    
    //set font family
    cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
    return cell;
    
}

#pragma mark Table View Delegate Methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [arrayGlobal addObject:accountDictionary];
        //reload subgroup list
        NSArray *arrTemp = [accountDictionary valueForKey:@"subGroupDetails"];
        NSDictionary *dictTemp = arrTemp[indexPath.row];
        
        NSArray *arrSub = [dictTemp valueForKey:@"subGroupDetails"];
        NSArray *arrAcc = [dictTemp valueForKey:@"accountDetails"];
        if (arrSub.count > 0 || arrAcc.count > 0)
        {
            accountDictionary = dictTemp;
            //[arrayGlobal addObject:accountDictionary];
            //firstReload = false;
            [self viewWillAppear:NO];
            [tableViewSubGroup reloadData];
        }
        else
        {
            [arrayGlobal removeLastObject];
        }
        
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(id)sender
{
  //  NSLog(@"back arr = %@",arrayGlobal);
    if (arrayGlobal.count > 0)
    {
        accountDictionary = [arrayGlobal lastObject];
        firstReload = false;
        [self viewWillAppear:NO];
        [tableViewSubGroup reloadData];
        [arrayGlobal removeLastObject];
    }
    else
    {
        [arrayGlobal removeAllObjects];
        [self.navigationController popViewControllerAnimated:YES];
    }
    //[self.navigationController popViewControllerAnimated:YES];
}

-(NSString*)formatToTwoDigitValueForNumber:(double)number{
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    return  [fmt stringFromNumber:[NSNumber numberWithFloat:number]];
}
@end
