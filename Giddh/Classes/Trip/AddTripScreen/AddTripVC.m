//
//  AddTripVC.m
//  Giddh
//
//  Created by Admin on 21/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AddTripVC.h"
#import "Person.h"
#import "MBProgressHUD.h"

#import "Companies.h"
#import "TripHomeVC.h"
#import "AddressBookVC.h"
#import "AppData.h"

@interface AddTripVC ()

@end

@implementation AddTripVC
@synthesize arrSelectedPersons,editFlag,strEditTripName,intEditTripId,intCompanyId,ifTripOwner;

- (void)viewDidLoad
{
    arrSelectedPersons = [NSMutableArray array];
    arrTableData = [NSMutableArray array];
    [super viewDidLoad];
    userDef = [NSUserDefaults standardUserDefaults];
    
    if (editFlag)
    {
        self.navigationItem.title = @"Edit Trip";
        txtTripName.text = strEditTripName;
        [btnSaveEditTrip setTitle:@"Save Changes" forState:UIControlStateNormal];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"arr sel = > %@",arrSelectedPersons);
    if (ifTripOwner == 0)
    {
        tableViewPerson.hidden = YES;
        txtEmail.hidden = YES;
        btnSelectUser.hidden = YES;
    }
    else
    {
        if (arrSelectedPersons.count == 0 && arrTableData.count == 0)
        {
            tableViewPerson.hidden = YES;
        }
        else
        {
            if (arrSelectedPersons.count > 0)
            {
                [arrTableData addObjectsFromArray:arrSelectedPersons];
                [arrSelectedPersons removeAllObjects];
            }
            [tableViewPerson reloadData];
            tableViewPerson.hidden = NO;
        }
        //remove extra separators from tableview
        tableViewPerson.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    
    //header view
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,30)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,300,30)];
    [headerView addSubview:imageView];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,300,30)];
    labelView.text = @"Sharing trip with:";
    labelView.textAlignment = NSTextAlignmentCenter;
    labelView.font = [UIFont fontWithName:@"GothamRounded-Light" size:18];
    [headerView addSubview:labelView];
    tableViewPerson.tableHeaderView = headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return arrTableData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableViewPerson dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Person *personObj = arrTableData[indexPath.row];
    if (personObj.name.length == 0)
    {
        cell.textLabel.hidden = YES;
    } else {
        cell.textLabel.hidden = NO;
    }
    
    if ([personObj.name isEqual:personObj.emailId])
    {
        cell.detailTextLabel.hidden = YES;
    }
    cell.textLabel.text = personObj.name;
    cell.detailTextLabel.text = personObj.emailId;
    //set font family
    cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:17];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
    return cell;
    
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [arrTableData removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"afterEditIdentifier"])
    {
        //TripHomeVC *vc = [];
    }
    if (editFlag)
    {
        if ([[segue identifier] isEqualToString:@"addressBookIdentifier"])
        {
            AddressBookVC *avc = [segue destinationViewController];
            avc.checkEditFlag = true;
        }
    }
    
}


-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)createTripAction:(id)sender
{
    
    if ([txtTripName.text isEqualToString:@""])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter Trip Name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
    if ([[AppData sharedData] isInternetAvailable])
    {
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText=@"Saving";
        [self performSelector:@selector(manageTrip) withObject:nil afterDelay:1.0];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Internet not Available" message:@"Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show] ;
    }
    
    
    
    
}

-(void) manageTrip
{
    //Check if Add Trip or Edit Trip
    if (editFlag)
    {
        
        
        //add new share email ids for trip
        //hit second API of saving email ids
        if (arrTableData.count > 0)
        {
            for (Person *personObj in arrTableData)
            {
                [[ServiceManager sharedManager] shareTripForAuthKey:[userDef valueForKey:@"AuthKey"] companyId:[NSString stringWithFormat:@"%d",intCompanyId] andTripId:intEditTripId andEmail:personObj.emailId withCompletionBlock:^(NSDictionary *responce, NSError *error)
                 {
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                    // NSLog(@"response = %@",responce);
                     NSString *strStatus = [responce valueForKey:@"status"];
                     //NSLog(@"status = %@",strStatus);
                     int intStatus = [strStatus intValue];
                     
                     if (intStatus == 1)
                     {
                         //NSArray *arrData = [responce valueForKey:@"data"];
                         //NSDictionary *dictData = arrData[0];
                         NSNumber *tripOwnerShare = [NSNumber numberWithInt:0];
                         NSNumber *tripId = [NSNumber numberWithInt:intEditTripId];
                         
                         //insert enrty in Trip Share Table
                         NSManagedObject *tripShareObj =[NSEntityDescription insertNewObjectForEntityForName:@"TripShare" inManagedObjectContext:[self managedObjectContext]];
                         [tripShareObj setValue:tripId forKey:@"tripId"];
                         [tripShareObj setValue:personObj.emailId forKey:@"emailId"];
                         [tripShareObj setValue:tripOwnerShare forKey:@"owner"];
                         [tripShareObj setValue:strCompName forKey:@"companyName"];
                         NSError *error2;
                         if (![[self managedObjectContext] save:&error2]) {
                            // NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                         }
                     }
                     else
                     {
                         /*
                          UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[responce valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                          [av show];
                          return;
                          */
                         //NSLog(@"Error= %@ and response = %@",error,responce);
                     }
                 }];
            }
        }
        
        //hit API to edit trip name
        //MBProgressHUD *hud2=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //hud2.labelText=@"Saving";
        [[ServiceManager sharedManager] editTripForAuthKey:[userDef valueForKey:@"AuthKey"] andTripName:txtTripName.text andTripId:intEditTripId andCompanyId:intCompanyId withCompletionBlock:^(NSDictionary *responce, NSError *error)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             //NSLog(@"response = %@",responce);
             NSString *strStatus = [responce valueForKey:@"status"];
             //NSLog(@"status = %@",strStatus);
             int intStatus = [strStatus intValue];
             
             if (intStatus == 1)
             {
                 //update trip info table
                 NSManagedObjectContext *context = [self managedObjectContext];
                 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
                 
                 //Apply filter condition
                 [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:intEditTripId]]];
                 
                 //NSArray *tempArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                 NSArray *objectArr = [context executeFetchRequest:fetchRequest error:&error];
                 NSManagedObject *tempObject = [objectArr objectAtIndex:0];
                 
                 [tempObject setValue:txtTripName.text forKey:@"tripName"];
                 
                 //[context save:&error];
                 
                 NSError *error = nil;
                 // Save the object to persistent store
                 if (![context save:&error]) {
                     //NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                 }
                 [self.navigationController popViewControllerAnimated:YES];
             }
             else
             {
                 //NSLog(@"Error edit trip = %@",error);
             }
             //
         }];
        
        //[self performSegueWithIdentifier:@"afterEditIdentifier" sender:nil];
        
        
    }
    else
    {
        //create new object
        //MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //hud.labelText=@"Saving";
        
        NSString *compId = [NSString stringWithFormat:@"%d",intCompanyId];
        //hit API
        [[ServiceManager sharedManager] createTripForAuthKey:[userDef valueForKey:@"AuthKey"] andTripName:txtTripName.text andCompanyId:compId withCompletionBlock:^(NSDictionary *responce, NSError *error)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             //NSLog(@"response = %@",responce);
             NSString *strStatus = [responce valueForKey:@"status"];
             //NSLog(@"status = %@",strStatus);
             int intStatus = [strStatus intValue];
             
             if (intStatus == 1)
             {
                 NSArray *arrData = [responce valueForKey:@"data"];
                 NSDictionary *dictData = arrData[0];
                 NSNumber *compId = [NSNumber numberWithInt:[[dictData valueForKey:@"companyId"] intValue]];
                 NSNumber *tripId = [NSNumber numberWithInt:[[dictData valueForKey:@"tripId"] intValue]];
                 NSNumber *tripOwner = [NSNumber numberWithInt:1];
                 //int intCompanyId = [[dictData valueForKey:@"companyId"] intValue];
                 //int intTripId = [[dictData valueForKey:@"tripId"] intValue];
                 NSString *strTripName = [dictData valueForKey:@"tripName"];
                 
                 //add data in local DB
                 NSManagedObjectContext *context = [self managedObjectContext];
                 
                 //get company name and email id from local DB
                 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                 NSEntityDescription *entity = [NSEntityDescription entityForName:@"Companies" inManagedObjectContext:[self managedObjectContext]];
                 [fetchRequest setEntity:entity];
                 
                 //Add following method to your code. this will help you to get desired result.
                 [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"companyId == %@", [NSNumber numberWithInt:intCompanyId]]]; //hardcoded temporarily
                 
                 NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
                 
                 for (Companies *comp in fetchedObjects) {
                     strCompName = comp.companyName;
                     strCompEmail = comp.emailId;
                 }
                 
                 //insert entry in tripInfo table
                 NSManagedObject *tripObj = [NSEntityDescription insertNewObjectForEntityForName:@"TripInfo" inManagedObjectContext:[self managedObjectContext]];
                 [tripObj setValue:compId forKey:@"companyId"];
                 [tripObj setValue:tripId forKey:@"tripId"];
                 [tripObj setValue:tripOwner forKey:@"owner"];
                 [tripObj setValue:strTripName forKey:@"tripName"];
                 NSError *error;
                 if (![[self managedObjectContext] save:&error]) {
                     //NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                 }
                 
                 //insert enrty in tripShare table
                 NSManagedObject *tripShareObj =[NSEntityDescription insertNewObjectForEntityForName:@"TripShare" inManagedObjectContext:[self managedObjectContext]];
                 [tripShareObj setValue:tripId forKey:@"tripId"];
                 [tripShareObj setValue:strCompEmail forKey:@"emailId"];
                 [tripShareObj setValue:tripOwner forKey:@"owner"];
                 [tripShareObj setValue:strCompName forKey:@"companyName"];
                 NSError *error2;
                 if (![[self managedObjectContext] save:&error2]) {
                    // NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                 }
                 
                 //hit second API of saving email ids
                 if (arrTableData.count > 0)
                 {
                     for (Person *personObj in arrTableData)
                     {
                         [[ServiceManager sharedManager] shareTripForAuthKey:[userDef valueForKey:@"AuthKey"] companyId:[NSString stringWithFormat:@"%d",intCompanyId] andTripId:[tripId intValue] andEmail:personObj.emailId withCompletionBlock:^(NSDictionary *responce, NSError *error)
                          {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              //NSLog(@"response = %@",responce);
                              NSString *strStatus = [responce valueForKey:@"status"];
                              //NSLog(@"status = %@",strStatus);
                              int intStatus = [strStatus intValue];
                              
                              if (intStatus == 1)
                              {
                                  //NSArray *arrData = [responce valueForKey:@"data"];
                                  //NSDictionary *dictData = arrData[0];
                                  NSNumber *tripOwnerShare = [NSNumber numberWithInt:0];
                                  
                                  //insert enrty in Trip Share Table
                                  NSManagedObject *tripShareObj =[NSEntityDescription insertNewObjectForEntityForName:@"TripShare" inManagedObjectContext:[self managedObjectContext]];
                                  [tripShareObj setValue:tripId forKey:@"tripId"];
                                  [tripShareObj setValue:personObj.emailId forKey:@"emailId"];
                                  [tripShareObj setValue:tripOwnerShare forKey:@"owner"];
                                  //[tripShareObj setValue:strCompName forKey:@"companyName"];
                                  [tripShareObj setValue:personObj.emailId forKey:@"companyName"];
                                  NSError *error2;
                                  if (![[self managedObjectContext] save:&error2]) {
                                      //NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                                  }
                              }
                              else
                              {
                                  /*
                                   UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[responce valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                   [av show];
                                   return;
                                   */
                                  //NSLog(@"Error");
                              }
                          }];
                     }
                     
                 }
                 
                 UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Trip Created Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 [av show];
                 //redirect on trip list screen
                 [self.navigationController popViewControllerAnimated:YES];
             }
             else
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[responce valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 [av show];
                 return;
             }
             
         }];
    }
    
}


#pragma mark DB Methods
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark Text Field Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:txtEmail])
    {
        //check valid email id
        BOOL check = [self NSStringIsValidEmail:txtEmail.text];
        if (check)
        {
            //add email in person table view
            Person *newEmail = [[Person alloc]init];
            newEmail.name = txtEmail.text;
            newEmail.emailId = txtEmail.text;
            [arrTableData addObject:newEmail];
            tableViewPerson.hidden = NO;
            [tableViewPerson reloadData];
            txtEmail.text = nil;
            [textField resignFirstResponder];
        }
        else
        {
            //show error message
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Email Id" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
            [textField becomeFirstResponder];
        }
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}
@end
