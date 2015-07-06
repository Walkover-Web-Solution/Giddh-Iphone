//
//  PersonalHomeVC.m
//  Giddh
//
//  Created by Admin on 16/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "PersonalHomeVC.h"
#import "RNFrostedSidebar.h"
#import "AppDelegate.h"
#import "ServiceManager.h"
#import "TransactionTypeViewController.h"
#import "Accounts.h"
#import "EntriesInfoTrip.h"
#import "Entries.h"
#import "TripHomeVC.h"
#import "AppData.h"
#import "SummaryViewController.h"
#import "TripInfo.h"
#import "SettingsViewController.h"
#import "Companies.h"
#import "BankInitialBalanceVC.h"
#import "UserHomeVC.h"
#import "BTSimpleSideMenu.h"
#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"
#import "DeletedEntries.h"
#import "WalletInitialBalanceVC.h"

static NSString *const menuCellIdentifier = @"rotationCell";

@interface PersonalHomeVC ()<RNFrostedSidebarDelegate,BTSimpleSideMenuDelegate,UITableViewDelegate,
UITableViewDataSource,YALContextMenuTableViewDelegate>{
    
    __weak IBOutlet UIButton *btnGivingMoney;
    __weak IBOutlet UILabel *lblHeader;
    __weak IBOutlet UIButton *btnReceivingMoney;
    NSArray *arrAccounts;
    NSArray *arrEntries;
    NSArray *arrTripInfo;
    NSArray *arrDeletedEntries;
    
}
@property(nonatomic)BTSimpleSideMenu *sideMenu;

@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;

- (IBAction)receivingMoneyButtonAction:(id)sender;
- (IBAction)menuButtonAction:(id)sender;
@property (nonatomic, strong) NSMutableIndexSet *optionIndices;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)givingMoneyButtonAction:(id)sender;

@end

@implementation PersonalHomeVC
@synthesize companyName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // sync companies
    [[AppData sharedData] syncCompanyList];
    //  [self configureLayout];
    // NSLog(@"%@ id ==%@",self.companies.companyName,self.companies.companyId);
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self initiateMenuOptions];
    
    arrEntries= [NSArray array];
    
    
    self.optionIndices = [NSMutableIndexSet indexSetWithIndex:1];
    NSString *checkFirstTime = [[NSUserDefaults standardUserDefaults]valueForKey:@"accountFirstTime"];
    if(![checkFirstTime isEqual:@"done"]){
        [self initialiseAccounts];
    }
    NSString *checkFirstTimeForGrp = [[NSUserDefaults standardUserDefaults]valueForKey:@"groupFirstTime"];
    if(![checkFirstTimeForGrp isEqual:@"done"]){
        [self initialiseGroup];
    }
    [self syncAccounts];
    [self syncEntryInfo];
    [self syncAllNullEntries];
    [self syncTripList];
    // NSLog(@"%@",self.companies.companyName);
    // _sideMenu.delegate = self;
    //[_sideMenu toggleMenu];
    arrDeletedEntries = [NSArray array];
    [self getDeletedEntries];
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

-(void)getAllTripInfo{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrAccounts=[[context executeFetchRequest:request error:&error]mutableCopy];
}

-(void)viewWillAppear:(BOOL)animated
{
    companyName = [self getCompanyNameById:self.companies.companyId];
    lblHeader.text=companyName;
}

-(NSString *)getCompanyNameById:(NSNumber *)companyID
{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    //NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Companies"];
    
    //Apply filter condition
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"companyId == %@", companyID]];
    
    //NSArray *tempArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSError *error = nil;
    NSArray *objectArr = [context executeFetchRequest:fetchRequest error:&error];
    NSString *strCompName;
    if(objectArr.count!=0){
        Companies *objComp = [objectArr objectAtIndex:0];
        strCompName = objComp.companyName;
    }
    else{
        strCompName = self.companies.companyName;
    }
    return strCompName;
    
}
-(void)deleteAllDeletedEntries{
    [[ServiceManager sharedManager]getAllDeletedEntriesforAuthKey:@"" andcompanyid:[NSString stringWithFormat:@"%@",self.companies.companyId] withCompletionBlock:^(NSDictionary *responce, NSError *error) {
        // NSLog(@"%@",responce);
        NSArray *arrData = [responce valueForKey:@"data"];
        NSDictionary *dictData = [arrData objectAtIndex:0];
        NSArray *arrEntryId = [dictData valueForKey:@"entryId"];
        for(NSString *entryId in arrEntryId){
            for(Entries *entry in arrEntries){
                if([entry.entryId isEqual:[NSNumber numberWithInt:[entryId intValue]]]){
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    //create managed object context
                    NSManagedObjectContext *context = [appDelegate managedObjectContext];
                    NSError *error;
                    [context deleteObject:entry];
                    [context save:&error];
                    
                }
            }
        }
        
    }];
}

-(void) syncTripList
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    //MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText=@"Syncing..";
    [[ServiceManager sharedManager] syncTripForAuthKey:[userDef valueForKey:@"AuthKey"] andCompanyId:[self.companies.companyId intValue] withCompletionBlock:^(NSDictionary *responce, NSError *error)
     {
         //[MBProgressHUD hideHUDForView:self.view animated:YES];
         NSString *strStatus = [responce valueForKey:@"status"];
         int intStatus = [strStatus intValue];
         
         if (intStatus == 1)
         {
             NSArray *arrData = [responce valueForKey:@"data"];
             //get group details
             for (NSMutableDictionary *dictTrip in arrData)
             {
                 AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                 NSManagedObjectContext *contextTrip=[appDelegate managedObjectContext];
                 NSFetchRequest *fetchRequestTrip = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
                 //Apply filter condition
                 [fetchRequestTrip setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:[[dictTrip valueForKey:@"tripId"] intValue]]]];
                 
                 NSArray *tripArr = [[contextTrip executeFetchRequest:fetchRequestTrip error:nil] mutableCopy];
                 // add a new company
                 if(tripArr.count == 0)
                 {
                     NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"TripInfo" inManagedObjectContext:contextTrip];
                     
                     [newDevice setValue:[NSNumber numberWithInt:[[dictTrip valueForKey:@"tripId"] intValue]] forKey:@"tripId"];
                     [newDevice setValue:[dictTrip valueForKey:@"tripName"] forKey:@"tripName"];
                     [newDevice setValue:[NSNumber numberWithInt:[[dictTrip valueForKey:@"owner"] intValue]] forKey:@"owner"];
                     [newDevice setValue:[NSNumber numberWithInt:[self.companies.companyId intValue]] forKey:@"companyId"];
                 }
                 else
                 {
                     //Update trip list
                     TripInfo *tripObject = tripArr[0];
                     tripObject.tripName = [dictTrip valueForKey:@"tripName"];
                     tripObject.tripId = [NSNumber numberWithInt:[[dictTrip valueForKey:@"tripId"] intValue]];
                     tripObject.owner = [NSNumber numberWithInt:[[dictTrip valueForKey:@"owner"] intValue]];
                     tripObject.companyId = [NSNumber numberWithInt:[self.companies.companyId intValue]];
                 }
                 [contextTrip save:&error];
             }
         }
         else
         {
             //  NSLog(@"Error while syncing trip");
         }
     }];
}

-(void)syncAccounts{
    if( [[AppData sharedData]isInternetAvailable]){
        [[ServiceManager sharedManager]getAccountListForAuthKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"authKey"] companyName:self.companies.companyName companyid:[self.companies.companyId stringValue] andMobile:@"1" withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            //NSLog(@"%@",responce);
            NSArray *data = [responce valueForKey:@"data"];
            NSMutableArray *arrAllAccountId = [NSMutableArray array];
            if (data.count > 0)
            {
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
                        //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@ AND groupId contains[cd] %@", [dictAccounts valueForKey:@"accountName"],grpId];
                        // [request setPredicate:predicate];
                        [request setEntity:entityDescr];
                        NSError *error;
                        NSArray * arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                        NSMutableArray *arrtempData = [NSMutableArray array];
                        for(Accounts *account in arrData){
                            if([[account.accountName lowercaseString] isEqual:[[dictAccounts valueForKey:@"accountName"] lowercaseString]] && [account.groupId isEqual:grpId])
                            {
                                [arrtempData addObject:account];
                            }
                        }
                        if(arrtempData.count==0){
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
                            [arrAllAccountId addObject:accountId];
                            [newAccount setValue:[dictAccounts valueForKey:@"accountName"] forKeyPath:@"accountName"];
                            [newAccount setValue:self.companies.emailId forKeyPath:@"emailId"];
                            [newAccount setValue:grpId forKeyPath:@"groupId"];
                            [newAccount setValue:[NSNumber numberWithDouble:[[dictAccounts valueForKey:@"openingBalance"] doubleValue]] forKeyPath:@"openingBalance"];
                            [newAccount setValue:[dictAccounts valueForKey:@"uniqueName"] forKeyPath:@"uniqueName"];
                            [newAccount setValue:accountId forKeyPath:@"accountId"];
                            // NSLog(@"newAccount %@",newAccount);
                            [context insertObject:newAccount];
                            [context save:&error];
                            
                        }
                        else{
                            //update existin account
                            Accounts *account = arrtempData[0];
                            [arrAllAccountId addObject:account.accountId];
                            account.openingBalance =[NSNumber numberWithDouble:[[dictAccounts valueForKey:@"openingBalance"] doubleValue]];
                            [context save:&error];
                        }
                        //                      for(Accounts *account in arrAccounts ){
                        //                            if(account.accountId>[NSNumber numberWithInt:16]){
                        //                                  if(![arrAllAccountId containsObject:account.accountId]){
                        //                                        NSManagedObjectContext *context=[appDelegate managedObjectContext];
                        //                                        [context deleteObject:account];
                        //                                        [self refreshAccounts];
                        //                                  }
                        //
                        //                            }
                        //                                                 }
                    }
                }
            }
            
        }];
    }
    
    
}
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
        [[ServiceManager sharedManager]getEntrySummaryForAuthKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"authKey"] companyid:[self.companies.companyId stringValue] andEntryId:[NSString stringWithFormat:@"%d",max ] withCompletionBlock:^(NSDictionary *responce, NSError *error) {
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
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName == [cd]%@ AND groupId == %@", [creditAccountName lowercaseString],creditGrpId];
                    [request setPredicate:predicate];
                    [request setEntity:entityDescr];
                    NSError *error;
                    arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                    
                    NSMutableArray *arrCreTempData = [NSMutableArray array];
                    for(Accounts *accounts in arrData){
                        if([[accounts.accountName lowercaseString] isEqual:[creditAccountName lowercaseString]]){
                            [arrCreTempData addObject:accounts];
                        }
                    }
                    
                    if(arrCreTempData.count==0){
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
                        [newAccount setValue:self.companies.emailId forKeyPath:@"emailId"];
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
                        Accounts *accountsCre = arrCreTempData[0];
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
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName == [cd]%@ AND groupId == %@", debitAccountName ,debitGrpId];
                    [request setPredicate:predicate];
                    [request setEntity:entityDescr];
                    NSError *error;
                    arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                    NSMutableArray *arrDebTempData = [NSMutableArray array];
                    for(Accounts *accounts in arrData){
                        if([[accounts.accountName lowercaseString] isEqual:[debitAccountName lowercaseString]]){
                            [arrDebTempData addObject:accounts];
                        }
                    }
                    if(arrDebTempData.count==0){
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
                        [newAccount setValue:self.companies.emailId forKeyPath:@"emailId"];
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
                        Accounts *accountsDeb = arrDebTempData[0];
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
                [newEntry setValue:[NSNumber numberWithInt:[[dict valueForKey:@"tripId"] intValue]] forKey:@"tripId"];
                [newEntry setValue:self.companies.companyId forKey:@"companyId"];
                [newEntry setValue:[NSNumber numberWithInt:[amount intValue]] forKey:@"amount"];
                [newEntry setValue:[NSNumber numberWithInt:[entryId intValue]] forKey:@"entryId"];
                [context insertObject:newEntry];
                [context save:&error];
            }
            //[self getAllEntries];
            [self performSelector:@selector(getAllEntries) withObject:nil afterDelay:0.25];
            [self deleteAllDeletedEntries];
            [self deleteLocallyDeletedEntriesFromServer];
            NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
            [DateFormatter setDateFormat:@"dd-MMM-yyyy HH:mm:ss"];
            NSString * strDateTime = [DateFormatter stringFromDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setValue:strDateTime forKey:@"syncDateTime"];
        }];
    }
}

-(void)syncAllNullEntries{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrAllEntries =[[context executeFetchRequest:request error:&error]mutableCopy];
    for(Entries *entry in arrAllEntries){
        if([entry.entryId isEqual:[NSNumber numberWithInt:0]]){
            if(!([entry.date isEqual:nil]))
                [self syncEntry:entry];
        }
    }
}

-(void)syncEntry:(Entries*)entry{
    Accounts *creditAccount;
    Accounts *debitAccount;
    for(Accounts *account in arrAccounts){
        if([account.accountId isEqual:entry.creditAccount]){
            creditAccount = account;
        }
        else if ([account.accountId isEqual:entry.debitAccount]){
            debitAccount =account;
        }
    }
    int debGrpId = [debitAccount.groupId intValue];
    NSString *debGrpType;
    switch (debGrpId) {
        case 0:
            debGrpType = @"Income";
            break;
        case 1:
            debGrpType = @"Expense";
            break;
            
        case 2:
            debGrpType = @"Liability";
            break;
            
        case 3:
            debGrpType = @"Assets";
            break;
            
        default:
            break;
    }
    int creGrpId = [creditAccount.groupId intValue];
    
    NSString *creGrpType;
    switch (creGrpId) {
        case 0:
            creGrpType = @"Income";
            break;
        case 1:
            creGrpType = @"Expense";
            break;
        case 2:
            creGrpType = @"Liability";
            break;
        case 3:
            creGrpType = @"Assets";
            break;
            
        default:
            break;
    }
    NSString * strArrCredit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\",,\"uniqueName\":\"%@\"}]",creditAccount.accountName,entry.amount,creGrpType,creGrpType,creditAccount.uniqueName];
    NSString * strArrDebit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\",,\"uniqueName\":\"%@\"}]",debitAccount.accountName,entry.amount,debGrpType,debGrpType,debitAccount.uniqueName];
    //   NSError *error = nil;
    NSString *uniqueName = creditAccount.uniqueName;
    if([uniqueName isEqual:@""])
        uniqueName =debitAccount.uniqueName;
    [[ServiceManager sharedManager]createEntryForAuthKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"] andTripId:[entry.tripId intValue] andMobile:@"1" date:entry.date companyName:self.companies.companyName withDescription:entry.descriptionEntry  withDebit:strArrDebit andCredit:strArrCredit withTransactionType:[NSString stringWithFormat:@"%@",entry.transactionType] andUniqueName:uniqueName withCompletionBlock:^(NSDictionary *responce, NSError *error) {
        // NSLog(@"%@",responce);
        NSString * status = [NSString stringWithFormat:@"%@",[responce valueForKey:@"status"]];
        NSString *entryId;
        
        if([status isEqual:@"1"]){
            NSArray * arrData = [responce valueForKey:@"data"];
            NSDictionary *dataDict = arrData[0];
            entryId = [dataDict valueForKey:@"entryId"];
            
        }
        
        AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context=[appDelegate managedObjectContext];
        entry.entryId = [NSNumber numberWithInt:[entryId intValue]];
        [context save:&error];
    }];
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

/*
 -(void)getAllEtries{
 AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
 NSManagedObjectContext *context=[appDelegate managedObjectContext];
 NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
 NSFetchRequest *request=[[NSFetchRequest alloc]init];
 [request setEntity:entityDescr];
 NSError *error;
 NSArray *arrAccounts1=[[context executeFetchRequest:request error:&error]mutableCopy];
 arrEntries = arrAccounts1;
 //NSLog(@"%@",arrAccounts1);
 if (arrAccounts1.count == 0 )
 {
 [self showWalletPopup];
 }
 }
 */

-(void)getAllEntries{
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrAccounts1=[[context executeFetchRequest:request error:&error]mutableCopy];
    arrEntries = arrAccounts1;
    //check bank account entry
    //arrBankAcc = [NSMutableArray array];
    //AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *contextBank =[appDelegate managedObjectContext];
    NSFetchRequest *requestBank = [[NSFetchRequest alloc] initWithEntityName:@"Accounts"];
    [requestBank setPredicate:[NSPredicate predicateWithFormat:@"groupId == %@ AND accountName !=[c] %@", [NSNumber numberWithInt:3],@"Cash"]];
    NSError *errorBank = nil;
    NSArray *objectArr = [contextBank executeFetchRequest:requestBank error:&errorBank];
    
    int walletCash = 0;
    //if (objectArr.count == 0){
    NSManagedObjectContext *contextCash = [appDelegate managedObjectContext];
    NSFetchRequest *requestCash = [[NSFetchRequest alloc] initWithEntityName:@"Accounts"];
    [requestCash setPredicate:[NSPredicate predicateWithFormat:@"accountName ==[c] %@",@"Cash"]];
    NSError *errorCash = nil;
    NSArray *arrCash = [contextCash executeFetchRequest:requestCash error:&errorCash];
    Accounts *objectAcc = arrCash[0];
    walletCash = [objectAcc.openingBalance intValue];
    //}
    
    //cell.textLabel.text = objectAcc.accountName;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", objectAcc.openingBalance];
    //NSLog(@"%@",arrAccounts1);
    //arrAccounts1.count == 0  &&
    if ((objectArr.count == 0))
    {
        [self showWalletPopup];
    }
    else if (walletCash == 0)
    {
        //show only wallet cash balance popup
        UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
        WalletInitialBalanceVC *vc = [sb2 instantiateViewControllerWithIdentifier:@"WalletInitialBalanceVC"];
        vc.companyId = [self.companies.companyId intValue];
        vc.companyName = self.companies.companyName;
        [self.view addSubview:vc.view];
        [self addChildViewController:vc];
    }
}

-(void)initialiseGroup{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSArray *arrGroups = [NSArray arrayWithObjects:@"Income",@"Expense",@"Liability",@"Assests", nil];
    for(int i =0;i<4;i++){
        NSError *error = nil;
        NSManagedObject *newAccount;
        newAccount = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Groups"
                      inManagedObjectContext:context];
        
        NSNumber *groupId = [NSNumber numberWithInt:i];
        
        [newAccount setValue:self.companies.emailId forKeyPath:@"emailId"];
        [newAccount setValue:arrGroups[i] forKeyPath:@"groupName"];
        [newAccount setValue:groupId forKeyPath:@"parentId"];
        [newAccount setValue:groupId forKeyPath:@"systemId"];
        [context insertObject:newAccount];
        [context save:&error];
    }
    [[NSUserDefaults standardUserDefaults]setValue:@"done" forKey:@"groupFirstTime"];
}
-(void)initialiseAccounts{
    
    NSArray *arrAccount = [NSArray arrayWithObjects:
                           @{@"name":@"Food",@"accountId":@"1",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Petrol",@"accountId":@"2",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Phone bill",@"accountId":@"3",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Electricity bill",@"accountId":@"4",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Rent",@"accountId":@"5",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@"expenseRent"},
                           
                           @{@"name":@"Other",@"accountId":@"6",@"groupId":@"0",@"openingBalance":@"0",@"uniqueName":@"otherIncome"},
                           
                           @{@"name":@"Other",@"accountId":@"17",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@"otherExpense"},
                           
                           @{@"name":@"Shopping",@"accountId":@"7",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Salary",@"accountId":@"8",@"groupId":@"0",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Loan",@"accountId":@"9",@"groupId":@"2",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Travelling",@"accountId":@"10",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Cash",@"accountId":@"11",@"groupId":@"3",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Water bill",@"accountId":@"12",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Rent",@"accountId":@"13",@"groupId":@"0",@"openingBalance":@"0",@"uniqueName":@"incomeRent"},
                           
                           @{@"name":@"Movies",@"accountId":@"14",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"Newspaper",@"accountId":@"15",@"groupId":@"1",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           @{@"name":@"ATM withdraw",@"accountId":@"16",@"groupId":@"0",@"openingBalance":@"0",@"uniqueName":@""},
                           
                           nil];
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    
    for(NSDictionary *dictionary in arrAccount){
        NSError *error = nil;
        NSManagedObject *newAccount;
        newAccount = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Accounts"
                      inManagedObjectContext:context];
        
        NSNumber *accountId = [NSNumber numberWithInt:[[dictionary valueForKey:@"accountId"] intValue]];
        NSNumber *groupId = [NSNumber numberWithInt:[[dictionary valueForKey:@"groupId"] intValue]];
        NSNumber *openingBalance = [NSNumber numberWithInt:[[dictionary valueForKey:@"openingBalance"] floatValue]];
        [newAccount setValue:accountId forKeyPath:@"accountId"];
        [newAccount setValue:[dictionary valueForKey:@"name"] forKeyPath:@"accountName"];
        [newAccount setValue:[dictionary valueForKey:self.companies.emailId] forKeyPath:@"emailId"];
        [newAccount setValue:groupId forKeyPath:@"groupId"];
        [newAccount setValue:openingBalance forKeyPath:@"openingBalance"];
        [newAccount setValue:[dictionary valueForKey:@"uniqueName"] forKeyPath:@"uniqueName"];
        
        [context insertObject:newAccount];
        [context save:&error];
        
    }
    [[NSUserDefaults standardUserDefaults]setValue:@"done" forKey:@"accountFirstTime"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)receivingMoneyButtonAction:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
    TransactionTypeViewController *vc = [sb instantiateViewControllerWithIdentifier:@"TransactionTypeViewController"];
    vc.type = @"0";
    vc.companies= self.companies;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
    navController.navigationBarHidden =YES;
    [self.navigationController pushViewController:vc animated:YES];
    //[self presentViewController:navController animated:YES completion:NULL];
    
    
}

- (IBAction)menuButtonAction:(id)sender {
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = .05f;
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
    // NSLog(@"Tapped item at index %lu",(unsigned long)index);
    if (index == 0) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
        TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
        vc.globalCompanyId = [self.companies.companyId intValue];
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //navController.navigationBarHidden =YES;
        vc.companies = self.companies;
        
        [self presentViewController:navController animated:YES completion:nil];
        
        [sidebar dismissAnimated:YES completion:nil];
    }
    if(index == 1){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        SettingsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        vc.globalCompanyId = [self.companies.companyId intValue];
        vc.globalCompanyName = self.companies.companyName;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //navController.navigationBarHidden =YES;
        [self presentViewController:navController animated:YES completion:nil];
        
        [sidebar dismissAnimated:YES completion:nil];
    }
    if (index == 2) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
        SummaryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SummaryViewController"];
        //vc.globalCompanyId = [self.companies.companyId intValue];
        vc.companies =self.companies;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        navController.navigationBarHidden =YES;
        [self presentViewController:navController animated:YES completion:nil];
        
        [sidebar dismissAnimated:YES completion:nil];
    }
    if (index == 3) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didEnable:(BOOL)itemEnabled itemAtIndex:(NSUInteger)index {
    if (itemEnabled) {
        [self.optionIndices addIndex:index];
    }
    else {
        [self.optionIndices removeIndex:index];
    }
}


- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)givingMoneyButtonAction:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
    TransactionTypeViewController *vc = [sb instantiateViewControllerWithIdentifier:@"TransactionTypeViewController"];
    vc.type = @"1";
    vc.companies= self.companies;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
    //   navController.navigationBarHidden =YES;
    [self.navigationController pushViewController:vc animated:YES];
    
    // [self presentViewController:navController animated:YES completion:NULL];
}

#pragma mark Wallet Initial Methods
-(void) showWalletPopup
{
    UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
    BankInitialBalanceVC *vc = [sb2 instantiateViewControllerWithIdentifier:@"BankInitialBalanceVC"];
    vc.companyId = [self.companies.companyId intValue];
    vc.companyName = self.companies.companyName;
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
}

#pragma -mark BTSimpleSideMenuDelegate
-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu didSelectItemAtIndex:(NSInteger)index {
    // NSLog(@"Tapped item at index %lu",(unsigned long)index);
    if (index == 0) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
        TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
        vc.globalCompanyId = [self.companies.companyId intValue];
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //navController.navigationBarHidden =YES;
        vc.companies = self.companies;
        
        [self presentViewController:navController animated:YES completion:nil];
        
        // [sidebar dismissAnimated:YES completion:nil];
    }
    if(index == 1){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        SettingsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        vc.globalCompanyId = [self.companies.companyId intValue];
        vc.globalCompanyName = self.companies.companyName;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //navController.navigationBarHidden =YES;
        [self presentViewController:navController animated:YES completion:nil];
        
        //  [sidebar dismissAnimated:YES completion:nil];
    }
    if (index == 2) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
        SummaryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SummaryViewController"];
        //vc.globalCompanyId = [self.companies.companyId intValue];
        vc.companies =self.companies;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        navController.navigationBarHidden =YES;
        [self presentViewController:navController animated:YES completion:nil];
        
        //  [sidebar dismissAnimated:YES completion:nil];
    }
    if (index == 3) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu selectedItemTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Menu Clicked"
                                                   message:[NSString stringWithFormat:@"Item Title : %@", title]
                                                  delegate:self
                                         cancelButtonTitle:@"Dismiss"
                                         otherButtonTitles:nil, nil];
    [alert show];
}
#pragma mark - initiateMenuOptions

- (void)initiateMenuOptions {
    self.menuTitles = @[@"",
                        @"Trip",
                        @"Settings",
                        @"Summary",
                        @"Company",
                        ];
    
    self.menuIcons = @[[UIImage imageNamed:@"icn_close"],
                       [UIImage imageNamed:@"trip_icon1"],
                       [UIImage imageNamed:@"settings_icon1"],
                       [UIImage imageNamed:@"summary_icon1"],
                       [UIImage imageNamed:@"company_icon1"],
                       
                       ];
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    // NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //   NSLog(@"Tapped item at index %lu",(unsigned long)index);
    UIViewController *presentingVC = [self presentingViewController];
    NSString *pagetype = [[NSUserDefaults standardUserDefaults]valueForKey:@"firstPageType"];

    if (indexPath.row == 1) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
        TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
        vc.globalCompanyId = [self.companies.companyId intValue];
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //navController.navigationBarHidden =YES;
        vc.companies = self.companies;
        
        if([pagetype isEqual:@"transaction"]){
            [self presentViewController:navController animated:YES completion:nil];
        }
        else{
            [self dismissViewControllerAnimated:NO completion:
             ^{
                 [presentingVC presentViewController:navController animated:YES completion:nil];
             }];
        }
        
        
        // [sidebar dismissAnimated:YES completion:nil];
    }
    if(indexPath.row == 2){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        SettingsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        vc.globalCompanyId = [self.companies.companyId intValue];
        vc.globalCompanyName = self.companies.companyName;
        vc.companies = self.companies;
        
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //navController.navigationBarHidden =YES;
        if([pagetype isEqual:@"transaction"]){
            [self presentViewController:navController animated:YES completion:nil];
        }
        else{
            [self dismissViewControllerAnimated:NO completion:
             ^{
                 [presentingVC presentViewController:navController animated:YES completion:nil];
             }];
        }
        //  [sidebar dismissAnimated:YES completion:nil];
    }
    if (indexPath.row == 3) {
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
            if([pagetype isEqual:@"summary"]){
                [self dismissViewControllerAnimated:NO completion:
                 ^{
                     [presentingVC presentViewController:navController animated:YES completion:nil];
                 }];

            }
            else
                [self presentViewController:navController animated:YES completion:nil];
                   }
        //  [sidebar dismissAnimated:YES completion:nil];
    }
    if(indexPath.row == 4){
        //          NSString *pagetype = [[NSUserDefaults standardUserDefaults]valueForKey:@"firstPageType"];
        //
        //          if([pagetype isEqual:@"summary"]){
        //              UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //              UserHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"UserHomeVC"];
        //              UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //              navController.navigationBarHidden =NO;
        //              [self presentViewController:navController animated:YES completion:NULL];
        //
        //          }
        //          else{
        [self dismissViewControllerAnimated:NO completion:
         ^{
             [presentingVC dismissViewControllerAnimated:YES completion:nil];
         }];
        //  }
        
    }
    [tableView dismisWithIndexPath:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
        cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
        [cell.btnDismiss addTarget:self action:@selector(dismissSideMenu) forControlEvents:UIControlEventAllEvents];
    }
    
    return cell;
}
-(void)dismissSideMenu{
    [self.contextMenuTableView dismisWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

@end
