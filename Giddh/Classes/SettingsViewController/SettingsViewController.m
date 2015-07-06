//
//  SettingsViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 01/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "SettingsViewController.h"
#import "TripHomeVC.h"
#import "ServiceManager.h"
#import "AppDelegate.h"
#import "TripInfo.h"
#import "AppData.h"
#import "Accounts.h"
#import "Entries.h"
#import "CurrencyList.h"
#import "Accounts.h"
#import "BankAccountVC.h"
#import "CreditCardVC.h"
#import "AccountsViewController.h"
#import "Accounts.h"
#import "RNFrostedSidebar.h"
#import "Companies.h"
#import "TripHomeVC.h"
#import "SummaryViewController.h"
#import "BTSimpleSideMenu.h"
#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"
#import "UserHomeVC.h"
#import "PersonalHomeVC.h"
#import "DeletedEntries.h"
#import "AppHomeScreeVC.h"
static NSString *const menuCellIdentifier = @"rotationCell";
@interface SettingsViewController ()<RNFrostedSidebarDelegate,BTSimpleSideMenuDelegate,UITableViewDelegate,UIPickerViewDelegate,
UITableViewDataSource,YALContextMenuTableViewDelegate>{
    NSArray *arrDeletedEntries;
    
}
@property (nonatomic, strong) NSMutableIndexSet *optionIndices;
@property(nonatomic)BTSimpleSideMenu *sideMenu;
@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)backButtonAction:(id)sender;

@end

@implementation SettingsViewController
@synthesize globalCompanyId,globalCompanyName,globalCompanyEmail;

- (void)viewDidLoad {
    [super viewDidLoad];
    // sync companies
    [[AppData sharedData] syncCompanyList];
    // UIBarButtonItem * Item2= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTripButton)];
    UIBarButtonItem * Item1= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"burger.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonAction)];
    NSArray * buttonArray =[NSArray arrayWithObjects:Item1 ,nil];
    self.navigationItem.rightBarButtonItems =buttonArray;
    
    self.optionIndices = [NSMutableIndexSet indexSetWithIndex:1];
    _sideMenu.delegate = self;
    [self initiateMenuOptions];
    BTSimpleMenuItem *item1 = [[BTSimpleMenuItem alloc]initWithTitle:@"Trip"
                                                               image:[UIImage imageNamed:@"trip_icon.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            [_sideMenu toggleMenu];
                                                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
                                                            TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
                                                            vc.globalCompanyId = [self.companies.companyId intValue];
                                                            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
                                                            //navController.navigationBarHidden =YES;
                                                            vc.companies = self.companies;
                                                            
                                                            [self presentViewController:navController animated:YES completion:nil];
                                                            //NSLog(@"I am Item 1");
                                                        }];
    
    BTSimpleMenuItem *item2 = [[BTSimpleMenuItem alloc]initWithTitle:@"Settings"
                                                               image:[UIImage imageNamed:@"settings_icon.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            [_sideMenu toggleMenu];
                                                            
                                                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
                                                            SettingsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                                                            vc.globalCompanyId = [self.companies.companyId intValue];
                                                            vc.globalCompanyName = self.companies.companyName;
                                                            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
                                                            //navController.navigationBarHidden =YES;
                                                            [self presentViewController:navController animated:YES completion:nil];
                                                            
                                                            //NSLog(@"I am Item 2");
                                                        }];
    
    BTSimpleMenuItem *item3 = [[BTSimpleMenuItem alloc]initWithTitle:@"Summary"
                                                               image:[UIImage imageNamed:@"summary_icon.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            [_sideMenu toggleMenu];
                                                            
                                                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
                                                            SummaryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SummaryViewController"];
                                                            //vc.globalCompanyId = [self.companies.companyId intValue];
                                                            vc.companies =self.companies;
                                                            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
                                                            navController.navigationBarHidden =YES;
                                                            [self presentViewController:navController animated:YES completion:nil];
                                                            //NSLog(@"I am Item 3");
                                                        }];
    
    BTSimpleMenuItem *item4 = [[BTSimpleMenuItem alloc]initWithTitle:@"Company"
                                                               image:[UIImage imageNamed:@"company_icon.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            //NSLog(@"I am Item 4");
                                                            [_sideMenu toggleMenu];
                                                            
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                            
                                                        }];
    
    
    _sideMenu = [[BTSimpleSideMenu alloc]initWithItem:@[item1, item2, item3, item4, ]
                                  addToViewController:self];
    
    userDef = [NSUserDefaults standardUserDefaults];
    arrBankAcc = [NSMutableArray array];
    arrCreditCards = [NSMutableArray array];
    [self.tableView reloadData];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    btnSave.hidden = YES;
    
    //[self getCurrentDateTime];
    strDateTime = [userDef valueForKey:@"syncDateTime"];
    //text field
    txtUserName = [[UITextField alloc] init];
    lblEmail = [[UILabel alloc] init];
    // Do any additional setup after loading the view.
    arrDeletedEntries = [NSArray array];
    [self getDeletedEntries];
    //picker view
}
-(void)getDeletedEntries{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"DeletedEntries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrDeletedEntries=[[context executeFetchRequest:request error:&error]mutableCopy];
}
-(void)viewDidAppear:(BOOL)animated
{
}

-(void)viewWillAppear:(BOOL)animated{
    [self getAccountsCount];
    [self.tableView reloadData];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(int)getBankAccounts
{
    arrBankAcc = [NSMutableArray array];
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Accounts"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId == %@ AND accountName !=[c] %@", [NSNumber numberWithInt:3],@"Cash"]];
    NSError *error = nil;
    NSArray *objectArr = [context executeFetchRequest:fetchRequest error:&error];
    
    NSFetchRequest *fetchRequestCash = [[NSFetchRequest alloc] initWithEntityName:@"Accounts"];
    [fetchRequestCash setPredicate:[NSPredicate predicateWithFormat:@"groupId == %@", [NSNumber numberWithInt:3]]];
    NSError *errorCash = nil;
    NSArray *objectArrCash = [context executeFetchRequest:fetchRequestCash error:&errorCash];
    
    for (Accounts *objAcc in objectArrCash)
    {
        [arrBankAcc addObject:objAcc];
    }
    
    return objectArr.count;
    
}

-(int)getTripCount
{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"companyId == %@", [NSNumber numberWithInt:globalCompanyId]]];
    NSError *error = nil;
    NSArray *objectArr = [context executeFetchRequest:fetchRequest error:&error];
    return objectArr.count;
}

-(int) getCardCount
{
    arrCreditCards = [NSMutableArray array];
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Accounts"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId == %@ AND accountName != %@", [NSNumber numberWithInt:2],@"Loan"]];
    NSError *error = nil;
    NSArray *objectArr = [context executeFetchRequest:fetchRequest error:&error];
    for (Accounts *objAcc in objectArr)
    {
        [arrCreditCards addObject:objAcc];
    }
    return objectArr.count ;
}

#pragma mark UITableViewDelegate
/*
 - (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
 return 7;
 }
 
 -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return 60;
 }
 
 - (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 
 static NSString *cellIdentifier = @"PinLogsCell";
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
 //int count = self.arrTableData.count;
 
 if (!cell) {
 cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
 //cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
 //cell.contentView.backgroundColor = [UIColor clearColor];
 [cell setBackgroundColor:[UIColor clearColor]];
 }
 
 switch (indexPath.row)
 {
 case 0:
 {
 txtUserName.frame = CGRectMake(15, 8, 300, 22);
 txtUserName.delegate =self;
 //txtUserName.highlighted = YES;
 txtUserName.text = globalCompanyName;
 txtUserName.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
 [cell.contentView addSubview:txtUserName];
 
 lblEmail.frame = CGRectMake(15, 30, 300, 20);
 lblEmail.text = [userDef valueForKey:@"userEmail"];
 lblEmail.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
 [cell.contentView addSubview:lblEmail];
 break;
 }
 case 1:
 cell.textLabel.text = @"Bank Account";
 cell.detailTextLabel.text =  [NSString stringWithFormat:@"%d",[self getBankAccounts]];
 break;
 case 2:
 cell.textLabel.text = @"Associated Trip";
 cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[self getTripCount]];
 break;
 case 3:
 cell.textLabel.text = @"Credit card";
 cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[self getCardCount]];
 break;
 case 4:
 cell.textLabel.text = @"Sync";
 if ((strDateTime == (id)[NSNull null]) || (strDateTime.length == 0) || (strDateTime == nil))
 {
 strDateTime = @"Never";
 }
 cell.detailTextLabel.text = [NSString stringWithFormat:@"Last Updated : %@",strDateTime];
 break;
 case 5:
 {
 NSString *strCurrency = [userDef valueForKey:@"currencyName"];
 //cell.detailTextLabel.text = [userDef valueForKey:@"currencySymbol"];
 if ((strCurrency == (id)[NSNull null]) || (strCurrency.length == 0) || (strCurrency == nil))
 {
 cell.textLabel.text = @"Currency";
 cell.detailTextLabel.text = @"Select Currency";
 }
 else
 {
 cell.textLabel.text = [userDef valueForKey:@"currencySymbol"];
 cell.detailTextLabel.text = [userDef valueForKey:@"currencyName"];
 }
 break;
 }
 case 6:
 {
 cell.textLabel.text = @"Accounts";
 cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[self getAccountsCount]];
 }
 default:
 break;
 }
 //set font family
 cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
 cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
 return cell;
 }
 
 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (indexPath.row == 1)
 {
 selectedIndex = indexPath.row;
 [self performSegueWithIdentifier:@"bankIdentifier" sender:nil];
 
 }
 else if (indexPath.row == 2)
 {
 UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
 TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
 vc.globalCompanyId = globalCompanyId;
 UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
 [self presentViewController:navController animated:YES completion:nil];
 }
 else if (indexPath.row == 3)
 {
 selectedIndex = indexPath.row;
 [self performSegueWithIdentifier:@"creditIdentifier" sender:nil];
 }
 else if (indexPath.row == 4)
 {
 //sync trip,account,transaction
 //update sync datetime
 [self syncTripList];
 
 [self getCurrentDateTime];
 [self.tableView reloadData];
 }
 else if(indexPath.row == 5)
 {
 //[self showPickerView];
 [self performSegueWithIdentifier:@"currencyIdentifier" sender:nil];
 }
 else if(indexPath.row == 6)
 {
 //[self showPickerView];
 [self performSegueWithIdentifier:@"AccountsIdentifier" sender:nil];
 }
 
 }
 
 */
//sync trip list
-(void) syncTripList
{
    // MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // hud.labelText=@"Syncing..";
    [[ServiceManager sharedManager] syncTripForAuthKey:[userDef valueForKey:@"AuthKey"] andCompanyId:globalCompanyId withCompletionBlock:^(NSDictionary *responce, NSError *error)
     {
         // [MBProgressHUD hideHUDForView:self.view animated:YES];
         NSString *strStatus = [responce valueForKey:@"status"];
         int intStatus = [strStatus intValue];
         
         if (intStatus == 1)
         {
             //delete data from DB table
             
             NSArray *arrData = [responce valueForKey:@"data"];
             //NSLog(@"data arr -> %@",arrData);
             //NSMutableArray *arrTripDict = [arrData valueForKey:@"groupDetail"];
             //arrayGroup = [NSMutableArray array];
             //NSArray *arrayTrip = arrData[0];
             //get group details
             
             for (NSMutableDictionary *dictTrip in arrData)
             {
                 //NSLog(@"trip name -> %@",[dictTrip valueForKey:@"tripName"]);
                 //NSLog(@"trip id -> %@",[dictTrip valueForKey:@"tripId"]);
                 //NSLog(@"trip owner -> %@",[dictTrip valueForKey:@"owner"]);
                 
                 AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                 NSManagedObjectContext *contextTrip=[appDelegate managedObjectContext];
                 NSFetchRequest *fetchRequestTrip = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
                 //Apply filter condition
                 [fetchRequestTrip setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:[[dictTrip valueForKey:@"tripId"] intValue]]]];
                 
                 NSArray *tripArr = [[contextTrip executeFetchRequest:fetchRequestTrip error:nil] mutableCopy];
                 //NSManagedObject *tripObject = tripArr[0];
                 // add a new company
                 if(tripArr.count == 0)
                 {
                     NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"TripInfo" inManagedObjectContext:contextTrip];
                     
                     [newDevice setValue:[NSNumber numberWithInt:[[dictTrip valueForKey:@"tripId"] intValue]] forKey:@"tripId"];
                     [newDevice setValue:[dictTrip valueForKey:@"tripName"] forKey:@"tripName"];
                     [newDevice setValue:[NSNumber numberWithInt:[[dictTrip valueForKey:@"owner"] intValue]] forKey:@"owner"];
                     [newDevice setValue:[NSNumber numberWithInt:globalCompanyId] forKey:@"companyId"];
                     //[context insertObject:newDevice];
                 }
                 else
                 {
                     //Update trip list
                     //NSManagedObject *tripObject = tripArr[0];
                     //[tripObject];
                     TripInfo *tripObject = tripArr[0];
                     //Companies *company = [arrData objectAtIndex:0];
                     tripObject.tripName = [dictTrip valueForKey:@"tripName"];
                     tripObject.tripId = [NSNumber numberWithInt:[[dictTrip valueForKey:@"tripId"] intValue]];
                     tripObject.owner = [NSNumber numberWithInt:[[dictTrip valueForKey:@"owner"] intValue]];
                     tripObject.companyId = [NSNumber numberWithInt:globalCompanyId];
                 }
                 [contextTrip save:&error];
             }
         }
         else
         {
             NSLog(@"Error while syncing trip");
         }
     }];
    [self syncAccounts];
}

//sync accounts
-(void)syncAccounts{
    if( [[AppData sharedData]isInternetAvailable]){
        [[ServiceManager sharedManager]getAccountListForAuthKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"authKey"] companyName:globalCompanyName companyid:[NSString stringWithFormat:@"%d",globalCompanyId] andMobile:@"1" withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            // NSLog(@"%@",responce);
            NSArray *data = [responce valueForKey:@"data"];
            NSDictionary *grpDetails = [data objectAtIndex:0];
            NSArray *arrGrpDetails = [grpDetails valueForKey:@"groupDetail"];
            AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
            for(NSDictionary *dictionary in arrGrpDetails){
                // NSLog(@"%@",dictionary);
                NSString * grpName = [dictionary valueForKey:@"groupName"];
                NSNumber * grpId;
                if([[grpName lowercaseString] isEqual:@"income"]){
                    grpId = [NSNumber numberWithInt:0];
                }
                else if ([[grpName lowercaseString] isEqual:@"expense"]){
                    grpId = [NSNumber numberWithInt:1];
                }
                else if ([[grpName lowercaseString] isEqual:@"liability"]){
                    grpId = [NSNumber numberWithInt:2];
                }
                else if ([[grpName lowercaseString] isEqual:@"assets"]){
                    grpId = [NSNumber numberWithInt:3];
                }
                
                
                NSArray * arrAccountDetails = [dictionary valueForKey:@"accountDetails"];
                for(NSDictionary *dictAccounts in arrAccountDetails){
                    NSManagedObjectContext *context=[appDelegate managedObjectContext];
                    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                    NSFetchRequest *request=[[NSFetchRequest alloc]init];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@ AND groupId contains[cd] %@", [dictAccounts valueForKey:@"accountName"],grpId];
                    [request setPredicate:predicate];
                    [request setEntity:entityDescr];
                    NSError *error;
                    NSArray * arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                    if(arrData.count==0){
                        // add a new account
                        [self refreshAccounts];
                        // create a new account with max account id
                        NSMutableArray *arrAccountId = [NSMutableArray array];
                        for(Accounts *accounts in arrAccounts){
                            [arrAccountId addObject:accounts.accountId];
                        }
                        int max = [[arrAccountId valueForKeyPath:@"@max.intValue"] intValue];
                        max++;
                        NSManagedObject *newAccount;
                        newAccount = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Accounts"
                                      inManagedObjectContext:context];
                        NSNumber *accountId = [NSNumber numberWithInt:max];
                        [newAccount setValue:[dictAccounts valueForKey:@"accountName"] forKeyPath:@"accountName"];
                        [newAccount setValue:globalCompanyEmail forKeyPath:@"emailId"];
                        [newAccount setValue:grpId forKeyPath:@"groupId"];
                        [newAccount setValue:[NSNumber numberWithDouble:[[dictAccounts valueForKey:@"openingBalance"] doubleValue]] forKeyPath:@"openingBalance"];
                        [newAccount setValue:[dictAccounts valueForKey:@"uniqueName"] forKeyPath:@"uniqueName"];
                        [newAccount setValue:accountId forKeyPath:@"accountId"];
                        //  NSLog(@"newAccount %@",newAccount);
                        [context insertObject:newAccount];
                        [context save:&error];
                        
                    }
                    else{
                        //update existin account
                        Accounts *account = arrData[0];
                        account.openingBalance =[NSNumber numberWithDouble:[[dictAccounts valueForKey:@"openingBalance"] doubleValue]];
                        [context save:&error];
                    }
                }
            }
            
            
        }];
        [self syncEntryInfo];
    }
    
    
}

//sync transactions
-(void)syncEntryInfo{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self refreshAccounts];
    if( [[AppData sharedData]isInternetAvailable]){
        NSManagedObjectContext *context=[appDelegate managedObjectContext];
        NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
        NSFetchRequest *request=[[NSFetchRequest alloc]init];
        [request setEntity:entityDescr];
        NSError *error;
        NSArray *arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
        NSMutableArray *arrEntryId = [NSMutableArray array];
        for(Entries *entries in arrData){
            [arrEntryId addObject:entries.entryId];
        }
        int max = [[arrEntryId valueForKeyPath:@"@max.intValue"] intValue];
        //NSLog(@"%d",max);
        [[ServiceManager sharedManager]getEntrySummaryForAuthKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"authKey"] companyid:[NSString stringWithFormat:@"%d",globalCompanyId] andEntryId:[NSString stringWithFormat:@"%d",max ] withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            //NSLog(@"%@",responce);
            NSArray * arrData = [responce valueForKey:@"data"];
            NSNumber * creditGrpId;
            NSNumber * transactionType;
            NSNumber *creditAccountId;
            NSNumber *debitAccountId;
            NSString *amount ;
            for(NSDictionary *dict in arrData){
                NSArray * arrCredit = [dict valueForKey:@"credit"];
                NSArray * arrDebit = [dict valueForKey:@"debit"];
                // NSDictionary * creditDict = arrCredit[0];
                for(NSDictionary * creditDict in arrCredit){
                    
                    
                    NSString *creditGrpName = [creditDict valueForKey:@"groupName"];
                    NSString *creditAccountName = [creditDict valueForKey:@"accountName"];
                    amount = [creditDict valueForKey:@"amount"];
                    
                    // get first credit and debit groupname
                    NSDictionary * debitAt0 = arrDebit[0];
                    NSString * debit0GrpName = [debitAt0 valueForKey:@"groupName"];
                    NSDictionary * creditAt0 = arrCredit[0];
                    NSString * credit0GrpName = [creditAt0 valueForKey:@"groupName"];
                    
                    
                    //set transaction type
                    if([[debit0GrpName lowercaseString] isEqual:@"income"]||[[credit0GrpName lowercaseString] isEqual:@"income"] || [[credit0GrpName lowercaseString] isEqual:@"liability"]){
                        transactionType = [NSNumber numberWithInt:0];
                    }
                    else if([[debit0GrpName lowercaseString] isEqual:@"expense"]||[[credit0GrpName lowercaseString] isEqual:@"expense"] || [[debit0GrpName lowercaseString] isEqual:@"liability"]){
                        transactionType = [NSNumber numberWithInt:1];
                    }
                    else if([[debit0GrpName lowercaseString] isEqual:@"assets"]&&[[credit0GrpName lowercaseString] isEqual:@"assets"] ){
                        transactionType = [NSNumber numberWithInt:0];
                    }
                    // set Group id
                    if([[creditGrpName lowercaseString] isEqual:@"income"]){
                        creditGrpId = [NSNumber numberWithInt:0];
                    }
                    else if ([[creditGrpName lowercaseString] isEqual:@"expense"]){
                        creditGrpId = [NSNumber numberWithInt:1];
                    }
                    else if ([[creditGrpName lowercaseString] isEqual:@"liability"]){
                        creditGrpId = [NSNumber numberWithInt:2];
                    }
                    else if ([[creditGrpName lowercaseString] isEqual:@"assets"]){
                        creditGrpId = [NSNumber numberWithInt:3];
                    }
                    // check for accounts with same grp id and account name.
                    NSManagedObjectContext *context=[appDelegate managedObjectContext];
                    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                    NSFetchRequest *request=[[NSFetchRequest alloc]init];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@ AND groupId contains[cd] %@", creditAccountName,creditGrpId];
                    [request setPredicate:predicate];
                    [request setEntity:entityDescr];
                    NSError *error;
                    arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                    if(arrData.count==0){
                        [self refreshAccounts];
                        // create a new account with max account id
                        NSMutableArray *arrAccountId = [NSMutableArray array];
                        for(Accounts *accounts in arrAccounts){
                            [arrAccountId addObject:accounts.accountId];
                        }
                        int max = [[arrAccountId valueForKeyPath:@"@max.intValue"] intValue];
                        max++;
                        NSManagedObject *newAccount;
                        newAccount = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Accounts"
                                      inManagedObjectContext:context];
                        NSString *openingBalanceNum = @"0";
                        NSNumber *openingBalance = [NSNumber numberWithInt:[openingBalanceNum floatValue]];
                        NSNumber *accountId = [NSNumber numberWithInt:max];
                        
                        [newAccount setValue:creditAccountName forKeyPath:@"accountName"];
                        [newAccount setValue:globalCompanyEmail forKeyPath:@"emailId"];
                        [newAccount setValue:creditGrpId forKeyPath:@"groupId"];
                        [newAccount setValue:openingBalance forKeyPath:@"openingBalance"];
                        [newAccount setValue:@"" forKeyPath:@"uniqueName"];
                        [newAccount setValue:accountId forKeyPath:@"accountId"];
                        // NSLog(@"newAccount %@",newAccount);
                        [context insertObject:newAccount];
                        [context save:&error];
                        creditAccountId = accountId;
                        [self refreshAccounts];
                    }
                    else{
                        Accounts *accountsCre = arrData[0];
                        creditAccountId = accountsCre.accountId;
                    }
                    
                }
                // check for debit accounts with same grp id and account name.
                for(NSDictionary * debitDict in arrDebit){
                    
                    NSString *debitGrpName = [debitDict valueForKey:@"groupName"];
                    NSString *debitAccountName = [debitDict valueForKey:@"accountName"];
                    NSNumber * debitGrpId;
                    if([[debitGrpName lowercaseString] isEqual:@"income"]){
                        debitGrpId = [NSNumber numberWithInt:0];
                    }
                    else if ([[debitGrpName lowercaseString] isEqual:@"expense"]){
                        debitGrpId = [NSNumber numberWithInt:1];
                    }
                    else if ([[debitGrpName lowercaseString] isEqual:@"liability"]){
                        debitGrpId = [NSNumber numberWithInt:2];
                    }
                    else if ([[debitGrpName lowercaseString] isEqual:@"assets"]){
                        debitGrpId = [NSNumber numberWithInt:3];
                    }
                    
                    
                    [self refreshAccounts];
                    NSManagedObjectContext *context=[appDelegate managedObjectContext];
                    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                    NSFetchRequest *request=[[NSFetchRequest alloc]init];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@ AND groupId contains[cd] %@", debitAccountName,debitGrpId];
                    [request setPredicate:predicate];
                    [request setEntity:entityDescr];
                    NSError *error;
                    arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                    
                    if(arrData.count==0){
                        [self refreshAccounts];
                        
                        // create a new account with max account id
                        NSMutableArray *arrAccountId = [NSMutableArray array];
                        for(Accounts *accounts in arrAccounts){
                            [arrAccountId addObject:accounts.accountId];
                        }
                        int max = [[arrAccountId valueForKeyPath:@"@max.intValue"] intValue];
                        max++;
                        NSManagedObject *newAccount;
                        newAccount = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Accounts"
                                      inManagedObjectContext:context];
                        NSString *openingBalanceNum = @"0";
                        NSNumber *openingBalance = [NSNumber numberWithInt:[openingBalanceNum floatValue]];
                        NSNumber *accountId = [NSNumber numberWithInt:max];
                        
                        [newAccount setValue:debitAccountName forKeyPath:@"accountName"];
                        [newAccount setValue:globalCompanyEmail forKeyPath:@"emailId"];
                        [newAccount setValue:debitGrpId forKeyPath:@"groupId"];
                        [newAccount setValue:openingBalance forKeyPath:@"openingBalance"];
                        [newAccount setValue:@"" forKeyPath:@"uniqueName"];
                        [newAccount setValue:accountId forKeyPath:@"accountId"];
                        [context insertObject:newAccount];
                        [context save:&error];
                        debitAccountId = accountId;
                        [self refreshAccounts];
                    }
                    else{
                        Accounts *accountsDeb = arrData[0];
                        debitAccountId = accountsDeb.accountId;
                    }
                    
                }
                NSString * strDate = [dict valueForKey:@"entryDate"];
                NSArray * arr = [strDate componentsSeparatedByString:@" "];
                
                NSManagedObjectContext *context=[appDelegate managedObjectContext];
                NSError *error = nil;
                NSManagedObject *newEntry;
                newEntry = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Entries"
                            inManagedObjectContext:context];
                NSString *entryId = [dict valueForKey:@"entryId"];
                [newEntry setValue:transactionType forKey:@"transactionType"];
                [newEntry setValue:[arr objectAtIndex:0] forKey:@"date"];
                [newEntry setValue:[NSNumber numberWithInt:[amount intValue]] forKey:@"amount"];
                [newEntry setValue:debitAccountId forKey:@"debitAccount"];
                [newEntry setValue:creditAccountId forKey:@"creditAccount"];
                [newEntry setValue:globalCompanyEmail forKey:@"companyId"];
                [newEntry setValue:[NSNumber numberWithInt:[amount intValue]] forKey:@"amount"];
                [newEntry setValue:[NSNumber numberWithInt:[entryId intValue]] forKey:@"entryId"];
                [context insertObject:newEntry];
                [context save:&error];
            }
            // [self getAllEtries];
            [self deleteLocallyDeletedEntriesFromServer];
        }];
    }
}

-(void)deleteLocallyDeletedEntriesFromServer{
    for(DeletedEntries *deletedEntry in arrDeletedEntries){
        [[ServiceManager sharedManager]deleteEntrywithEntryId:[NSString stringWithFormat:@"%@",deletedEntry.entryId] withDeleteStatus:@"1" forAuthKey:@"" andCompanyName:self.companies.companyName withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            // NSLog(@"%@",responce);
            AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
            NSManagedObjectContext *context=[appDelegate managedObjectContext];
            [context deleteObject:deletedEntry];
            [context save:&error];
        }];
    }
    
}

-(void)refreshAccounts{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrAccounts=[[context executeFetchRequest:request error:&error]mutableCopy];
    
    
}

-(void) getCurrentDateTime
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"dd-MMM-yyyy HH:mm:ss"];
    strDateTime = [DateFormatter stringFromDate:[NSDate date]];
    [userDef setValue:strDateTime forKey:@"syncDateTime"];
    //  NSLog(@"%@",[DateFormatter stringFromDate:[NSDate date]]);
}


//picker view methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/*
 -(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
 {
 return [arrCurrency count];
 }
 
 - (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
 UILabel* tView = (UILabel*)view;
 if (!tView){
 tView = [[UILabel alloc] init];
 // Setup label properties - frame, font, colors etc
 //tView.frame = CGRectMake(tView.frame.origin.x + 15, tView.frame.origin.y, tView.frame.size.width, tView.frame.size.height);
 tView.font = [UIFont systemFontOfSize:15];
 tView.textAlignment = NSTextAlignmentJustified;
 tView.adjustsFontSizeToFitWidth = YES;
 }
 // Fill the label text here
 CurrencyList *objList = arrCurrency[row];
 NSString *strCurrency = [NSString stringWithFormat:@"%@ (%@)",objList.currencyName,objList.currencySymbol];
 tView.text = strCurrency;
 return tView;
 }
 */

-(void) showPickerView
{
    /*
     NSString *currencyCode = @"INR";
     NSLocale *locale1 = [[NSLocale alloc] initWithLocaleIdentifier:currencyCode];
     NSString *currencySymbol = [NSString stringWithFormat:@"%@",[locale1 displayNameForKey:NSLocaleCurrencySymbol value:currencyCode]];
     NSLog(@"Currency Symbol new : %@", currencySymbol);
     */
    //show date picker
    picView=[[UIPickerView alloc] initWithFrame:CGRectZero];
    CGRect bounds = [self.view bounds];
    int datePickerHeight = picView.frame.size.height;
    picView.frame = CGRectMake(0, bounds.size.height - (datePickerHeight), picView.frame.size.width, picView.frame.size.height);
    picView.dataSource = self;
    picView.delegate = self;
    [picView setBackgroundColor:[UIColor whiteColor]];
    //picView.datePickerMode = UIDatePickerModeDate;
    //set minimum date
    //NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //NSDate *currentDate = [NSDate date];
    //NSDateComponents *comps = [[NSDateComponents alloc] init];
    //[comps setMinute:+1];
    //NSDate *minDate = [gregorian dateByAddingComponents:comps toDate:currentDate  options:0];
    //[picView setMinimumDate:minDate];
    //[picView setMaximumDate:minDate];
    //[picView setMinimumDate:[NSDate date]];
    
    [self.view addSubview:picView];
    
    //picker view header
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, picView.frame.size.width, 40)];
    [headerView setBackgroundColor:[UIColor colorWithRed:230/255.0f green:103/255.0f blue:61/255.0f alpha:1]];
    //[headerView setBackgroundColor:[UIColor lightGrayColor ]];
    [picView addSubview:headerView];
    
    btnCancel=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [btnCancel setFrame:CGRectMake(5, bounds.size.height - (datePickerHeight), 100, 36)];
    btnCancel.tag=0;
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];
    
    
    btnDone=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone setFrame:CGRectMake(self.view.frame.size.width-2-100, bounds.size.height - (datePickerHeight), 100, 36)];
    btnDone.tag=1;
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDone];
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
}

- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    //[textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    UIBarButtonItem * Item2= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkIcon01"] style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    UIBarButtonItem * Item1= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"burger.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonAction)];
    NSArray * buttonArray =[NSArray arrayWithObjects:Item1 ,Item2,nil];
    self.navigationItem.rightBarButtonItems =buttonArray;
    
    btnSave.hidden = NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    // UIBarButtonItem * Item2= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTripButton)];
    UIBarButtonItem * Item1= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"burger.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonAction)];
    NSArray * buttonArray =[NSArray arrayWithObjects:Item1 ,nil];
    self.navigationItem.rightBarButtonItems =buttonArray;
    
    btnSave.hidden = YES;
}

- (IBAction)saveAction
{
    if ([[AppData sharedData] isInternetAvailable])
    {
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText=@"Processing..";
        //hit API : updateCompanyName
        [[ServiceManager sharedManager] updateCompanyNameForAuthKey:[userDef valueForKey:@"AuthKey"] prevCompanyName:globalCompanyName andNewCompanyName:txtUserName.text withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *strStatus = [responce valueForKey:@"status"];
            int intStatus = [strStatus intValue];
            
            if (intStatus == 1)
            {
                [userDef setValue:txtUserName.text forKey:@"userName"];
                
                //update local DB
                //update trip info table
                AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                NSManagedObjectContext *context =[appDelegate managedObjectContext];
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Companies"];
                
                //Apply filter condition
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"companyId == %@", [NSNumber numberWithInt:globalCompanyId]]];
                
                NSArray *objectArr = [context executeFetchRequest:fetchRequest error:&error];
                NSManagedObject *tempObject = [objectArr objectAtIndex:0];
                
                [tempObject setValue:txtUserName.text forKey:@"companyName"];
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    // NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
            else
            {
                // NSLog(@"Error message = %@",[responce valueForKey:@"message"]);
            }
        }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Internet not Available" message:@"Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil] show];
    }
}

#pragma mark Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqual:@"bankIdentifier"] )
    {
        BankAccountVC *vc = [segue destinationViewController];
        vc.arrAccounts = arrBankAcc;
        vc.globalCompanyId = globalCompanyId;
        vc.globalCompanyName = globalCompanyName;
        vc.companies = self.companies;
    }
    else if ([[segue identifier] isEqual:@"creditIdentifier"] )
    {
        CreditCardVC *vc = [segue destinationViewController];
        vc.arrAccounts = arrCreditCards;
        vc.globalCompanyId = globalCompanyId;
        vc.globalCompanyName = globalCompanyName;
    }
    else if ([[segue identifier] isEqual:@"AccountsIdentifier"] )
    {
        AccountsViewController *vc = [segue destinationViewController];
        //NSLog(@"%@",self.companies.companyName);
        vc.companies = self.companies;
    }
}
-(NSInteger)getAccountsCount{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *temp=[[context executeFetchRequest:request error:&error]mutableCopy];
    NSMutableArray *arrAcc =[NSMutableArray array];
    for(Accounts *accounts in temp){
        int accountId =17;
        NSString * storedAccountId = [NSString stringWithFormat:@"%@",accounts.accountId];
        if([storedAccountId intValue]>accountId){
            [arrAcc addObject:accounts];
        }
    }
    return arrAcc.count;
    
}


- (IBAction)menuButtonAction {
    //    NSArray *images = @[
    //                        [UIImage imageNamed:@"trip_icon"],
    //                        [UIImage imageNamed:@"summary_icon"],
    //                        [UIImage imageNamed:@"company_icon"],
    //                        ];
    //    NSArray *colors = @[
    //                        [UIColor colorWithRed:253/255.f green:125/255.f blue:89/255.f alpha:1],
    //                        [UIColor colorWithRed:255/255.f green:137/255.f blue:167/255.f alpha:1],
    //                        [UIColor colorWithRed:126/255.f green:242/255.f blue:195/255.f alpha:1],
    //                        ];
    //    RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images selectedIndices:self.optionIndices borderColors:nil andBackColor:colors];
    //
    //    //RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images];
    //    callout.delegate = self;
    //    // callout.tintColor = [UIColor colorWithRed:162/255.f green:151/255.f blue:144/255.f alpha:.6];
    //    callout.tintColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:.3 ];
    //
    //    callout.itemBackgroundColor =[UIColor whiteColor];
    //    //callout.showFromRight = YES;
    //    [callout show];
    //    [_sideMenu toggleMenu];
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.05;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    [self.contextMenuTableView showInView:self.navigationController.view withEdgeInsets:UIEdgeInsetsZero animated:YES];
    
}
#pragma mark - RNFrostedSidebarDelegate
- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    UIViewController *presentingVC = [self presentingViewController];
    //NSLog(@"Tapped item at index %lu",(unsigned long)index);
    if (index == 0) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
        TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
        vc.globalCompanyId = [self.companies.companyId intValue];
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        [self dismissViewControllerAnimated:NO completion:
         ^{
             [presentingVC presentViewController:navController animated:YES completion:nil];
         }];
        //
        //            }];
        
        [sidebar dismissAnimated:YES completion:nil];
    }
    if (index == 1) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
        SummaryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SummaryViewController"];
        vc.companies =self.companies;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        navController.navigationBarHidden =YES;
        [self dismissViewControllerAnimated:NO completion:
         ^{
             [presentingVC presentViewController:navController animated:YES completion:nil];
         }];
        
        [sidebar dismissAnimated:YES completion:nil];
    }
    if (index == 2) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}
#pragma mark - initiateMenuOptions

- (void)initiateMenuOptions {
    self.menuTitles = @[@"",
                        @"Trip",
                        @"Summary",
                        @"Transaction",
                        @"Company",
                        ];
    
    self.menuIcons = @[[UIImage imageNamed:@"icn_close"],
                       [UIImage imageNamed:@"trip_icon1"],
                       [UIImage imageNamed:@"summary_icon1"],
                       [UIImage imageNamed:@"icon_Transaction"],
                       [UIImage imageNamed:@"company_icon1"],
                       ];
    
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.tableView]){
        if (indexPath.row == 1)
        {
            selectedIndex = (int)indexPath.row;
            [self performSegueWithIdentifier:@"bankIdentifier" sender:nil];
        }
        else if (indexPath.row == 2)
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
            TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
            vc.globalCompanyId = globalCompanyId;
            vc.companies = self.companies;
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:navController animated:YES completion:nil];
        }
        else if (indexPath.row == 3)
        {
            selectedIndex = (int)indexPath.row;
            [self performSegueWithIdentifier:@"creditIdentifier" sender:nil];
        }
        else if (indexPath.row == 4)
        {
            //sync trip,account,transaction
            //update sync datetime
            [self syncTripList];
            [self getCurrentDateTime];
            [self.tableView reloadData];
        }
        //        else if(indexPath.row == 5)
        //        {
        //            //[self showPickerView];
        //            [self performSegueWithIdentifier:@"currencyIdentifier" sender:nil];
        //        }
        else if(indexPath.row == 5)
        {
            //[self showPickerView];
            [self performSegueWithIdentifier:@"AccountsIdentifier" sender:nil];
        }
        else if(indexPath.row == 6)
        {
            [[[UIAlertView alloc] initWithTitle:@"Are you sure to logout?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil] show];

            //[self showPickerView];
            
            //  [self presentViewController:navController animated:YES completion:nil];
        }
        
    }
    else{
        UIViewController *presentingVC = [self presentingViewController];
        //NSLog(@"Tapped item at index %lu",(unsigned long)index);
        if (indexPath.row == 1) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
            TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
            vc.globalCompanyId = [self.companies.companyId intValue];
            vc.companies = self.companies;
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            [self dismissViewControllerAnimated:NO completion:
             ^{
                 [presentingVC presentViewController:navController animated:YES completion:nil];
                 
             }];
            //
            //            }];
            
        }
        if (indexPath.row == 2) {
            NSString *pagetype = [[NSUserDefaults standardUserDefaults]valueForKey:@"firstPageType"];
            
            if([pagetype isEqual:@"summary"]){
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else{
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
                SummaryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SummaryViewController"];
                vc.companies =self.companies;
                UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
                navController.navigationBarHidden =YES;
                [self dismissViewControllerAnimated:NO completion:
                 ^{
                     [presentingVC presentViewController:navController animated:YES completion:nil];
                 }];
            }
            
        }
        
        if (indexPath.row == 3) {
            //[self dismissViewControllerAnimated:YES completion:nil];UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
            PersonalHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"PersonalHomeVC"];
            vc.companies =self.companies;
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            navController.navigationBarHidden =YES;
            NSString *pagetype = [[NSUserDefaults standardUserDefaults]valueForKey:@"firstPageType"];
            if([pagetype isEqual:@"transaction"]){
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else if(![pagetype isEqual:@"summary"]){
                [self presentViewController:navController animated:YES completion:nil];
            }
            else{
                [self dismissViewControllerAnimated:NO completion:
                 ^{
                     [presentingVC presentViewController:navController animated:YES completion:nil];
                 }];
            }
            
        }
        if(indexPath.row == 4){
            //            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            //            UserHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"UserHomeVC"];
            //            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            //            navController.navigationBarHidden =NO;
            //            [self presentViewController:navController animated:YES completion:NULL];
            [self dismissViewControllerAnimated:NO completion:
             ^{
                 [presentingVC dismissViewControllerAnimated:YES completion:nil];
             }];
        }
        
        [tableView dismisWithIndexPath:indexPath];
    }
    
}

-(void) confirmLogout
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogOut"];

    userDef = [NSUserDefaults standardUserDefaults];
    [self emptyCompanyList];
    [self emptyTripList];
    [self emptyAccountList];
    [self emptyEntriesList];
    [self emptyEntriesInfoTripList];
    [self emptyTripShareList];
    [self emptyGroupList];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    [userDef removeObjectForKey:@"accountFirstTime"];
    // Clear the cookies.
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:
                                [NSURL URLWithString:@"http://login.facebook.com"]];
    for (NSHTTPCookie* cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppHomeScreeVC *vc = [sb instantiateViewControllerWithIdentifier:@"AppHomeScreeVC"];
    vc.logoutFlag = true;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
    UIViewController *presentingVC = [self presentingViewController];
    
    [self dismissViewControllerAnimated:NO completion:
     ^{
         [presentingVC presentViewController:navController animated:YES completion:nil];
     }];
}
#pragma mark AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self performSelector:@selector(confirmLogout) withObject:nil afterDelay:.5];

       // [self confirmLogout];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableView isEqual:self.tableView]){
        return 7;
        
    }
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Companies"];
    NSArray *arrCompanies = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if(arrCompanies.count==1){
        return self.menuTitles.count-1;
        
    }
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.tableView]){
        static NSString *cellIdentifier = @"PinLogsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        //int count = self.arrTableData.count;
        
        if (!cell) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            //cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            //cell.contentView.backgroundColor = [UIColor clearColor];
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        
        switch (indexPath.row)
        {
            case 0:
            {
                txtUserName.frame = CGRectMake(15, 8, 300, 22);
                txtUserName.delegate =self;
                //txtUserName.highlighted = YES;
                txtUserName.text = globalCompanyName;
                txtUserName.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
                [cell.contentView addSubview:txtUserName];
                
                lblEmail.frame = CGRectMake(15, 30, 300, 20);
                lblEmail.text = [userDef valueForKey:@"userEmail"];
                lblEmail.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
                [cell.contentView addSubview:lblEmail];
                break;
            }
            case 1:
                cell.textLabel.text = @"Bank Account";
                cell.detailTextLabel.text =  [NSString stringWithFormat:@"%d",[self getBankAccounts]];
                break;
            case 2:
                cell.textLabel.text = @"Associated Trip";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[self getTripCount]];
                break;
            case 3:
                cell.textLabel.text = @"Credit card";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[self getCardCount]];
                break;
            case 4:
                cell.textLabel.text = @"Sync";
                if ((strDateTime == (id)[NSNull null]) || (strDateTime.length == 0) || (strDateTime == nil))
                {
                    strDateTime = @"Never";
                }
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Last Updated : %@",strDateTime];
                cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
                
                break;
                //            case 5:
                //            {
                //                NSString *strCurrency = [userDef valueForKey:@"currencyName"];
                //                //cell.detailTextLabel.text = [userDef valueForKey:@"currencySymbol"];
                //                if ((strCurrency == (id)[NSNull null]) || (strCurrency.length == 0) || (strCurrency == nil))
                //                {
                //                    cell.textLabel.text = @"Currency";
                //                    cell.detailTextLabel.text = @"Select Currency";
                //                }
                //                else
                //                {
                //                    cell.textLabel.text = [userDef valueForKey:@"currencySymbol"];
                //                    cell.detailTextLabel.text = [userDef valueForKey:@"currencyName"];
                //                }
                //                break;
                //            }
            case 5:
            {
                cell.textLabel.text = @"Accounts";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)[self getAccountsCount]];
                cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
                break;
                
            }
            case 6:
            {
                cell.textLabel.text = @"Logout";
                break;
                //  cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[self getAccountsCount]];
            }
                
            default:
                break;
        }
        //set font family
        cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
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
-(void)emptyCompanyList{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSFetchRequest * allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"Companies" inManagedObjectContext:context]];
    [allContacts setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * companies = [context executeFetchRequest:allContacts error:&error];
    for (NSManagedObject * company in companies) {
        [context deleteObject:company];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    
}

-(void)emptyTripList{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSFetchRequest * allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"TripInfo" inManagedObjectContext:context]];
    [allContacts setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * companies = [context executeFetchRequest:allContacts error:&error];
    for (NSManagedObject * company in companies) {
        [context deleteObject:company];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    
}

-(void)emptyAccountList{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSFetchRequest * allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context]];
    [allContacts setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * companies = [context executeFetchRequest:allContacts error:&error];
    for (NSManagedObject * company in companies) {
        [context deleteObject:company];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    
}

-(void)emptyEntriesList{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSFetchRequest * allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context]];
    [allContacts setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * companies = [context executeFetchRequest:allContacts error:&error];
    for (NSManagedObject * company in companies) {
        [context deleteObject:company];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    
}

-(void)emptyEntriesInfoTripList{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest * allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"EntriesInfoTrip" inManagedObjectContext:context]];
    [allContacts setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * companies = [context executeFetchRequest:allContacts error:&error];
    for (NSManagedObject * company in companies)
    {
        [context deleteObject:company];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    
}

-(void)emptyTripShareList{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSFetchRequest * allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"TripShare" inManagedObjectContext:context]];
    [allContacts setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * companies = [context executeFetchRequest:allContacts error:&error];
    for (NSManagedObject * company in companies) {
        [context deleteObject:company];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    
}

-(void)emptyGroupList{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSFetchRequest * allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"Groups" inManagedObjectContext:context]];
    [allContacts setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * companies = [context executeFetchRequest:allContacts error:&error];
    for (NSManagedObject * company in companies) {
        [context deleteObject:company];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    
}
-(void)emptyTripSharelist{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest * allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"TripShare" inManagedObjectContext:context]];
    [allContacts setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * companies = [context executeFetchRequest:allContacts error:&error];
    for (NSManagedObject * company in companies) {
        [context deleteObject:company];
    }
    NSError *saveError = nil;
    [context save:&saveError];
}
@end
