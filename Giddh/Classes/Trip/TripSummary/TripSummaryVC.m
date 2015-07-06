//
//  TripSummaryVC.m
//  Giddh
//
//  Created by Admin on 22/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TripSummaryVC.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "TripShare.h"
#import "AddTripVC.h"
#import "MBProgressHUD.h"
#import "ServiceManager.h"
#import "EntriesInfoTrip.h"
#import "TripSummaryDetailVC.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "AppData.h"

static NSString *const menuCellIdentifier = @"rotationCell";

@interface TripSummaryVC ()<YALContextMenuTableViewDelegate>
@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;
@property (nonatomic, strong) YALContextMenuTableView *contextMenuTableView;
- (IBAction)menuButtonAction:(id)sender;
- (IBAction)checkButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnMenu;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCheck;

@end

@implementation TripSummaryVC
@synthesize selectedTripId,selectedTripName,selectedTripCompanyId,ifTripOwner,companies,selectedDbCompanyId;

- (void)viewDidLoad {
    [super viewDidLoad];
    userDef = [NSUserDefaults standardUserDefaults];
    arrTableData = [NSMutableArray array];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.btnMenu, nil];
    lblMessage.hidden = YES;
    btnSync.hidden = YES;
    [self getLatestData];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self initiateMenuOptions];
    
    editTitleFlag = false;
    dispAmt = 0;
    totalExpense = 0;
    
    //Sync Email List from Server
    if ([[AppData sharedData] isInternetAvailable])
    {
        [self syncEmailList];
    }
    //[self getLatestData];
    /*
    else
    {
        [self getLatestData];
    }
    */
    //[self performSelector:@selector(syncEmailList) withObject:nil afterDelay:0.5];
    
    tableViewSummary.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //self.navigationController.navigationBar.hidden = YES ;
    //UITextField *txtField=[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    //UITextField *txtField=[[UITextField alloc] init];
    //[txtField setBorderStyle:UITextBorderStyleRoundedRect];
    //txtField.text=@"Hello";
    //[self.navigationController.navigationBar addSubview:txtField];
    //[self.navigationItem.titleView addSubview:txtField];
    
    //[self getLatestData];
    //[self performSelector:@selector(reloadTable) withObject:nil afterDelay:0.5];
}

#pragma mark - initiateMenuOptions

- (void)initiateMenuOptions {
    self.menuTitles = @[@"",
                        @"Edit",
                        @"Exit From Trip",
                        ];
    
    self.menuIcons = @[[UIImage imageNamed:@"icn_close"],
                       [UIImage imageNamed:@"Editing256"],
                       [UIImage imageNamed:@"Close256"],
                       ];
}
- (IBAction)menuButtonAction {
       if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.1;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    [self.contextMenuTableView showInView:self.navigationController.view withEdgeInsets:UIEdgeInsetsZero animated:YES];
    
}

-(void) syncEmailList
{
    if ([[AppData sharedData] isInternetAvailable])
    {
        if (arrTableData.count == 0)
        {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"Processing..";
        }
        //hardcode company id = 51
        [[ServiceManager sharedManager ] syncEmailForAuthKey:[userDef valueForKey:@"AuthKey"] andCompanyId:selectedTripCompanyId andTripId:selectedTripId withCompletionBlock:^(NSDictionary *responce, NSError *error)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             NSString *strStatus = [responce valueForKey:@"status"];
             int intStatus = [strStatus intValue];
             if (intStatus == 1)
             {
                 NSArray *arrData = [responce valueForKey:@"data"];
                 for (NSMutableDictionary *dictEmail in arrData)
                 {
                     //save in local DB
                     //check if object already exist in table
                     AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                     NSManagedObjectContext *contextTrip=[appDelegate managedObjectContext];
                     NSFetchRequest *fetchRequestTrip = [[NSFetchRequest alloc] initWithEntityName:@"TripShare"];
                     //Apply filter condition
                     //[fetchRequestTrip setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:selectedTripId]]];
                     //[fetchRequestTrip setPredicate:[NSPredicate predicateWithFormat:@"emailId == %@",[dictEmail valueForKey:@"email"]]];
                     
                     NSPredicate *predicateName = [NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:selectedTripId]];
                     NSPredicate *predicateEmail = [NSPredicate predicateWithFormat:@"emailId == %@", [dictEmail valueForKey:@"email"]];
                     //NSPredicate *predicateCompany = [NSPredicate predicateWithFormat:@"companyId == %@", [NSNumber numberWithInt:[[dictEmail valueForKey:@"companyId"] intValue]]];
                     NSArray *subPredicates = [NSArray arrayWithObjects:predicateName, predicateEmail, nil];
                     
                     NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
                     
                     fetchRequestTrip.predicate = andPredicate;
                     
                     NSArray *emailListArr = [[contextTrip executeFetchRequest:fetchRequestTrip error:nil] mutableCopy];
                     
                     if (emailListArr.count == 0)
                     {
                         //insert enrty in tripShare table
                         NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"TripShare" inManagedObjectContext:contextTrip];
                         if ([dictEmail valueForKey:@"companyName"] == (id)[NSNull null])
                         {
                             [newDevice setValue:[dictEmail valueForKey:@"email"] forKey:@"companyName"];
                         }
                         else
                         {
                             [newDevice setValue:[dictEmail valueForKey:@"companyName"] forKey:@"companyName"];
                         }
                         [newDevice setValue:[NSNumber numberWithInt:selectedTripId] forKey:@"tripId"];
                         [newDevice setValue:[NSNumber numberWithInt:[[dictEmail valueForKey:@"companyId"] intValue]] forKey:@"companyId"];
                         [newDevice setValue:[dictEmail valueForKey:@"email"] forKey:@"emailId"];
                         [newDevice setValue:[NSNumber numberWithInt:[[dictEmail valueForKey:@"owner"] intValue]] forKey:@"owner"];
                     }
                     else
                     {
                         //Update trip list
                         //TripShare *shareObject = [[TripShare alloc]init];
                         TripShare *shareObject = emailListArr[0];
                         if ([dictEmail valueForKey:@"companyName"] == (id)[NSNull null])
                         {
                             shareObject.companyName = [dictEmail valueForKey:@"email"];
                         }
                         else
                         {
                             shareObject.companyName = [dictEmail valueForKey:@"companyName"];
                         }
                         shareObject.tripId = [NSNumber numberWithInt:selectedTripId];
                         shareObject.companyId = [NSNumber numberWithInt:[[dictEmail valueForKey:@"companyId"] intValue]];
                         shareObject.emailId = [dictEmail valueForKey:@"email"];
                         shareObject.owner = [NSNumber numberWithInt:[[dictEmail valueForKey:@"owner"] intValue]];
                     }
                     
                 }
             }
             else
             {
                 NSLog(@"Error while syncing trip");
             }
             
             [self getLatestData];
             //[self performSelector:@selector(getLatestData) withObject:nil afterDelay:0.5];
         }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Internet not Available" message:@"Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show] ;
    }
}


-(void) getLatestData
{
    //get latest trip name
    //[self getLatestData];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *contextTrip=[appDelegate managedObjectContext];
    NSFetchRequest *fetchRequestTrip = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
    //Apply filter condition
    [fetchRequestTrip setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:selectedTripId]]];
    
    NSArray *tripArr = [[contextTrip executeFetchRequest:fetchRequestTrip error:nil] mutableCopy];
    NSManagedObject *tripObject = tripArr[0];
    self.navigationItem.title = [tripObject valueForKey:@"tripName"];
    selectedTripName = [tripObject valueForKey:@"tripName"];
    txtSummaryTitle.text = selectedTripName;
   // self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btnRemove,btnEdit, nil];
    // self.navigationItem.leftBarButtonItem.title = @"abc";
    
    /*
     UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
     label.text=self.navigationItem.title;
     label.textColor=[UIColor whiteColor];
     label.backgroundColor =[UIColor clearColor];
     label.adjustsFontSizeToFitWidth=YES;
     //label.font = [AppHelper titleFont];
     label.textAlignment = NSTextAlignmentCenter;
     self.navigationItem.titleView=label;
     */
    //self.navigationItem.title = selectedTripName;
    
    //get data from local DB
    //AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TripShare"];
    
    //Apply filter condition
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@",[NSNumber numberWithInt:selectedTripId]]];
    
    arrTableData = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    //[arrTableData sortUsingSelector:@selector(caseInsensitiveCompare:)];
    //arrTableData = (NSArray *)[arrTableData sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"emailId" ascending:YES];
    [arrTableData sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    //get total expense details
    for (TripShare *shareObj in arrTableData)
    {
        [self calculateTripExpense:shareObj.emailId isInitial:YES];
    }
    [self reloadTable];
    //[self performSelector:@selector(reloadTable) withObject:nil afterDelay:0.5];
    
}

-(void) reloadTable
{
    //get data from local DB
    //NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    //NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
    //arrTableData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (arrTableData.count == 0)
    {
        //show message label
        lblMessage.hidden = NO;
        btnSync.hidden = NO;
        tableViewSummary.hidden = YES;
    }
    else
    {
        [tableViewSummary reloadData];
        tableViewSummary.hidden = NO;
        lblMessage.hidden = YES;
        btnSync.hidden = YES;
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
   // NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:tableViewSummary]){
        return 50;
    }
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableView isEqual:tableViewSummary]){
        if (section == 0)
        {
            //sub group section
            return 2;
        }
        else
        {
            //accounts section
            return arrTableData.count;
        }

           }
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:tableViewSummary]){
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        float positiveVal;
        // Configure the cell...
        if (indexPath.section == 1)
        {
            TripShare *shareObj = arrTableData[indexPath.row];
            if (shareObj.companyName == (id)[NSNull null])
            {
                cell.textLabel.text = shareObj.emailId;
            }
            else
            {
                cell.textLabel.text = shareObj.companyName;
            }
            int owner = [shareObj.owner intValue];
            if (owner == 1)
            {
                cell.textLabel.textColor = [UIColor orangeColor];
            }
            else
            {
                cell.textLabel.textColor = [UIColor blackColor];
            }
            
            //detail label amount calculations
            [self calculateTripExpense:shareObj.emailId isInitial:NO];
            positiveVal = fabsf(dispAmt);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f",[userDef valueForKey:@"currencySymbol"],positiveVal];
        }
        else
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = @"Total";
                positiveVal = fabsf(totalExpense);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f",[userDef valueForKey:@"currencySymbol"],positiveVal];
                //[NSString stringWithFormat:@"\u20B9 %.2f",positiveVal];
            }
            else
            {
                cell.textLabel.text = @"Per head";
                positiveVal = fabsf(perHeadExpense);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f",[userDef valueForKey:@"currencySymbol"],positiveVal];
            }
        }
        //set font family
        cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
        
        return cell;

    }
    else{

        ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
        
        if (cell) {
            cell.backgroundColor = [UIColor clearColor];
            cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
            cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
            [cell.btnDismiss addTarget:self action:@selector(dismissSideMenu) forControlEvents:UIControlEventAllEvents];
            
        }
        
        return cell;
        
    }
}
-(void)dismissSideMenu{
    [self.contextMenuTableView dismisWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([tableView isEqual:tableViewSummary]){
       return 2;
    }
    return 1;
}
/*
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        //sub group section
        return 2;
    }
    else
    {
        //accounts section
        return arrTableData.count;
    }
    
}
*/
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{   if([tableView isEqual:tableViewSummary]){
        if(section == 0)
            return 0.0f;
        return 32.0f;
}
    return 0;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([tableView isEqual:tableViewSummary]){

        if(section == 0)
            return nil;
        if(section == 1)
            return @"Trip shared with";
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *header;
    if (section == 1)
    {
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        header.backgroundColor = [UIColor colorWithRed:162/255.0f green:151/255.0f blue:144/255.0f alpha:1.0];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        label.font = [UIFont boldSystemFontOfSize:15.0f];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Trip shared with";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
        //label.shadowColor = [UIColor darkGrayColor];
        label.shadowOffset = CGSizeMake(1.0, 1.0);
        [header addSubview:label];
        
        
    }
    else
    {
        //header = [[UIView alloc] initWithFrame:CGRectZero];
        header = nil;
    }
    return nil;
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
        float positiveVal;
    // Configure the cell...
    if (indexPath.section == 1)
    {
        TripShare *shareObj = arrTableData[indexPath.row];
        if (shareObj.companyName == (id)[NSNull null])
        {
            cell.textLabel.text = shareObj.emailId;
        }
        else
        {
            cell.textLabel.text = shareObj.companyName;
        }
        int owner = [shareObj.owner intValue];
        if (owner == 1)
        {
            cell.textLabel.textColor = [UIColor orangeColor];
        }
        else
        {
            cell.textLabel.textColor = [UIColor blackColor];
        }
        
        //detail label amount calculations
        [self calculateTripExpense:shareObj.emailId isInitial:NO];
        positiveVal = fabsf(dispAmt);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f",[userDef valueForKey:@"currencySymbol"],positiveVal];
    }
    else
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Total";
            positiveVal = fabsf(totalExpense);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f",[userDef valueForKey:@"currencySymbol"],positiveVal];
            //[NSString stringWithFormat:@"\u20B9 %.2f",positiveVal];
        }
        else
        {
            cell.textLabel.text = @"Per head";
            positiveVal = fabsf(perHeadExpense);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f",[userDef valueForKey:@"currencySymbol"],positiveVal];
        }
    }
    //set font family
    cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    
    return cell;
    
}
*/
-(void) calculateTripExpense:(NSString *)email isInitial:(BOOL)initialFlag
{
    //detail label amount calculations
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"EntriesInfoTrip" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripId == %@ AND email == %@", [NSNumber numberWithInt:selectedTripId],email];
    
    [request setPredicate:predicate];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arData=[[context executeFetchRequest:request error:&error]mutableCopy];
    dispAmt = 0;
    for (EntriesInfoTrip *objInfo in arData)
    {
        float amt;
        int tranType = [objInfo.transactionType intValue];
        if (tranType == 0)
        {
            //recieving money
            amt = [objInfo.amount floatValue];
            dispAmt += amt;
        }
        
        else
        {
            //giving money
            amt = [objInfo.amount floatValue];
            dispAmt = dispAmt - amt;
        }
        
        //amt = [objInfo.amount floatValue];
        //dispAmt += amt;
        
    }
    if (initialFlag) {
        totalExpense += dispAmt;
        perHeadExpense = totalExpense/arrTableData.count;
    }
    
}
- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:tableViewSummary]){
        if (indexPath.section == 1)
        {
            TripShare *shareObj = arrTableData[indexPath.row];
            selectedUserEmail = shareObj.emailId;
            selectedDbCompanyId = [shareObj.companyId intValue];
            [self performSegueWithIdentifier:@"summaryDetailIdentifier" sender:nil];
        }

    }
    else{
        [tableView dismisWithIndexPath:indexPath];

        if(indexPath.row==1){
            [self performSelector:@selector(editAction) withObject:nil afterDelay:.5];

        }
        else if(indexPath.row == 2){

            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are you sure to delete this trip??" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [av show];
        }
    }
    
}

#pragma mark TableView Delegate Methods
/*
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{if([tableView isEqual:tableViewSummary]){
       else{
        
    }
}
   }
*/
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:tableViewSummary]){

    // Return YES if you want the specified item to be editable.
    if (indexPath.section == 1)
    {
        if (ifTripOwner == 1)
        {
            TripShare *shareObj = arrTableData[indexPath.row];
            int owner = [shareObj.owner intValue];
            if (owner == 1)
            {
                return NO;
            }
            else
            {
                return YES;
            }
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
    }
    else return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripShare *shareObj = arrTableData[indexPath.row];
    NSString *selEmail = shareObj.emailId;
    
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Removing";
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //hit API to delete email
        [[ServiceManager sharedManager] removeEmailForAuthKey:[userDef valueForKey:@"AuthKey"] andTripId:selectedTripId andCompanyId:selectedTripCompanyId andEmail:selEmail withCompletionBlock:^(NSDictionary *responce, NSError *error)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             //NSLog(@"response = %@",responce);
             NSString *strStatus = [responce valueForKey:@"status"];
             //NSLog(@"status = %@",strStatus);
             int intStatus = [strStatus intValue];
             
             if (intStatus == 1)
             {
                 //remove object from DB
                 [context deleteObject:[arrTableData objectAtIndex:indexPath.row]];
                 NSError *error = nil;
                 if (![context save:&error])
                 {
                    // NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                     return;
                 }
                 
                 //remove data from table view array
                 [arrTableData removeObjectAtIndex:indexPath.row];
                 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                 [tableView reloadData];
             }
             else
             {
                 NSLog(@"error while removing email");
             }
         }];
    }
}

-(void) updateTripNameAction
{
    if (editTitleFlag)
    {
        [txtSummaryTitle resignFirstResponder];
        
        if(![txtSummaryTitle.text isEqualToString:selectedTripName])
        {
            if ([[AppData sharedData] isInternetAvailable])
            {
                
            
            //hit API to edit trip Name
            [[ServiceManager sharedManager] editTripForAuthKey:[userDef valueForKey:@"AuthKey"] andTripName:txtSummaryTitle.text andTripId:selectedTripId andCompanyId:selectedTripCompanyId withCompletionBlock:^(NSDictionary *responce, NSError *error)
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 //NSLog(@"response = %@",responce);
                 NSString *strStatus = [responce valueForKey:@"status"];
                 //NSLog(@"status = %@",strStatus);
                 int intStatus = [strStatus intValue];
                 
                 if (intStatus == 1)
                 {
                     //update trip info table
                     AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
                     NSManagedObjectContext *context =[appDelegate managedObjectContext];
                     //NSManagedObjectContext *context = [self managedObjectContext];
                     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
                     
                     //Apply filter condition
                     [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:selectedTripId]]];
                     
                     //NSArray *tempArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                     NSArray *objectArr = [context executeFetchRequest:fetchRequest error:&error];
                     NSManagedObject *tempObject = [objectArr objectAtIndex:0];
                     
                     [tempObject setValue:txtSummaryTitle.text forKey:@"tripName"];
                     
                     //[context save:&error];
                     
                     NSError *error = nil;
                     // Save the object to persistent store
                     if (![context save:&error]) {
                        // NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                     }
                     [self.view endEditing:YES];
                     [self viewWillAppear:NO];
                 }
                 else
                 {
                    // NSLog(@"Error edit trip = %@",error);
                 }
                 //
             }];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Internet not Available" message:@"Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show] ;
            }
        }
    }
}

- (IBAction)removeAction:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are you sure to delete this trip??" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [av show];
}

- (IBAction)syncAction:(id)sender
{
    [self syncEmailList];
}

-(void)hitRemoveAPI
{
    //hit API for deleting trip
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Processing";
    
    [[ServiceManager sharedManager] deleteTripForAuthKey:[userDef valueForKey:@"AuthKey"] andTripId:selectedTripId andCompanyId:selectedTripCompanyId withCompletionBlock:^(NSDictionary *responce, NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         NSString *strStatus = [responce valueForKey:@"status"];
         int intStatus = [strStatus intValue];
         
         if (intStatus == 1)
         {
             //delete data from DB table
             AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
             NSManagedObjectContext *contextTrip=[appDelegate managedObjectContext];
             NSFetchRequest *fetchRequestTrip = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
             //Apply filter condition
             [fetchRequestTrip setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:selectedTripId]]];
             NSArray *tripArr = [[contextTrip executeFetchRequest:fetchRequestTrip error:nil] mutableCopy];
             NSManagedObject *tripObject = tripArr[0];
             [contextTrip deleteObject:tripObject];
             NSError *error = nil;
             if (![contextTrip save:&error])
             {
                 //NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                 return;
             }
             
             UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Done" message:@"Trip Deleted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [av show];
             [self.navigationController popViewControllerAnimated:YES];
         }
         else
         {
            // NSLog(@"Error while deleting trip");
         }
     }];
}

- (IBAction)editAction
{
    //[self.view endEditing:YES];
    if (editTitleFlag)
    {
        [self updateTripNameAction];
    }
    else
    {
        if (!ifTripOwner)
        {
            [txtSummaryTitle becomeFirstResponder];
        }
        else
        {
            //[self performSegueWithIdentifier:@"editTripIdentifier" sender:nil];
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
            AddTripVC *vc = [sb instantiateViewControllerWithIdentifier:@"AddTripVC"];
            vc.editFlag = true;
            vc.strEditTripName = selectedTripName;
            vc.intEditTripId = selectedTripId;
            vc.intCompanyId = selectedTripCompanyId;
            vc.ifTripOwner = ifTripOwner;
            //navController.navigationBarHidden =YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"editTripIdentifier"])
    {
        AddTripVC *vc = [segue destinationViewController];
        vc.editFlag = true;
        vc.strEditTripName = selectedTripName;
        vc.intEditTripId = selectedTripId;
        vc.intCompanyId = selectedTripCompanyId;
        vc.ifTripOwner = ifTripOwner;
    }
    else if ([[segue identifier] isEqualToString:@"summaryDetailIdentifier"])
    {
        TripSummaryDetailVC *detVC = [segue destinationViewController];
        detVC.selectedTripId = selectedTripId;
        detVC.tripEmail = selectedUserEmail;
        detVC.selectedTripName = selectedTripName;
        //detVC.selectedTripCompanyId = selectedTripCompanyId;
        detVC.selectedTripCompanyId = selectedDbCompanyId;
        detVC.companies = companies;
    }
}

#pragma mark Text Field Delegate Methods
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.btnMenu,self.btnCheck, nil];

    editTitleFlag = true;
   // [btnEdit setImage:[UIImage imageNamed:@"checkIcon03.png"]];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    editTitleFlag = false;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.btnMenu, nil];

   // [btnEdit setImage:[UIImage imageNamed:@"pencil.png"]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self hitRemoveAPI];
    }
}
- (IBAction)menuButtonAction:(id)sender {
    [self menuButtonAction];
}

- (IBAction)checkButtonAction:(id)sender {
    if (editTitleFlag)
    {
        [self updateTripNameAction];
    }
    else
    {
        if (!ifTripOwner)
        {
            [txtSummaryTitle becomeFirstResponder];
        }
        else
        {
            [self performSegueWithIdentifier:@"editTripIdentifier" sender:nil];
        }
    }

}
@end
