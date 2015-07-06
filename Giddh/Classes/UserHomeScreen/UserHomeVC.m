//
//  UserHomeVC.m
//  Giddh
//
//  Created by Admin on 06/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "UserHomeVC.h"
#import "MBProgressHUD.h"
#import "ServiceManager.h"
#import "Companies.h"
#import "CompanyHomeVC.h"
#import "PersonalHomeVC.h"
#import "AppDelegate.h"
#import "TripHomeVC.h"
#import "AppHomeScreeVC.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SummaryViewController.h"
#import "Entries.h"
#import "AppData.h"

@interface UserHomeVC (){
    NSArray *arrEntries;
}

@end

@implementation UserHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    userDef = [NSUserDefaults standardUserDefaults];
    arrTableData = [NSMutableArray array];
    arrEntries = [NSMutableArray array];
    [self getAllEntries];
    NSString *strCurrency = [userDef valueForKey:@"currencyName"];
    if ((strCurrency == (id)[NSNull null]) || (strCurrency.length == 0) || (strCurrency == nil))
    {
        [userDef setValue:@"" forKey:@"currencySymbol"];
        [userDef setValue:@"" forKey:@"currencyName"];
    }
    //[userDef valueForKey:@"currencyName"];
    //set default currency as blank
    self.automaticallyAdjustsScrollViewInsets = NO;
    //self.tableView.tableHeaderView = nil;
    tableViewUser.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //set condition for already logged in user
    NSString *checkAccess = [userDef valueForKey:@"AuthKey"];//[userDef valueForKey:@"userAccessToken"];
    if ((checkAccess.length > 0) && (checkAccess != (id)[NSNull null]) )
    {
        [self.navigationItem setHidesBackButton:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //call API to get accounts list
    [self getLocalCompanies];
    [self getCompanyList];
}

#pragma mark DB Methods
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}


#pragma mark API Methods
-(void) getCompanyList
{
    if( [[AppData sharedData]isInternetAvailable])
    {
        if (arrTableData.count == 0)
        {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"Authenticating";
        }
    }
    
   // NSLog(@"authId = %@",[userDef valueForKey:@"AuthKey"]);
    [[ServiceManager sharedManager] getCompanyListForAuthKey:[userDef valueForKey:@"AuthKey"] andMobile:@"1" withCompletionBlock:^(NSDictionary *responce, NSError *error)
     {
         //NSLog(@"data -> %@",responce);
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         //NSLog(@"response = %@",responce);
         NSString *strStatus = [responce valueForKey:@"status"];
         //NSLog(@"status = %@",strStatus);
         int intStatus = [strStatus intValue];
         
         //if status is Success
         if (intStatus == 1)
         {
             //save data in database
             NSManagedObjectContext *context = [self managedObjectContext];
             
             NSArray *arrAuth = [responce valueForKey:@"data"];
             //NSLog(@"arr auth = %@",arrAuth);
             
             for (NSDictionary *dict in arrAuth)
             {
                 NSNumber *compId = [NSNumber numberWithInt:[[dict valueForKey:@"companyId"] intValue]];
                 NSNumber *compType = [NSNumber numberWithInt:[[dict valueForKey:@"companyType"] intValue]];
                 //NSString *strEmail = [dict valueForKey:@"emailId"];
                 //NSLog(@"email == > %@",strEmail);
                 
                 NSFetchRequest *request = [[NSFetchRequest alloc] init];
                 [request setEntity:[NSEntityDescription entityForName:@"Companies" inManagedObjectContext:context]];
                 
                 NSError *error = nil;
                 NSArray *results = [context executeFetchRequest:request error:&error];
                 
                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId == %@", compId];
                 [request setPredicate:predicate];
                 NSArray *arrData = [results filteredArrayUsingPredicate:predicate].mutableCopy;
                 
                 // add a new company
                 if(arrData.count == 0)
                 {
                     NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Companies" inManagedObjectContext:context];
                     
                     [newDevice setValue:compId forKey:@"companyId"];
                     [newDevice setValue:[dict valueForKey:@"companyName"] forKey:@"companyName"];
                     [newDevice setValue:compType forKey:@"companyType"];
                     [newDevice setValue:[userDef valueForKey:@"userEmail"] forKey:@"emailId"];
                     [newDevice setValue:[dict valueForKey:@"financialYear"] forKey:@"financialYear"];
                     //[context insertObject:newDevice];
                     
                 }
                 else
                 {
                     //Update company
                     Companies *company = [arrData objectAtIndex:0];
                     company.companyName = [dict valueForKey:@"companyName"];
                     company.companyType = compType;
                     company.emailId = [userDef valueForKey:@"userEmail"];
                     company.financialYear = [dict valueForKey:@"financialYear"];
                 }
                 if ((compId != 0) && (compId != (id)[NSNull null]))
                 {
                     [context save:&error];
                 }
             }
             //code END
         }
         else
         {
             NSLog(@"Error");
         }
         
         //fetch updated data from local database
         [self getLocalCompanies];
     }];
    
}

-(void) getLocalCompanies
{
    
    [arrTableData removeAllObjects];
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Companies"];
    arrTableData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
   // NSLog(@"table data => %@",arrTableData);
    [tableViewUser reloadData];
    if(arrTableData.count==0){
        [self performSelector:@selector(forwardToNextScreenIfOnlyAccount) withObject:nil afterDelay:1];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrTableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSManagedObject *dataObj = [arrTableData objectAtIndex:indexPath.row];
    cell.tag = [[dataObj valueForKey:@"companyType"] intValue];
    
    cell.textLabel.text = [dataObj valueForKey:@"companyName"];
    cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
    
    NSString *strRange;
    if (cell.tag == 2)
    {
        NSString *strYear = [dataObj valueForKey:@"financialYear"];
        NSArray *arrDate = [strYear componentsSeparatedByString:@"-"];
        int currentYear = [[arrDate firstObject] intValue];
        strRange = [NSString stringWithFormat:@"%d - %d",currentYear-1,currentYear];
        
    }
    else
    {
        strRange = @"";
    }
    cell.detailTextLabel.text = strRange;
    
    //cell.detailTextLabel.text = [dataObj valueForKey:@"financialYear"];
    //cell.tag = (int)[dataObj valueForKey:@"companyType"];
    
    
    
    //NSLog(@"cell tag == >%d",cellTag);
    return cell;
    
}
-(void)forwardToNextScreenIfOnlyAccount{
    if(arrEntries.count == 0){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
        PersonalHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"PersonalHomeVC"];
        Companies *companies = arrTableData[0];
        [[NSUserDefaults standardUserDefaults]setValue:@"transaction" forKey:@"firstPageType"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstPageCompany"];
        vc.companies =companies;
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        navController.navigationBarHidden =YES;
        [self presentViewController:navController animated:YES completion:NULL];
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"summary" forKey:@"firstPageType"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstPageCompany"];
        UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
        SummaryViewController *vc2 = [sb2 instantiateViewControllerWithIdentifier:@"SummaryViewController"];
        vc2.isFirstTime =YES;
        [[NSUserDefaults standardUserDefaults]setValue:@"summary" forKey:@"firstPageType"];
        
        //vc.globalCompanyId = [self.companies.companyId intValue];
        Companies *companies = arrTableData[0];
        vc2.companies =companies;
        UINavigationController *navController2 = [[UINavigationController alloc]initWithRootViewController:vc2];
        navController2.navigationBarHidden =YES;
        [self presentViewController:navController2 animated:YES completion:nil];
        
    }

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableViewUser cellForRowAtIndexPath:indexPath];
    NSManagedObject *dataObj = [arrTableData objectAtIndex:indexPath.row];
    strCompanyName = [dataObj valueForKey:@"companyName"];
    companyId = [[dataObj valueForKey:@"companyId"] intValue];
    if(cell.tag == 1)
    {
        //personal account home screen
    if(arrEntries.count == 0){
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
            PersonalHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"PersonalHomeVC"];
            Companies *companies = arrTableData[indexPath.row];
           [[NSUserDefaults standardUserDefaults]setValue:@"transaction" forKey:@"firstPageType"];
           [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstPageCompany"];
            vc.companies =companies;
            vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            navController.navigationBarHidden =YES;
            [self presentViewController:navController animated:YES completion:NULL];

       }
        else
        {
            [[NSUserDefaults standardUserDefaults]setValue:@"summary" forKey:@"firstPageType"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstPageCompany"];
            UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
            SummaryViewController *vc2 = [sb2 instantiateViewControllerWithIdentifier:@"SummaryViewController"];
            vc2.isFirstTime =YES;
            [[NSUserDefaults standardUserDefaults]setValue:@"summary" forKey:@"firstPageType"];

            //vc.globalCompanyId = [self.companies.companyId intValue];
            Companies *companies = arrTableData[indexPath.row];
            vc2.companies =companies;
            UINavigationController *navController2 = [[UINavigationController alloc]initWithRootViewController:vc2];
            navController2.navigationBarHidden =YES;
            [self presentViewController:navController2 animated:YES completion:nil];

        }
    }
    else
    {
        //company account home screen
        NSManagedObject *dataObj = [arrTableData objectAtIndex:indexPath.row];
        strGlobalDate = [dataObj valueForKey:@"financialYear"];
        [self performSegueWithIdentifier:@"companyIdentifier" sender:nil];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"companyIdentifier"])
    {
        CompanyHomeVC *homeVC = (CompanyHomeVC *)[segue destinationViewController];
        homeVC.companyName = strCompanyName;
        homeVC.companyId = companyId;
        homeVC.globalDate = strGlobalDate;
        
    }
    if ([[segue identifier] isEqualToString:@"personalIdentifier"])
    {
        PersonalHomeVC *homeVC = (PersonalHomeVC *)[segue destinationViewController];
        homeVC.companyName = strCompanyName;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)logout:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Are you sure to logout?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil] show];
}

-(void) confirmLogout
{
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
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)reportAuthStatus {
    //GIDGoogleUser *googleUser = [[GIDSignIn sharedInstance] currentUser];
    [self refreshUserInfo];
}

// Update the interface elements containing user data to reflect the
// currently signed in user.
- (void)refreshUserInfo {
    if ([GIDSignIn sharedInstance].currentUser.authentication == nil) {
        return;
    }
    
    if (![GIDSignIn sharedInstance].currentUser.profile.hasImage) {
        // There is no Profile Image to be loaded.
        return;
    }
    // Load avatar image asynchronously, in background
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

#pragma mark Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self confirmLogout];
    }
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
-(void)getAllEntries{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrEntries = [[context executeFetchRequest:request error:&error]mutableCopy];
}

@end
