//
//  TripSummaryDetailVC.m
//  Giddh
//
//  Created by Admin on 22/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TripSummaryDetailVC.h"
#import "AppDelegate.h"
#import "EntriesInfoTrip.h"
#import "Accounts.h"
#import "SummaryEntry.h"
#import "SummaryDetail.h"
#import "SummaryTableViewCell.h"
#import "SummaryAccount.h"
#import "EditEntryViewController.h"
#import "SummaryAccount.h"
#import "ServiceManager.h"

@interface TripSummaryDetailVC ()

@end

@implementation TripSummaryDetailVC
@synthesize tripEmail,selectedTripId,selectedTripName,selectedTripCompanyId,companies;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userDef = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view.
    tableViewDetails.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableViewDetails.allowsSelection = NO;
    lblMessage.hidden = YES;
    //set multiple labels in navigation bar
    UIView *btn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    
    UILabel *label;
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 240, 16)];
    label.tag = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"GothamRounded-Light" size:20];
    label.adjustsFontSizeToFitWidth = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = selectedTripName;
    //label.highlightedTextColor = [UIColor blackColor];
    [btn addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 240, 16)];
    label.tag = 2;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    label.adjustsFontSizeToFitWidth = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = tripEmail;
    //label.highlightedTextColor = [UIColor blackColor];
    [btn addSubview:label];
    
    self.navigationItem.titleView = btn;
    
    //get all data from entries entity
    [self getAllEntries];
}

-(void)getAllEntries{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrAllEntries = [[context executeFetchRequest:request error:&error]mutableCopy];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    arrTableData = [NSMutableArray array];
    
    arrResult = [NSMutableArray array];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    //create managed object context
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"EntriesInfoTrip"];
    //NSEntityDescription* entity = [NSEntityDescription entityForName:@"EntriesInfoTrip" inManagedObjectContext:context];
    //NSAttributeDescription* clsName = [entity.attributesByName objectForKey:@"date"];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName: @"count"];
    [expressionDescription setExpressionResultType: NSInteger32AttributeType];
    //[fetch setPropertiesToFetch:[NSArray arrayWithObjects:clsName, nil]];
    //[fetch setPropertiesToGroupBy:[NSArray arrayWithObject:clsName]];
    //[fetch setResultType:NSDictionaryResultType];
    NSError* error = nil;
    arrResult = [context executeFetchRequest:fetch  error:&error];
    NSMutableArray *arrDate = [NSMutableArray array];
    for(NSDictionary *date in arrResult)
    {
        [arrDate addObject:[date valueForKey:@"date"]];
    }
    [arrDate sortUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
        // return date2 compare date1 for descending. Or reverse the call for ascending.
        return [date2 compare:date1];
    }];
    //NSLog(@"date array = %@",arrDate);
    //return arrDate;
    NSMutableArray *finalDateArr = [NSMutableArray array];
    //split date and time
    for (NSString *strDateTime in arrDate)
    {
        NSArray *arrDateTime = [strDateTime componentsSeparatedByString:@" "];
        NSString *strDate = arrDateTime[0];
        [finalDateArr addObject:strDate];
    }
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:finalDateArr];
    arrayUniqueDate = [orderedSet array];
    [self sortEntriesByDate:arrayUniqueDate];
    
}

-(void) sortEntriesByDate:(NSArray *)arrData
{
    
    arrSummaryEntry = [NSMutableArray array];;
    
    for(NSString *date in arrData){
        SummaryEntry *summaryEntry = [[SummaryEntry alloc]init];
        
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context=[appDelegate managedObjectContext];
        NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"EntriesInfoTrip" inManagedObjectContext:context];
        NSFetchRequest *request=[[NSFetchRequest alloc]init];
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripId == %@ AND email == %@", [NSNumber numberWithInt:selectedTripId],tripEmail];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date beginswith[c] %@ AND tripId == %@ AND companyId == %@",date,[NSNumber numberWithInt:selectedTripId],[NSNumber numberWithInt:selectedTripCompanyId] ];
        
        [request setPredicate:predicate];
        [request setEntity:entityDescr];
        NSError *error;
        NSArray *arrSameDateEntries =[[context executeFetchRequest:request error:&error]mutableCopy];
        
        NSMutableArray *arrEntry =[NSMutableArray array];
        
        for(EntriesInfoTrip * entInfo in arrSameDateEntries)
        {
            /*
             SummaryDetail *summaryDet =[[SummaryDetail alloc]init];
             summaryDet.amount = entInfo.amount;
             summaryDet.transactionType = entInfo.transactionType;
             summaryDet.creditAccount = entInfo.creditAccount;
             summaryDet.debitAccount = entInfo.debitAccount;
             
             [arrEntry addObject:summaryDet];
             */
            SummaryAccount *summaryAcc = [[SummaryAccount alloc]init];
            summaryAcc.sum = [entInfo.amount doubleValue];
            summaryAcc.transactionType = [NSString stringWithFormat:@"%@",entInfo.transactionType];
            if ([summaryAcc.transactionType intValue] == 0 )
            {
                summaryAcc.accountId = entInfo.creditAccount;
            }
            else
            {
                summaryAcc.accountId = entInfo.debitAccount;
            }
            summaryAcc.objId = [entInfo objectID];
            [arrEntry addObject:summaryAcc];
            
        }
        summaryEntry.arrEntries = arrEntry;
        summaryEntry.date = date;
        if(arrEntry.count!=0)
        {
            [arrSummaryEntry addObject:summaryEntry];
        }
    }
    
    if (arrSummaryEntry.count == 0)
    {
        lblMessage.hidden = NO;
        tableViewDetails.hidden = YES;
    }
    else
    {
        [tableViewDetails reloadData];
        tableViewDetails.hidden = NO;
        lblMessage.hidden = YES;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return arrSummaryEntry.count;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SummaryEntry *summaryEntry = arrSummaryEntry[section];
    return summaryEntry.arrEntries.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SummaryEntry *summaryEntry = arrSummaryEntry[section];
    
    NSString *originalDateString = summaryEntry.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date = [dateFormatter dateFromString:originalDateString];
    
    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];//22-Nov-2012
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    return formattedDateString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MSCMoreOptionTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    //code 02
    SummaryEntry *sumEntry = arrSummaryEntry[indexPath.section];
    NSArray *arrData = sumEntry.arrEntries;
    //SummaryDetail *sumDetail  = arrData[indexPath.row];
    SummaryAccount *sumDetail  = arrData[indexPath.row];
    cell.textLabel.text = sumDetail.emailIfLoan;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f",[userDef valueForKey:@"currencySymbol"], sumDetail.sum];
    NSString *userEmail = [userDef valueForKey:@"userEmail"];
    NSString *accName;
    
    if ([userEmail isEqualToString:tripEmail])
    {
        int accId;
        accId = [sumDetail.accountId intValue];
        if([sumDetail.transactionType intValue] == 0)
        {
            //accId = [sumDetail.creditAccount intValue];
            //cell.detailTextLabel.textColor = [UIColor greenColor];
            cell.detailTextLabel.textColor = [UIColor greenColor];
        }
        else
        {
            //accId = [sumDetail.debitAccount intValue];
            //cell.detailTextLabel.textColor = [UIColor redColor];
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
        accName = [self getAccountNameById:accId];
    }
    else
    {
        accName = [NSString stringWithFormat:@"%@",sumDetail.accountId];
        if([sumDetail.transactionType intValue] == 0)
        {
            //accName = [NSString stringWithFormat:@"%@",sumDetail.creditAccount];
            cell.detailTextLabel.textColor = [UIColor greenColor];
        }
        else
        {
            //accName = [NSString stringWithFormat:@"%@",sumDetail.debitAccount];
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
    }
    
    cell.textLabel.text = accName;
    
    //set font family
    cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    return cell;
}


#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Called when 'delete' button is pushed.
        // NSLog(@"DELETE button pushed in row at: %@", indexPath.description);
        
        SummaryEntry *summaryEntry = arrSummaryEntry[indexPath.section];
        NSArray *arrData = summaryEntry.arrEntries;
        SummaryAccount *summaryAccount  = arrData[indexPath.row];
        [self hitDeleteEntryApiForForManagedObjectId:summaryAccount.objId];
        //[self sortAllDataForAccountId:self.accountId];
        // Hide 'more'- and 'delete'-confirmation view
        [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
            if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
                [cell hideDeleteConfirmation];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*
     vc.companies = self.companies;
     */
    // Called when 'more' button is pushed.
    SummaryEntry *summaryEntry = arrSummaryEntry[indexPath.section];
    NSArray *arrData = summaryEntry.arrEntries;
    SummaryAccount *summaryAccount  = arrData[indexPath.row];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
    EditEntryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EditEntryViewController"];
    vc.objId = summaryAccount.objId;
    vc.tripSummaryFlag = true;
    vc.companies = companies;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:vc animated:YES];
    // Hide 'more'- and 'delete'-confirmation view
    [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
        if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
            [cell hideDeleteConfirmation];
        }
    }];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Edit";
    /*
     NSString *str = @"Edit";
     NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:str];
     NSInteger _stringLength=[str length];
     
     UIColor *_red=[UIColor redColor];
     UIFont *font=[UIFont fontWithName:@"GothamRounded-Light" size:16.0f];
     [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, _stringLength)];
     [attString addAttribute:NSStrokeColorAttributeName value:_red range:NSMakeRange(0, _stringLength)];
     [attString addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:-3.0] range:NSMakeRange(0, _stringLength)];
     NSString *strFinal = [NSString stringWithFormat:@"%@",attString];
     
     return strFinal;
     */
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[userDef valueForKey:@"userEmail"] isEqualToString:tripEmail])
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


-(NSString *)getAccountNameById:(int)accountId
{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountId == %@",[NSNumber numberWithInt:accountId]];
    [request setPredicate:predicate];
    [request setEntity:entityDescr];
    NSError *error;
    arrAccounts=[[context executeFetchRequest:request error:&error]mutableCopy];
    
    Accounts *objAcc = arrAccounts[0];
    NSString *accName = objAcc.accountName;
    return accName;
}

-(void)hitDeleteEntryApiForForManagedObjectId:(NSManagedObjectID*)objId{
    for(EntriesInfoTrip *entries in arrResult)
    {
        if([entries.objectID isEqual:objId]){
            // hit delete entry api with  entries.entryId
            MBProgressHUD * hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"Processing...";
            
            [[ServiceManager sharedManager]deleteEntrywithEntryId:[NSString stringWithFormat:@"%@",entries.entryId] withDeleteStatus:@"1" forAuthKey:@"" andCompanyName:[self getCompanyNameById:selectedTripCompanyId] withCompletionBlock:^(NSDictionary *responce, NSError *error) {
                // NSLog(@"%@",responce);
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSString *status  = [NSString stringWithFormat:@"%@",[responce valueForKey:@"status"]];
                if([status isEqual:@"1"])
                {
                    [self deleteEntryForManagedObjectId:objId];
                }
                else
                {
                    // add entry in delete entry table
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    //create managed object context
                    NSManagedObjectContext *context = [appDelegate managedObjectContext];
                    NSManagedObject *newDeleteEntry = [NSEntityDescription insertNewObjectForEntityForName:@"DeletedEntries" inManagedObjectContext:context];
                    for(Entries * entries in arrResult)
                    {
                        if([entries.objectID isEqual:objId])
                        {
                            NSError *error;
                            [newDeleteEntry setValue:entries.entryId forKeyPath:@"entryId"];
                            [context insertObject:newDeleteEntry];
                            [context save:&error];
                        }
                    }
                }
            }];
        }
    }
}

-(void)deleteEntryForManagedObjectId:(NSManagedObjectID*)objId{
    for(EntriesInfoTrip * entries in arrResult){
        if([entries.objectID isEqual:objId]){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            //create managed object context
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            NSError *error;
            [self deleteEntriesObjectForEntryId:entries.entryId];
            [context deleteObject:entries];
            [context save:&error];
            //[self sortAllDataForAccountId:self.accountId];
            [self viewWillAppear:NO];
            
        }
    }
}

-(void)deleteEntriesObjectForEntryId:(NSNumber*)entryId{
    for(Entries *entriesObj in arrAllEntries)
    {
        if([entriesObj.entryId isEqual:entryId]){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            //create managed object context
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            NSError *error;
            [context deleteObject:entriesObj];
            [context save:&error];
            
        }
    }
}

#pragma mark Company Name By Id 
-(NSString *)getCompanyNameById:(int)companyID
{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    //NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Companies"];
    
    //Apply filter condition
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"companyId == %@",[NSNumber numberWithInt:companyID]]];
    
    //NSArray *tempArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSError *error = nil;
    NSArray *objectArr = [context executeFetchRequest:fetchRequest error:&error];
    Companies *objComp = [objectArr objectAtIndex:0];
    NSString *strCompName = objComp.companyName;
    return strCompName;
    
}


@end

