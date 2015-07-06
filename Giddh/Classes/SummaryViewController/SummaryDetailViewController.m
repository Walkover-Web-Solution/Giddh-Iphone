//
//  SummaryDetailViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 01/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "SummaryDetailViewController.h"
#import "AppDelegate.h"
#import "Entries.h"
#import "SummaryEntry.h"
#import "SummaryAccount.h"
#import "Accounts.h"
#import "EntriesInfoTrip.h"
#import "SummaryTableViewCell.h"
#import "MSCMoreOptionTableViewCell.h"
#import "MSCMoreOptionTableViewCellDelegate.h"
#import "EditEntryViewController.h"
#import "ServiceManager.h"
#import "YALContextMenuTableView.h"
#import "LedgerTypeViewController.h"
#import "YALContextMenuCell.h"
#import "LedgerEntryViewController.h"
static NSString *const menuCellIdentifier = @"rotationCell";

@interface SummaryDetailViewController ()<MSCMoreOptionTableViewCellDelegate,YALContextMenuTableViewDelegate,UIPopoverControllerDelegate>{
    NSArray *arrEntries;
    NSMutableArray *arrSummaryEntry;
    NSArray *arrAccounts;
    NSArray *arrEntriesInfoTrip;
    NSMutableArray *arrBackStack;
    NSMutableArray *arrBackStackName;
    BOOL isFirstTimeBack;
    NSString * viewtype;
    __weak IBOutlet UILabel *lblClosingBal;
    __weak IBOutlet UILabel *lblOpeningBal;
    __weak IBOutlet UIButton *btnAdd;
}
@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;
@property (nonatomic, strong) YALContextMenuTableView * contextMenuTableView;
- (IBAction)backButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)addLedgerEntryButtonAction:(id)sender;

@end

@implementation SummaryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    viewtype = self.type;
    isFirstTimeBack = NO;
    arrEntries = [NSArray array];
    arrEntriesInfoTrip = [NSArray array];
    arrBackStack = [NSMutableArray array];
    arrBackStackName= [NSMutableArray array];
    arrSummaryEntry = [NSMutableArray array];
    arrAccounts = [NSArray array];
    lblHeader.text = self.header;
    lblMessage.hidden = YES;
    [self getAccounts];
    [self getAllEntries];
    [self getAllEntriesInfoTrip];
    if([self.type isEqual:@"Income"]){
        [arrBackStackName addObject:@"Income"];
    }
    else if([self.type isEqual:@"Expense"]){
        [arrBackStackName addObject:@"Expense"];
    }
    else{
        [arrBackStackName addObject:self.accountName];
        [arrBackStack addObject:self.accountId];
    }
    isFirstTimeBack =YES;
    
    // Do any additional setup after loading the view.
}
-(void)getAllEntriesInfoTrip{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"EntriesInfoTrip" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrEntriesInfoTrip = [[context executeFetchRequest:request error:&error]mutableCopy];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    // [self.view removeFromSuperview];
    [self getAccounts];
    [self getAllEntries];
    [self getAllEntriesInfoTrip];
    [self sortAllDataForAccountId:self.accountId];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [self.view removeFromSuperview];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.view removeFromSuperview];
    
}
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return arrSummaryEntry.count;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SummaryEntry *summaryEntry = arrSummaryEntry[section];
    return summaryEntry.arrEntries.count;
}



- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"SummaryCell";
    MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MSCMoreOptionTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    SummaryEntry *summaryEntry = arrSummaryEntry[indexPath.section];
    NSArray *arrData = summaryEntry.arrEntries;
    SummaryAccount *summaryAccount  = arrData[indexPath.row];
    cell.textLabel.text = summaryAccount.name;
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@", [self formatToTwoDigitValueForNumber:summaryAccount.sum]];
    if([summaryAccount.transactionType isEqual:@"0"]){
        cell.detailTextLabel.textColor = [UIColor colorWithRed:9.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
    }
    else if([summaryAccount.transactionType isEqual:@"1"]){
        cell.detailTextLabel.textColor = [UIColor redColor];
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SummaryEntry *summaryEntry = arrSummaryEntry[indexPath.section];
    NSArray *arrData = summaryEntry.arrEntries;
    SummaryAccount *summaryAccount  = arrData[indexPath.row];
    lblHeader.text = summaryAccount.name;
    self.type = @"";
    if(arrBackStack.count<4){
        [arrBackStack addObject:summaryAccount.accountId];
        [arrBackStackName addObject:summaryAccount.name];
        [self sortAllDataForAccountId:summaryAccount.accountId];
        //NSLog(@"load for account id--%@",summaryAccount.accountId);
        isFirstTimeBack =YES;
    }
    else{
        [arrBackStack removeObjectAtIndex:0];
        [arrBackStack addObject:summaryAccount.accountId];
        [arrBackStackName addObject:summaryAccount.name];
        [self sortAllDataForAccountId:summaryAccount.accountId];
        //NSLog(@"load for account id--%@",summaryAccount.accountId);
        isFirstTimeBack = YES;
    }
    //NSLog(@"%@",arrBackStack);
    
    [self.tableView reloadData];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Called when 'delete' button is pushed.
        // NSLog(@"DELETE button pushed in row at: %@", indexPath.description);
        
        SummaryEntry *summaryEntry = arrSummaryEntry[indexPath.section];
        NSArray *arrData = summaryEntry.arrEntries;
        SummaryAccount *summaryAccount  = arrData[indexPath.row];
        //NSLog(@"%@",summaryAccount.objId);
        //NSLog(@"%@",summaryAccount.name);
        
        [self hitDeleteEntryApiForForManagedObjectId:summaryAccount.objId];
        [self sortAllDataForAccountId:self.accountId];
        // Hide 'more'- and 'delete'-confirmation view
        [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
            if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
                [cell hideDeleteConfirmation];
            }
        }];
    }
}
- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath {
    // Called when 'more' button is pushed.
    // NSLog(@"MORE button pushed in row at: %@", indexPath.description);
    SummaryEntry *summaryEntry = arrSummaryEntry[indexPath.section];
    NSArray *arrData = summaryEntry.arrEntries;
    SummaryAccount *summaryAccount  = arrData[indexPath.row];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
    EditEntryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EditEntryViewController"];
    vc.objId = summaryAccount.objId;
    vc.companies = self.companies;
    [self.navigationController pushViewController:vc animated:YES];
    // Hide 'more'- and 'delete'-confirmation view
    [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
        if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
            [cell hideDeleteConfirmation];
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Edit";
}

-(NSString*)formatToTwoDigitValueForNumber:(double)number{
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundCeiling];
    
    NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithDouble:number]];
    return numberString;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
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
-(void)sortAllDataForAccountId:(NSString*)accountId{
    if([accountId isEqual:nil]||self.accountId==nil)
        btnAdd.hidden = YES;
    if(accountId!=nil)
        btnAdd.hidden = NO;
    
    arrSummaryEntry = [NSMutableArray array];
    self.accountId = accountId;
    [self setOpeningAndClosingBalanceForAccountId:[NSNumber numberWithInt:[accountId intValue]]];
    for(NSString *date in [self fetchAllDates]){
        SummaryEntry *summaryEntry = [[SummaryEntry alloc]init];
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"SELF.date beginswith[c] %@ ",date ];
        NSArray *arrSameDateEntries = [arrEntries filteredArrayUsingPredicate:datePredicate].mutableCopy;
        // NSMutableArray *arrCreditEntries = [NSMutableArray array];
        //  NSMutableArray *arrEntries = [NSMutableArray array];
        NSMutableArray *arrEntry =[NSMutableArray array];
        
        for(Entries * entries in arrSameDateEntries){
            SummaryAccount *sumaryAccount =[[SummaryAccount alloc]init];
            sumaryAccount.sum = [entries.amount doubleValue];
            
            if([self.type isEqual:@"Income"]){
                lblHeader.text = @"Income";
                if([entries.transactionType isEqual:[NSNumber numberWithInt:0]]){
                    sumaryAccount.accountId = [entries.creditAccount stringValue];
                    sumaryAccount.emailIfLoan = entries.emailIfLoan;
                    sumaryAccount.name = [self getAccountNameForAccountId:entries.creditAccount];
                    sumaryAccount.transactionType = [entries.transactionType stringValue];
                    sumaryAccount.objId = [entries objectID];
                    [arrEntry addObject:sumaryAccount];
                }
                
            }
            else  if([self.type isEqual:@"Expense"]){
                lblHeader.text = @"Expense";
                if([entries.transactionType isEqual:[NSNumber numberWithInt:1]]){
                    sumaryAccount.accountId = [entries.debitAccount stringValue];
                    sumaryAccount.emailIfLoan = entries.emailIfLoan;
                    sumaryAccount.name = [self getAccountNameForAccountId:entries.debitAccount];
                    sumaryAccount.transactionType = [entries.transactionType stringValue];
                    sumaryAccount.objId = [entries objectID];
                    [arrEntry addObject:sumaryAccount];
                }
                
            }
            else{
                if([entries.creditAccount isEqual:[NSNumber numberWithInt:[accountId intValue]]]){
                    sumaryAccount.accountId = [entries.debitAccount stringValue];
                    sumaryAccount.emailIfLoan = entries.emailIfLoan;
                    sumaryAccount.name = [self getAccountNameForAccountId:entries.debitAccount];
                    sumaryAccount.objId = [entries objectID];
                    
                    sumaryAccount.transactionType = [entries.transactionType stringValue];
                    [arrEntry addObject:sumaryAccount];
                    //  NSLog(@"name-- %@ sum--%f",sumaryAccount.name,sumaryAccount.sum);
                    
                }
                else if ([entries.debitAccount isEqual:[NSNumber numberWithInt:[accountId intValue]]]){
                    sumaryAccount.accountId = [entries.creditAccount stringValue];
                    sumaryAccount.emailIfLoan = entries.emailIfLoan;
                    sumaryAccount.name = [self getAccountNameForAccountId:entries.creditAccount];
                    sumaryAccount.objId = [entries objectID];
                    
                    sumaryAccount.transactionType = [entries.transactionType stringValue];
                    [arrEntry addObject:sumaryAccount];
                    // NSLog(@"name-- %@ sum--%f",sumaryAccount.name,sumaryAccount.sum);
                }
            }
        }
        summaryEntry.arrEntries = arrEntry;
        summaryEntry.date = date;
        if(arrEntry.count!=0){
            [arrSummaryEntry addObject:summaryEntry];
        }
    }
    
    if (arrSummaryEntry.count == 0)
    {
        lblMessage.hidden = NO;
        self.tableView.hidden = YES;
    }
    else
    {
        [self.tableView reloadData];
        self.tableView.hidden = NO;
        lblMessage.hidden = YES;
    }
    
    [self.tableView reloadData];
}
-(void)setOpeningAndClosingBalanceForAccountId:(NSNumber*)accountId{
    for(Accounts *account in arrAccounts){
        if([account.accountId isEqual: accountId]){
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 33)];
            UILabel *lblOpenBal = [[UILabel alloc] initWithFrame:CGRectMake(8 , 6, 145, 21)];
            lblOpenBal.font = [UIFont systemFontOfSize:12.0f];
            
            lblOpeningBal.text=lblOpenBal.text =[NSString stringWithFormat:@"Opening Bal:%@",[self formatToTwoDigitValueForNumber:[account.openingBalance doubleValue]]];
            [headerView addSubview:lblOpenBal];
            UILabel *lblCloseBal = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-151, 6, 145, 21)];
            lblCloseBal.adjustsFontSizeToFitWidth=YES;
            lblOpenBal.adjustsFontSizeToFitWidth=YES;
            lblCloseBal.font = [UIFont systemFontOfSize:12.0f];
            lblCloseBal.textAlignment = NSTextAlignmentRight;
            double creditBal= 0;
            double debitBal= 0;
            double mainBal = 0;
            for(Entries *entries in arrEntries){
                if([entries.creditAccount isEqual:account.accountId]){
                    creditBal = creditBal + [entries.amount doubleValue];
                }
                if([entries.debitAccount isEqual:account.accountId]){
                    debitBal = debitBal + [entries.amount doubleValue];
                }
            }
            mainBal = debitBal - creditBal + [account.openingBalance doubleValue];
            lblClosingBal.text=lblCloseBal.text =[NSString stringWithFormat:@"Closing Bal:%@",[self formatToTwoDigitValueForNumber:mainBal]];
            
            [headerView addSubview:lblCloseBal];
            self.tableView.tableHeaderView = headerView;
            
            
        }
    }
}

-(NSString*)getAccountNameForAccountId:(NSNumber*)accountId{
    for(Accounts *account in arrAccounts){
        if([account.accountId isEqual: accountId]){
            return account.accountName;
        }
    }
    return @"";
}
-(Accounts*)getAccountForAccountId:(NSNumber*)accountId{
    for(Accounts *account in arrAccounts){
        if([account.accountId isEqual: accountId]){
            return account;
        }
    }
    return nil;
}


-(NSArray*)fetchAllDates{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    //create managed object context
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entries"];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Entries"
                                              inManagedObjectContext:context];
    NSAttributeDescription* clsName = [entity.attributesByName objectForKey:@"date"];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName: @"count"];
    [expressionDescription setExpressionResultType: NSInteger32AttributeType];
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:clsName, nil]];
    [fetch setPropertiesToGroupBy:[NSArray arrayWithObject:clsName]];
    [fetch setResultType:NSDictionaryResultType];
    NSError* error = nil;
    NSArray *results = [context executeFetchRequest:fetch  error:&error];
    NSMutableArray *arrDate = [NSMutableArray array];
    for(NSDictionary *date in results){
        [arrDate addObject:[date valueForKey:@"date"]];
    }
    [arrDate sortUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
        // return date2 compare date1 for descending. Or reverse the call for ascending.
        return [date2 compare:date1];
    }];
    return arrDate;
    
}
-(void)getAllEntries{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrEntries = [[context executeFetchRequest:request error:&error]mutableCopy];
}

-(void)getAccounts{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrAccounts=[[context executeFetchRequest:request error:&error]mutableCopy];
}

-(void)deleteEntryForManagedObjectId:(NSManagedObjectID*)objId{
    for(Entries * entries in arrEntries){
        if([entries.objectID isEqual:objId]){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            //create managed object context
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            NSError *error;
            [self deleteEntriesInfoTripObjectForEntryId:entries.entryId];
            [context deleteObject:entries];
            [context save:&error];
            [self sortAllDataForAccountId:self.accountId];
            
        }
    }
}

-(void)deleteEntriesInfoTripObjectForEntryId:(NSNumber*)entryId{
    for(EntriesInfoTrip *entriesInfoTrip in arrEntriesInfoTrip){
        if([entriesInfoTrip.entryId isEqual:entryId]){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            //create managed object context
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            NSError *error;
            
            [context deleteObject:entriesInfoTrip];
            [context save:&error];
            
        }
    }
}

-(void)hitDeleteEntryApiForForManagedObjectId:(NSManagedObjectID*)objId{
    for(Entries * entries in arrEntries){
        if([entries.objectID isEqual:objId]){
            // hit delete entry api with  entries.entryId
            MBProgressHUD * hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"Processing...";
            
            [[ServiceManager sharedManager]deleteEntrywithEntryId:[NSString stringWithFormat:@"%@",entries.entryId] withDeleteStatus:@"1" forAuthKey:@"" andCompanyName:self.companies.companyName withCompletionBlock:^(NSDictionary *responce, NSError *error) {
                // NSLog(@"%@",responce);
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSString *status  = [NSString stringWithFormat:@"%@",[responce valueForKey:@"status"]];
                if([status isEqual:@"1"]){
                    [self deleteEntryForManagedObjectId:objId];
                }
                else{
                    // add entry in delete entry table
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    //create managed object context
                    NSManagedObjectContext *context = [appDelegate managedObjectContext];
                    
                    NSManagedObject *newDeleteEntry;
                    newDeleteEntry = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"DeletedEntries"
                                      inManagedObjectContext:context];
                    for(Entries * entries in arrEntries){
                        if([entries.objectID isEqual:objId]){
                            NSError *error;
                            [newDeleteEntry setValue:entries.entryId forKeyPath:@"entryId"];
                            [self deleteEntryForManagedObjectId:objId];
                            [context insertObject:newDeleteEntry];
                            [context save:&error];
                        }
                    }
                    
                }
                
            }];
            
        }
    }
}

- (IBAction)backButtonAction:(id)sender {
    if(arrBackStack.count==0){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        if(isFirstTimeBack){
            [arrBackStack removeObjectAtIndex:arrBackStack.count-1];
            [arrBackStackName removeObjectAtIndex:arrBackStackName.count-1];
        }
        if(arrBackStack.count==0){
            if([viewtype isEqual:@"Income"]||[viewtype isEqual:@"Expense"]){
                self.type = viewtype;
                self.accountId = nil;
                [self sortAllDataForAccountId:self.accountId];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            
        }
        else{
            NSString *accountId = [arrBackStack objectAtIndex:arrBackStack.count-1];
            NSString *name  = [arrBackStackName objectAtIndex:arrBackStackName.count-1];
            lblHeader.text = name;
            [self sortAllDataForAccountId:accountId];
            [arrBackStack removeObjectAtIndex:arrBackStack.count-1];
            [arrBackStackName removeObjectAtIndex:arrBackStackName.count-1];
            [self.tableView reloadData];
        }
    }
    isFirstTimeBack =NO;
    
}

- (IBAction)addLedgerEntryButtonAction:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
    Accounts *account = [self getAccountForAccountId:[NSNumber numberWithInt:[self.accountId intValue]]];
    if([account.groupId intValue]>1){
        LedgerTypeViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LedgerTypeViewController"];
        vc.companies = self.companies;
        vc.accountId= self.accountId;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        navController.navigationBarHidden =YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        LedgerEntryViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"LedgerEntryViewController"];
        vc1.companies = self.companies;
        vc1.accountId= self.accountId;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc1];
        navController.navigationBarHidden =YES;
        [self.navigationController pushViewController:vc1 animated:YES];
    }
    
    
}
@end
