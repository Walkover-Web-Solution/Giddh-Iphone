//
//  TripHomeVC.m
//  Giddh
//
//  Created by Admin on 21/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TripHomeVC.h"
#import "ServiceManager.h"
#import "TripInfo.h"
#import "TripSummaryVC.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "AddTripVC.h"
#import "Accounts.h"
#import "EntriesInfoTrip.h"
#import "Entries.h"
#import "RNFrostedSidebar.h"
#import "SettingsViewController.h"
#import "SummaryViewController.h"
#import "BTSimpleSideMenu.h"
#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"
#import "PersonalHomeVC.h"
#import "UserHomeVC.h"
#import "AppData.h"

static NSString *const menuCellIdentifier = @"rotationCell";
@interface TripHomeVC ()<RNFrostedSidebarDelegate,BTSimpleSideMenuDelegate,UITableViewDelegate,YALContextMenuTableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableIndexSet *optionIndices;
@property(nonatomic)BTSimpleSideMenu *sideMenu;
@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;
@end

@implementation TripHomeVC
@synthesize globalCompanyId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // sync companies
    [[AppData sharedData] syncCompanyList];
    
    arrTableData = [NSMutableArray array];
    self.optionIndices = [NSMutableIndexSet indexSetWithIndex:1];
    [self initiateMenuOptions];
   
    //self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, -20, 0);
    userDef = [NSUserDefaults standardUserDefaults];
    UIBarButtonItem * Item2= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTripButton)];
    UIBarButtonItem * Item1= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"burger.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonAction)];
    NSArray * buttonArray =[NSArray arrayWithObjects:Item1,Item2 ,nil];
    
    self.navigationItem.rightBarButtonItems =buttonArray;
    lblMessage.hidden = YES;
    btnSync.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    //sync data from server
    //hit API
    //[self performSelector:@selector(syncTripList) withObject:nil afterDelay:0.5];
    
    if([[AppData sharedData] isInternetAvailable])
    {
        [self syncTripList];
    }
    
    
    //[self reloadTable];
    [self performSelector:@selector(reloadTable) withObject:nil afterDelay:0.5];
    tableViewTrips.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void) syncTripList
{
    if([[AppData sharedData] isInternetAvailable])
    {
        if (arrTableData.count == 0)
        {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"Syncing..";
        }
        [[ServiceManager sharedManager] syncTripForAuthKey:[userDef valueForKey:@"AuthKey"] andCompanyId:globalCompanyId withCompletionBlock:^(NSDictionary *responce, NSError *error)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
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
                     
                     AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
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
        [self reloadTable];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Internet not Available" message:@"Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [av show];
    }
}

-(void)reloadTable
{
    //get data from local DB
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
    arrTableData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (arrTableData.count == 0)
    {
        //show message label
        lblMessage.hidden = NO;
        btnSync.hidden = NO;
        tableViewTrips.hidden = YES;
    }
    else
    {
        [tableViewTrips reloadData];
        tableViewTrips.hidden = NO;
        lblMessage.hidden = YES;
        btnSync.hidden = YES;
    }
    
    
}

-(void) goToAddTrip
{
    [self performSegueWithIdentifier:@"addTripIdentifier" sender:nil];
}

#pragma mark DB Methods
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrTableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableViewTrips dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    TripInfo *trip = arrTableData[indexPath.row];
    cell.textLabel.text = trip.tripName;
    
    //set font family
    cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    
    return cell;
    
}

#pragma mark TableView Delegate Methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get trip values
    TripInfo *trip = arrTableData[indexPath.row];
    selTripId = [trip.tripId intValue];
    selTripName = trip.tripName;
    selCompanyId = [trip.companyId intValue];
    ifOwner = [trip.owner intValue];
    
    //sync code START
    //sync trip summary
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Syncing..";
    
    //apply filter conditions for trip id and company id
    AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"EntriesInfoTrip" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripId == %@ AND companyId == %@", [NSNumber numberWithInt:selTripId],[NSNumber numberWithInt:selCompanyId]];
    
    request.fetchLimit = 1;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"entryId" ascending:NO]];
    
    NSError *error = nil;
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripId == %@ AND groupId contains[cd] %@", [NSNumber numberWithInt:selTripId],creditGrpId];
    //[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:intEditTripId]]];
    [request setPredicate:predicate];
    [request setEntity:entityDescr];
    //NSError *error;
    //NSArray *arData=[[context executeFetchRequest:request error:&error]mutableCopy];
    //int entryIdd = [context executeFetchRequest:request error:&error].lastObject;
    EntriesInfoTrip *infoObj = [context executeFetchRequest:request error:&error].lastObject;
    int entId = [infoObj.entryId intValue];
    NSLog(@"entry id == %d",entId);
    
    [[ServiceManager sharedManager] getTripSummaryForAuthKey:[userDef valueForKey:@"AuthKey"] companyId:selCompanyId  andTripId:selTripId andEntryId:entId withCompletionBlock:^(NSDictionary *responce, NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         NSLog(@"%@",responce);
         NSArray * arrData = [responce valueForKey:@"data"];
         NSNumber * creditGrpId;
         NSNumber * transactionType;
         NSString *creditAccountId;
         NSString *debitAccountId;
         NSString *amount ;
         for(NSDictionary *dict in arrData)
         {
             NSArray * arrCredit = [dict valueForKey:@"credit"];
             NSArray * arrDebit = [dict valueForKey:@"debit"];
             // NSDictionary * creditDict = arrCredit[0];
             //get sync email and user email
             NSString *syncListEmail = [dict valueForKey:@"email"];
             NSString *userEmail = [userDef valueForKey:@"userEmail"];
             
             for(NSDictionary * creditDict in arrCredit)
             {
                 
                 
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
                 else if([[debit0GrpName lowercaseString] isEqual:@"assets"]&&[[credit0GrpName lowercaseString] isEqual:@"assets"])
                 {
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
                 
                 
                 //if emaill is same else
                 
                 
                 if ([userEmail isEqualToString:syncListEmail])
                 {
                     //check for accounts with same grp id and account name.
                     AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
                     NSManagedObjectContext *context=[appDelegate managedObjectContext];
                     NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                     NSFetchRequest *request=[[NSFetchRequest alloc]init];
                     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@ AND groupId contains[cd] %@", creditAccountName,creditGrpId];
                     [request setPredicate:predicate];
                     [request setEntity:entityDescr];
                     NSError *error;
                     arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                     
                     //get account id from account name
                     NSLog(@"user email = %@",[userDef valueForKey:@"userEmail"]);
                     if(arrData.count==0)
                     {
                         [self refreshAccounts];
                         // create a new account with max account id
                         NSMutableArray *arrAccountId = [NSMutableArray array];
                         
                         
                         for(Accounts *accounts in arrAccounts)
                         {
                             [arrAccountId addObject:accounts.accountId];
                         }
                         
                         int max = [[arrAccountId valueForKeyPath:@"@max.intValue"] intValue];
                         max++;
                         NSManagedObject *newAccount;
                         newAccount = [NSEntityDescription insertNewObjectForEntityForName:@"Accounts" inManagedObjectContext:context];
                         NSString *openingBalanceNum = @"0";
                         NSNumber *openingBalance = [NSNumber numberWithInt:[openingBalanceNum floatValue]];
                         NSNumber *accountId = [NSNumber numberWithInt:max];
                         
                         [newAccount setValue:creditAccountName forKeyPath:@"accountName"];
                         [newAccount setValue:syncListEmail forKeyPath:@"emailId"];
                         [newAccount setValue:creditGrpId forKeyPath:@"groupId"];
                         [newAccount setValue:openingBalance forKeyPath:@"openingBalance"];
                         [newAccount setValue:@"" forKeyPath:@"uniqueName"];
                         [newAccount setValue:accountId forKeyPath:@"accountId"];
                         NSLog(@"newAccount %@",newAccount);
                         [context insertObject:newAccount];
                         [context save:&error];
                         creditAccountId = [NSString stringWithFormat:@"%@",accountId];
                         [self refreshAccounts];
                     }
                     else{
                         Accounts *accountsCre = arrData[0];
                         creditAccountId = [NSString stringWithFormat:@"%@",accountsCre.accountId];
                     }
                 }
                 else
                 {
                     //make entries as it is
                     creditAccountId = creditAccountName;
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
                 
                 
                 //set condition for inserting account name or account id
                 if ([userEmail isEqualToString:syncListEmail])
                 {
                     [self refreshAccounts];
                     AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
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
                         [newAccount setValue:syncListEmail forKeyPath:@"emailId"];
                         [newAccount setValue:debitGrpId forKeyPath:@"groupId"];
                         [newAccount setValue:openingBalance forKeyPath:@"openingBalance"];
                         [newAccount setValue:@"" forKeyPath:@"uniqueName"];
                         [newAccount setValue:accountId forKeyPath:@"accountId"];
                         [context insertObject:newAccount];
                         [context save:&error];
                         debitAccountId = [NSString stringWithFormat:@"%@",accountId];
                         [self refreshAccounts];
                     }
                     else{
                         Accounts *accountsDeb = arrData[0];
                         debitAccountId = [NSString stringWithFormat:@"%@",accountsDeb.accountId];
                     }
                 }
                 else
                 {
                     debitAccountId = debitAccountName;
                 }
                 
             }
             AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
             NSManagedObjectContext *context=[appDelegate managedObjectContext];
             NSError *error = nil;
             NSManagedObject *newEntry;
             newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"EntriesInfoTrip" inManagedObjectContext:context];
             NSString *entryId = [dict valueForKey:@"entryId"];
             [newEntry setValue:transactionType forKey:@"transactionType"];
             [newEntry setValue:[dict valueForKey:@"entryDate"] forKey:@"date"];
             [newEntry setValue:debitAccountId forKey:@"debitAccount"];
             [newEntry setValue:creditAccountId forKey:@"creditAccount"];
             [newEntry setValue:[NSNumber numberWithInt:globalCompanyId] forKey:@"companyId"];
             [newEntry setValue:syncListEmail forKey:@"email"];
             [newEntry setValue:[NSNumber numberWithInt:[amount intValue]] forKey:@"amount"];
             [newEntry setValue:[NSNumber numberWithInt:[entryId intValue]] forKey:@"entryId"];
             [newEntry setValue:[NSNumber numberWithInt:selTripId] forKey:@"tripId"];
             [context insertObject:newEntry];
             [context save:&error];
         }
         [self getAllEtries];
     }];
    //sync code END
    
    [self performSegueWithIdentifier:@"summaryIdentifier" sender:nil];
}
*/
-(void)refreshAccounts
{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrAccounts=[[context executeFetchRequest:request error:&error]mutableCopy];
}

-(void)getAllEtries{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"EntriesInfoTrip" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    //NSError *error;
    //NSArray *arrAccountsEntry=[[context executeFetchRequest:request error:&error]mutableCopy];
    //NSLog(@"%@",arrAccountsEntry);
//    for(Entries *entries in arrAccountsEntry)
//    {
//        NSLog(@"%@",entries.entryId);
//        NSLog(@"%@",entries.amount);
//        NSLog(@"%@",entries.companyId);
//        NSLog(@"%@",entries.creditAccount);
//        NSLog(@"%@",entries.debitAccount);
//        NSLog(@"tran type = %@",entries.transactionType);
//    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"summaryIdentifier"])
    {
        TripSummaryVC *vc = [segue destinationViewController];
        vc.selectedTripId = selTripId;
        vc.selectedTripName = selTripName;
        vc.selectedTripCompanyId = globalCompanyId;
        vc.ifTripOwner = ifOwner;
        vc.companies = self.companies;
    }
    if ([[segue identifier] isEqualToString:@"addTripIdentifier"])
    {
        AddTripVC *vc = [segue destinationViewController];
        vc.editFlag = false;
        vc.ifTripOwner = 2;
        vc.intCompanyId = globalCompanyId;
    }
}


- (IBAction)addTripAction:(id)sender
{
    
}
-(void)addTripButton{
    [self performSegueWithIdentifier:@"addTripIdentifier" sender:nil];

}
-(void)menuButtonAction{
//    NSArray *images = @[
//                        [UIImage imageNamed:@"settings_icon"],
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
    [self.contextMenuTableView showInView:self.navigationController.view withEdgeInsets:UIEdgeInsetsZero animated:YES];

    // it is better to use this method only for proper animation

}


#pragma mark - RNFrostedSidebarDelegate
- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    //[self dismissViewControllerAnimated:YES completion:nil];
    //    [self dismissViewControllerAnimated:NO completion:^{
   // NSLog(@"Tapped item at index %lu",(unsigned long)index);
//    if (index == 0) {
//        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
//        TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
//        vc.globalCompanyId = [self.companies.companyId intValue];
//        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
//        //navController.navigationBarHidden =YES;
//        //            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
//        [self presentViewController:navController animated:YES completion:nil];
//        //
//        //            }];
//        
//        [sidebar dismissAnimated:YES completion:nil];
//    }
    if(index == 0){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        SettingsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        vc.globalCompanyId = [self.companies.companyId intValue];
        vc.globalCompanyName = self.companies.companyName;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //navController.navigationBarHidden =YES;
        [self presentViewController:navController animated:YES completion:nil];
        
        [sidebar dismissAnimated:YES completion:nil];
    }
    if (index == 1) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
        SummaryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SummaryViewController"];
        //vc.globalCompanyId = [self.companies.companyId intValue];
        vc.companies =self.companies;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        navController.navigationBarHidden =YES;
        [self presentViewController:navController animated:YES completion:nil];

        [sidebar dismissAnimated:YES completion:nil];
    }
    if (index == 2) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    // here you can create a code for presetn C viewcontroller
    
    //   }];
    // [self.navigationController popToRootViewControllerAnimated:YES];
    
    
}

- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)syncAction:(id)sender
{
    [self syncTripList];
}


#pragma -mark BTSimpleSideMenuDelegate
-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu didSelectItemAtIndex:(NSInteger)index {
    //NSLog(@"Tapped item at index %lu",(unsigned long)index);
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
#pragma mark - initiateMenuOptions

- (void)initiateMenuOptions {
    self.menuTitles = @[@"",
                        @"Settings",
                        @"Summary",
                        @"Transaction",
                        @"Company",
                        ];
    
    self.menuIcons = @[[UIImage imageNamed:@"icn_close"],
                       [UIImage imageNamed:@"settings_icon1"],
                       [UIImage imageNamed:@"summary_icon1"],
                       [UIImage imageNamed:@"icon_Transaction"],
                       [UIImage imageNamed:@"company_icon1"],
                       ];
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
   // NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:tableViewTrips]){
        //get trip values
        TripInfo *trip = arrTableData[indexPath.row];
        selTripId = [trip.tripId intValue];
        selTripName = trip.tripName;
        selCompanyId = [trip.companyId intValue];
        ifOwner = [trip.owner intValue];
        
        //sync code START
        //sync trip summary
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText=@"Syncing..";
        
        //apply filter conditions for trip id and company id
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context=[appDelegate managedObjectContext];
        NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"EntriesInfoTrip" inManagedObjectContext:context];
        NSFetchRequest *request=[[NSFetchRequest alloc]init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripId == %@ AND companyId == %@", [NSNumber numberWithInt:selTripId],[NSNumber numberWithInt:selCompanyId]];
        
        request.fetchLimit = 1;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"entryId" ascending:NO]];
        
        NSError *error = nil;
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripId == %@ AND groupId contains[cd] %@", [NSNumber numberWithInt:selTripId],creditGrpId];
        //[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:intEditTripId]]];
        [request setPredicate:predicate];
        [request setEntity:entityDescr];
        //NSError *error;
        //NSArray *arData=[[context executeFetchRequest:request error:&error]mutableCopy];
        //int entryIdd = [context executeFetchRequest:request error:&error].lastObject;
        EntriesInfoTrip *infoObj = [context executeFetchRequest:request error:&error].lastObject;
        int entId = [infoObj.entryId intValue];
        //NSLog(@"entry id == %d",entId);
        
        [[ServiceManager sharedManager] getTripSummaryForAuthKey:[userDef valueForKey:@"AuthKey"] companyId:selCompanyId  andTripId:selTripId andEntryId:entId withCompletionBlock:^(NSDictionary *responce, NSError *error)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             //NSLog(@"%@",responce);
             NSArray * arrData = [responce valueForKey:@"data"];
             NSNumber * creditGrpId;
             NSNumber * transactionType;
             NSString *creditAccountId;
             NSString *debitAccountId;
             NSString *amount ;
             for(NSDictionary *dict in arrData)
             {
                 NSArray * arrCredit = [dict valueForKey:@"credit"];
                 NSArray * arrDebit = [dict valueForKey:@"debit"];
                 // NSDictionary * creditDict = arrCredit[0];
                 //get sync email and user email
                 NSString *syncListEmail = [dict valueForKey:@"email"];
                 NSString *userEmail = [userDef valueForKey:@"userEmail"];
                 
                 for(NSDictionary * creditDict in arrCredit)
                 {
                     
                     
                     NSString *creditGrpName = [creditDict valueForKey:@"groupName"];
                     NSString *creditAccountName = [creditDict valueForKey:@"accountName"];
                     amount = [creditDict valueForKey:@"amount"];
                     
                     
                     
                     // get first credit and debit groupname
                     NSDictionary * debitAt0 = arrDebit[0];
                     NSString * debit0GrpName = [debitAt0 valueForKey:@"groupName"];
                     NSDictionary * creditAt0 = arrCredit[0];
                     NSString * credit0GrpName = [creditAt0 valueForKey:@"groupName"];
                     transactionType = [NSNumber numberWithInt:0];

                     //set transaction type
                     if([[debit0GrpName lowercaseString] isEqual:@"income"]||[[credit0GrpName lowercaseString] isEqual:@"income"] || [[credit0GrpName lowercaseString] isEqual:@"liability"]){
                         transactionType = [NSNumber numberWithInt:0];
                     }
                     else if([[debit0GrpName lowercaseString] isEqual:@"expense"]||[[credit0GrpName lowercaseString] isEqual:@"expense"] || [[debit0GrpName lowercaseString] isEqual:@"liability"]){
                         transactionType = [NSNumber numberWithInt:1];
                     }
                     else if([[debit0GrpName lowercaseString] isEqual:@"assets"]&&[[credit0GrpName lowercaseString] isEqual:@"assets"])
                     {
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
                     
                     
                     //if emaill is same else
                     
                     
                     if ([userEmail isEqualToString:syncListEmail])
                     {
                         //check for accounts with same grp id and account name.
                         AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                         NSManagedObjectContext *context=[appDelegate managedObjectContext];
                         NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                         NSFetchRequest *request=[[NSFetchRequest alloc]init];
                         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@ AND groupId contains[cd] %@", creditAccountName,creditGrpId];
                         [request setPredicate:predicate];
                         [request setEntity:entityDescr];
                         NSError *error;
                         arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                         
                         //get account id from account name
                         //NSLog(@"user email = %@",[userDef valueForKey:@"userEmail"]);
                         if(arrData.count==0)
                         {
                             [self refreshAccounts];
                             // create a new account with max account id
                             NSMutableArray *arrAccountId = [NSMutableArray array];
                             
                             
                             for(Accounts *accounts in arrAccounts)
                             {
                                 [arrAccountId addObject:accounts.accountId];
                             }
                             
                             int max = [[arrAccountId valueForKeyPath:@"@max.intValue"] intValue];
                             max++;
                             NSManagedObject *newAccount;
                             newAccount = [NSEntityDescription insertNewObjectForEntityForName:@"Accounts" inManagedObjectContext:context];
                             NSString *openingBalanceNum = @"0";
                             NSNumber *openingBalance = [NSNumber numberWithInt:[openingBalanceNum floatValue]];
                             NSNumber *accountId = [NSNumber numberWithInt:max];
                             
                             [newAccount setValue:creditAccountName forKeyPath:@"accountName"];
                             [newAccount setValue:syncListEmail forKeyPath:@"emailId"];
                             [newAccount setValue:creditGrpId forKeyPath:@"groupId"];
                             [newAccount setValue:openingBalance forKeyPath:@"openingBalance"];
                             [newAccount setValue:@"" forKeyPath:@"uniqueName"];
                             [newAccount setValue:accountId forKeyPath:@"accountId"];
                            // NSLog(@"newAccount %@",newAccount);
                             [context insertObject:newAccount];
                             [context save:&error];
                             creditAccountId = [NSString stringWithFormat:@"%@",accountId];
                             [self refreshAccounts];
                         }
                         else{
                             Accounts *accountsCre = arrData[0];
                             creditAccountId = [NSString stringWithFormat:@"%@",accountsCre.accountId];
                         }
                     }
                     else
                     {
                         //make entries as it is
                         creditAccountId = creditAccountName;
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
                     
                     
                     //set condition for inserting account name or account id
                     if ([userEmail isEqualToString:syncListEmail])
                     {
                         [self refreshAccounts];
                         AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
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
                             [newAccount setValue:syncListEmail forKeyPath:@"emailId"];
                             [newAccount setValue:debitGrpId forKeyPath:@"groupId"];
                             [newAccount setValue:openingBalance forKeyPath:@"openingBalance"];
                             [newAccount setValue:@"" forKeyPath:@"uniqueName"];
                             [newAccount setValue:accountId forKeyPath:@"accountId"];
                             [context insertObject:newAccount];
                             [context save:&error];
                             debitAccountId = [NSString stringWithFormat:@"%@",accountId];
                             [self refreshAccounts];
                         }
                         else{
                             Accounts *accountsDeb = arrData[0];
                             debitAccountId = [NSString stringWithFormat:@"%@",accountsDeb.accountId];
                         }
                     }
                     else
                     {
                         debitAccountId = debitAccountName;
                     }
                     
                 }
                 AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
                 NSManagedObjectContext *context=[appDelegate managedObjectContext];
                 NSError *error = nil;
                 NSManagedObject *newEntry;
                 newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"EntriesInfoTrip" inManagedObjectContext:context];
                 NSString *entryId = [dict valueForKey:@"entryId"];
                 [newEntry setValue:transactionType forKey:@"transactionType"];
                 [newEntry setValue:[dict valueForKey:@"entryDate"] forKey:@"date"];
                 [newEntry setValue:debitAccountId forKey:@"debitAccount"];
                 [newEntry setValue:creditAccountId forKey:@"creditAccount"];
                 [newEntry setValue:[NSNumber numberWithInt:[[dict valueForKey:@"companyId"] intValue]] forKey:@"companyId"];
                 [newEntry setValue:syncListEmail forKey:@"email"];
                 [newEntry setValue:[NSNumber numberWithInt:[amount intValue]] forKey:@"amount"];
                 [newEntry setValue:[NSNumber numberWithInt:[entryId intValue]] forKey:@"entryId"];
                 [newEntry setValue:[NSNumber numberWithInt:selTripId] forKey:@"tripId"];
                 [context insertObject:newEntry];
                 [context save:&error];
             }
             [self getAllEtries];
         }];
        //sync code END
        
        [self performSegueWithIdentifier:@"summaryIdentifier" sender:nil];
        
    }
    else{
        NSString *pagetype = [[NSUserDefaults standardUserDefaults]valueForKey:@"firstPageType"];

        UIViewController *presentingVC = [self presentingViewController];
        //NSLog(@"Tapped item at index %lu",(unsigned long)index);
        if(indexPath.row == 1){
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
            SettingsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            vc.globalCompanyId = [self.companies.companyId intValue];
            vc.globalCompanyName = self.companies.companyName;
            vc.companies = self.companies;

            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            //navController.navigationBarHidden =YES;
            [self dismissViewControllerAnimated:NO completion:
             ^{
                 [presentingVC presentViewController:navController animated:YES completion:nil];
             }];
        }

        if (indexPath.row == 2) {

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
        if(indexPath.row == 4){
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstPageCompany"]) {
                [self dismissViewControllerAnimated:NO completion:
                 ^{
                     [presentingVC dismissViewControllerAnimated:YES completion:nil];
                 }];
            }
            else{
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UserHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"UserHomeVC"];
                UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
                navController.navigationBarHidden =NO;
                [self presentViewController:navController animated:YES completion:NULL];
            }
        }
        if (indexPath.row == 3) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
            PersonalHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"PersonalHomeVC"];
            vc.companies =self.companies;
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            navController.navigationBarHidden =YES;
            //NSString *pagetype = [[NSUserDefaults standardUserDefaults]valueForKey:@"firstPageType"];

//            if(![pagetype isEqual:@"summary"]){
//                [self dismissViewControllerAnimated:YES completion:nil];
//            }
//            else{
            if([pagetype isEqual:@"transaction"]){
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else{
                [self dismissViewControllerAnimated:NO completion:
                 ^{
                     [presentingVC presentViewController:navController animated:YES completion:nil];
                 }];

            }
                        //   }
        }
        
        
        
        [tableView dismisWithIndexPath:indexPath];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:tableViewTrips]){
        return 50;
    }
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableView isEqual:tableViewTrips]){
        return arrTableData.count;

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
    if([tableView isEqual:tableViewTrips]){
        
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableViewTrips dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        TripInfo *trip = arrTableData[indexPath.row];
        cell.textLabel.text = trip.tripName;
        
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

@end
