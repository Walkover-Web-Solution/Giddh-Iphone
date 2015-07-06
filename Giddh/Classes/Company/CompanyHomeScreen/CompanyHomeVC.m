//
//  CompanyHomeVC.m
//  Giddh
//
//  Created by Admin on 16/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "CompanyHomeVC.h"
#import "ServiceManager.h"
#import "MBProgressHUD.h"
#import "SubGroupAccountVC.h"
#import "AppData.h"

@interface CompanyHomeVC ()

@end

@implementation CompanyHomeVC
@synthesize companyName,companyId,globalDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    userDef = [NSUserDefaults standardUserDefaults];
    
    self.navigationItem.title = companyName;
    //[self.navigationItem.titleView sizeToFit];
    CGFloat width = [companyName sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"GothamRounded-Light" size:20 ]}].width;
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width - self.navigationItem.leftBarButtonItem.width, self.navigationController.navigationBar.frame.size.height)];
    tlabel.frame = CGRectMake(0, 0, width,30);
    tlabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:20];
    tlabel.text=self.navigationItem.title;
    tlabel.textColor=[UIColor whiteColor];
    //tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    arrayGroup = [[NSMutableArray alloc]init];
    arrGroupName = [NSMutableArray array];
    arrGroupClosingBal = [NSMutableArray array];
    
    //search bar
    searchFlag = true;
    textSearch = @"";
    
    //get current date trial balance
    //convert date to string
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //strAPIDate = [formatter stringFromDate:[NSDate date]];
    strAPIDate = globalDate;
    NSDate *dateSelected = [formatter dateFromString:strAPIDate];
    
    lblMessage.hidden = YES;
    btnSync.hidden = YES;
    
    //hit API
    if ([[AppData sharedData] isInternetAvailable])
    {
        [self goAction:nil];
    }
    
    //[self performSelector:@selector(reloadTable) withObject:nil afterDelay:0.5];
    //set current date in date button
    [formatter setDateFormat:@"dd MMM yyyy"];
    //NSString *strSchedule = [formatter stringFromDate:[NSDate date]];
    NSString *strSchedule = [formatter stringFromDate:dateSelected];
    [btnDate setTitle:strSchedule forState:UIControlStateNormal];
    tableViewAccount.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //set datepicker date according to financial year(toYear)
    //[btnDate setTitle:strDate forState:UIControlStateNormal];
}


-(void)viewWillAppear:(BOOL)animated
{
   // NSLog(@"arr grp = %@",arrayGroup);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Data Source Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrGroupName.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    
    UITableViewCell *cell = [tableViewAccount dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    cell.textLabel.text = arrGroupName[indexPath.row];
    double closingBal = [arrGroupClosingBal[indexPath.row] doubleValue];
    double tempBal = fabs(closingBal);
    if (closingBal > 0)
    {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:9.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
    }
    else
    {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",[userDef valueForKey:@"currencySymbol"],strVal];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f",[userDef valueForKey:@"currencySymbol"],tempBal];
    //[self formatToTwoDigitValueForNumber:tempBal]
    //set font family
    
    cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    
    return cell;
    

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentDict = arrayGroup[indexPath.row];
    //NSLog(@"group =-> %@",[currentDict valueForKey:@"subGroupDetails"]);
    
    if (![[currentDict valueForKey:@"subGroupDetails"] isEqual:(id)[NSNull null]])
    {
        //move to next view controller
        [self performSegueWithIdentifier:@"detailGroupIdentifier" sender:nil];
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    SubGroupAccountVC *vc = [segue destinationViewController];
    vc.accountDictionary = currentDict;
}


#pragma mark Date Picker Methods
- (IBAction)dateAction:(id)sender
{
    //show date picker
    picView=[[UIDatePicker alloc] initWithFrame:CGRectZero];
    CGRect bounds = [self.view bounds];
    int datePickerHeight = picView.frame.size.height;
    picView.frame = CGRectMake(0, bounds.size.height - (datePickerHeight), picView.frame.size.width, picView.frame.size.height);
    
    [picView setBackgroundColor:[UIColor whiteColor]];
    picView.datePickerMode = UIDatePickerModeDate;
    
    //convert nsstring to nsdate
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *pickerDate = [formatter dateFromString:globalDate];
    
    //set minimum date and maximum date according to financial year
     NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
     NSDateComponents *comps = [[NSDateComponents alloc] init];
     [comps setYear:-1];
    [comps setDay:+1];
     NSDate *minDate = [gregorian dateByAddingComponents:comps toDate:pickerDate  options:0];
     
     picView.minimumDate = minDate;
     picView.maximumDate = pickerDate;
    /*
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMinute:+1];
    NSDate *minDate = [gregorian dateByAddingComponents:comps toDate:currentDate  options:0];
    //[picView setMinimumDate:minDate];
    [picView setMaximumDate:minDate];
    
    //[picView setMinimumDate:[NSDate date]];
    */
    [self.view addSubview:picView];
    
    //picker view header
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, picView.frame.size.width, 40)];
    [headerView setBackgroundColor:[UIColor colorWithRed:230/255.0f green:103/255.0f blue:61/255.0f alpha:1]];
    //[headerView setBackgroundColor:[UIColor lightGrayColor ]];
    [picView addSubview:headerView];
    
    btnCancel=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:18];
    [btnCancel setFrame:CGRectMake(5, bounds.size.height - (datePickerHeight), 100, 36)];
    btnCancel.tag=0;
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];
    
    
    btnDone=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone setFrame:CGRectMake(self.view.frame.size.width-2-100, bounds.size.height - (datePickerHeight), 100, 36)];
    btnDone.tag=1;
    btnDone.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:18];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDone];

}

- (IBAction)goAction:(id)sender
{
    [arrGroupName removeAllObjects];
    if ([[AppData sharedData]isInternetAvailable ])
    {
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Fetching Details..";
    
    //check search bar text
    if (goFlag)
    {
        //go action for search bar text
        //hit API
        [[ServiceManager sharedManager] getTrialBalanceForCompanyName:companyName andCompanyId:companyId andDate:strAPIDate andMobile:@"1" andSearchBy:textSearch withCompletionBlock:^(NSDictionary *responce, NSError *error)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             //NSLog(@"response = %@",responce);
             NSString *strStatus = [responce valueForKey:@"status"];
             //NSLog(@"status = %@",strStatus);
             int intStatus = [strStatus intValue];
             
             if (intStatus == 1)
             {
                 NSArray *arrData = [responce valueForKey:@"data"];
                 //NSLog(@"data arr -> %@",arrData);
                 NSMutableArray *arrGroups = [arrData valueForKey:@"groupDetail"];
                 
                 arrayGroup = arrGroups[0];
                 //get group details
                 
                 for (NSMutableDictionary *dictGroup in arrayGroup)
                 {
                     //NSLog(@"group 1-> %@",[dictGroup valueForKey:@"groupName"]);
                     int strLen = (int)[NSString stringWithFormat:@"%@",[dictGroup valueForKey:@"groupName"]].length;
                     if (strLen > 0)
                     {
                         [arrGroupName addObject:[dictGroup valueForKey:@"groupName"]];
                         [arrGroupClosingBal addObject:[dictGroup valueForKey:@"closingBalance"]];
                     }
                     
                 }
                 
                 //            NSString *strAuth = arrAuth[0];
                 //            //[userDef setValue:strAuth forKey:@"AuthKey"];
                 //            [self performSegueWithIdentifier:@"homeTableSegue" sender:nil];
             } else
             {
                // NSLog(@"Error");
             }
             
             //reload table
             [self reloadTable];
             //[tableViewAccount reloadData];
             //searchFlag = 1;
         }];
    }
    else
    {
        //hit API
        [[ServiceManager sharedManager] getTrialBalanceForCompanyName:companyName andCompanyId:companyId andDate:strAPIDate andMobile:@"1" andSearchBy:@"" withCompletionBlock:^(NSDictionary *responce, NSError *error)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             //NSLog(@"response = %@",responce);
             NSString *strStatus = [responce valueForKey:@"status"];
             //NSLog(@"status = %@",strStatus);
             int intStatus = [strStatus intValue];
             
             if(intStatus == 1)
             {
                 NSArray *arrData = [responce valueForKey:@"data"];
                 //NSLog(@"data arr -> %@",arrData);
                 NSMutableArray *arrGroups = [arrData valueForKey:@"groupDetail"];
                 
                 arrayGroup = arrGroups[0];
                 //get group details
                 
                 for (NSMutableDictionary *dictGroup in arrayGroup)
                 {
                     //NSLog(@"group 2-> %@",[dictGroup valueForKey:@"groupName"]);
                     int strLen = (int)[NSString stringWithFormat:@"%@",[dictGroup valueForKey:@"groupName"]].length;
                     if (strLen > 0)
                     {
                         [arrGroupName addObject:[dictGroup valueForKey:@"groupName"]];
                         [arrGroupClosingBal addObject:[dictGroup valueForKey:@"closingBalance"]];
                     }
                     //[arrGroupName addObject:[dictGroup valueForKey:@"groupName"]];
                     //[arrGroupClosingBal addObject:[dictGroup valueForKey:@"closingBalance"]];
                 }
                 
                 //            NSString *strAuth = arrAuth[0];
                 //            //[userDef setValue:strAuth forKey:@"AuthKey"];
                 //            [self performSegueWithIdentifier:@"homeTableSegue" sender:nil];
             } else
             {
                 //NSLog(@"Error");
             }
             
             //reload table
             [self reloadTable];
             //[tableViewAccount reloadData];
             
         }];
    }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Internet not Available" message:@"Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil] show];
    }
}


-(void) reloadTable
{
    //get data from local DB
    //NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    //NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
    //arrTableData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if ((arrGroupName.count == 0) && (![[AppData sharedData] isInternetAvailable]))
    {
        //show message label
        lblMessage.hidden = NO;
        btnSync.hidden = NO;
        tableViewAccount.hidden = YES;
    }
    else
    {
        [tableViewAccount reloadData];
        tableViewAccount.hidden = NO;
        lblMessage.hidden = YES;
        btnSync.hidden = YES;
    }
}

- (IBAction)searchAction:(id)sender
{
    if (searchFlag)
    {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        searchBar.delegate = self;
        tableViewAccount.tableHeaderView = searchBar;
        searchFlag = false;
        goFlag = true;
    }
    else
    {
        tableViewAccount.tableHeaderView = nil;
        self.automaticallyAdjustsScrollViewInsets = YES;
        searchFlag = true;
        goFlag = false;
        //[self viewDidLoad];
    }
    
    
}

- (IBAction)syncAction:(id)sender
{
    [self goAction:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //hit API with text
    //NSLog(@"%@",searchText);
    textSearch = searchText;
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{

}
//cancel button event
-(void) cancelAction : (UIPickerView *)pc
{
    [pc removeFromSuperview];
    picView.hidden = YES;
    btnCancel.hidden = btnDone.hidden = YES;
    //[btnSchedule setImage:[UIImage imageNamed:@"sch_off.png"] forState:UIControlStateNormal];
    //lblSchedule.text = @"Schedule";
    //[btnSchedule setTitle:@"Schedule" forState:UIControlStateNormal];
}

//done button event
-(void) doneAction : (UIPickerView *)pc
{
    [pc removeFromSuperview];
    picView.hidden = YES;
    btnCancel.hidden = btnDone.hidden = YES;
    
    //convert date to string
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    strAPIDate = [formatter stringFromDate:picView.date];
    
    //hit API
    [self goAction:nil];
    
    [formatter setDateFormat:@"dd MMM yyyy"];
    NSString *strSchedule = [formatter stringFromDate:picView.date];
    
    [btnDate setTitle:strSchedule forState:UIControlStateNormal];
}

-(NSString*)formatToTwoDigitValueForNumber:(double)number{
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    return  [fmt stringFromNumber:[NSNumber numberWithFloat:number]];
}
@end
