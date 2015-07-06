//
//  homeViewTableVC.m
//  Giddh
//
//  Created by Admin on 16/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "homeViewTableVC.h"
#import "MBProgressHUD.h"
#import "ServiceManager.h"
#import "Companies.h"
#import "CompanyHomeVC.h"
#import "PersonalHomeVC.h"
#import "AppDelegate.h"
#import "TripHomeVC.h"


@implementation homeViewTableVC

-(void)viewDidLoad
{
    userDef = [NSUserDefaults standardUserDefaults];
    arrTableData = [NSMutableArray array];
    
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //self.tableView.tableHeaderView = nil;
    
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
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Authenticating";
   // NSLog(@"authId = %@",[userDef valueForKey:@"AuthKey"]);
    [[ServiceManager sharedManager] getCompanyListForAuthKey:[userDef valueForKey:@"AuthKey"] andMobile:@"1" withCompletionBlock:^(NSDictionary *responce, NSError *error)
    {
        //NSLog(@"data -> %@",responce);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
       // NSLog(@"response = %@",responce);
        NSString *strStatus = [responce valueForKey:@"status"];
       // NSLog(@"status = %@",strStatus);
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
                    
                    //[context insertObject:newDevice];
                    
                }
                else
                {
                    //Update company
                    Companies *company = [arrData objectAtIndex:0];
                    company.companyName = [dict valueForKey:@"companyName"];
                    company.companyType = compType;
                    company.emailId = [userDef valueForKey:@"userEmail"];
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
            //NSLog(@"Error");
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
    
    //NSLog(@"table data => %@",arrTableData);
    [self.tableView reloadData];
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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
     NSManagedObject *dataObj = [arrTableData objectAtIndex:indexPath.row];
    cell.textLabel.text = [dataObj valueForKey:@"companyName"];
    //cell.detailTextLabel.text = [dataObj valueForKey:@"companyId"];
    //cell.tag = (int)[dataObj valueForKey:@"companyType"];
    cell.tag = [[dataObj valueForKey:@"companyType"] intValue];
    //NSLog(@"cell tag == >%d",cellTag);
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSManagedObject *dataObj = [arrTableData objectAtIndex:indexPath.row];
    strCompanyName = [dataObj valueForKey:@"companyName"];
    if(cell.tag == 1)
    {
        //personal account home screen
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
        PersonalHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"PersonalHomeVC"];
        Companies *companies = arrTableData[indexPath.row];
        vc.companies =companies;
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        navController.navigationBarHidden =YES;
        [self presentViewController:navController animated:YES completion:NULL];    }
    else
    {
        //company account home screen
        [self performSegueWithIdentifier:@"companyIdentifier" sender:nil];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"companyIdentifier"])
    {
        CompanyHomeVC *homeVC = (CompanyHomeVC *)[segue destinationViewController];
        homeVC.companyName = strCompanyName;
    }
    if ([[segue identifier] isEqualToString:@"personalIdentifier"])
    {
        PersonalHomeVC *homeVC = (PersonalHomeVC *)[segue destinationViewController];
        homeVC.companyName = strCompanyName;
    }
    
}
- (IBAction)tripAction:(id)sender
{
    TripHomeVC *tvc=[[UIStoryboard storyboardWithName:@"Trip" bundle:nil] instantiateViewControllerWithIdentifier:@"TripHomeVC"]; //or the homeController
    //UINavigationController *navController=[[UINavigationController alloc] initWithRootViewController:tvc];
    //[self presentViewController:navController animated:YES completion:NULL];
    [self.navigationController pushViewController:tvc animated:YES];
    //self.window.rootViewController=tvc;
}
@end
