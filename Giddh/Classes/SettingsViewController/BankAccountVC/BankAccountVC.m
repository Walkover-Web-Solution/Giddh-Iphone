//
//  BankAccountVC.m
//  Giddh
//
//  Created by Admin on 06/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "BankAccountVC.h"
#import "ServiceManager.h"
#import "AppDelegate.h"
#import "ServiceManager.h"
#import "Entries.h"
#import "AppData.h"

@interface BankAccountVC ()
{
    NSArray *arrEntries;
    NSMutableArray *arrAccounts;
}
@end

@implementation BankAccountVC
@synthesize arrAccounts,globalCompanyId,globalCompanyName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrEntries = [NSArray array];
    [self getAllEntries];
 //   [self getAccounts];
    userDef = [NSUserDefaults standardUserDefaults];
    updateFlag = NO;
    tableViewAccounts.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btnSave,btnClear, nil];
    
    CGFloat width = [self.navigationItem.title sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"GothamRounded-Light" size:20 ]}].width;
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width - self.navigationItem.leftBarButtonItem.width, self.navigationController.navigationBar.frame.size.height)];
    tlabel.frame = CGRectMake(0, 0, width,30);
    tlabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:20];
    tlabel.text=self.navigationItem.title;
    tlabel.textColor=[UIColor whiteColor];
    //tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    
    //set toolbar for numberpad
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           nil];
    [numberToolbar sizeToFit];
    txtOpeningBal.inputAccessoryView = numberToolbar;
}
//-(void)getAccounts{
//    AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
//    NSManagedObjectContext *context=[appDelegate managedObjectContext];
//    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
//    NSFetchRequest *request=[[NSFetchRequest alloc]init];
//    [request setEntity:entityDescr];
//    NSError *error;
//    NSArray *temp=[[context executeFetchRequest:request error:&error]mutableCopy];
//    arrAccounts = [NSMutableArray array];
//    for(Accounts *accounts in temp){
//        int accountId =17;
//        if(accounts.accountId >[NSNumber numberWithInt:accountId]){
//            [arrAccounts addObject:accounts];
//        }
//    }
//}
-(void)getAllEntries{
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrEntries = [[context executeFetchRequest:request error:&error]mutableCopy];
}

-(void)cancelNumberPad{
    [txtOpeningBal resignFirstResponder];
    //  numberTextField.text = @"";
}

-(void)getBankAccounts
{
    arrAccounts = [NSMutableArray array];
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Accounts"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId == %@", [NSNumber numberWithInt:3]]];
    NSError *error = nil;
    NSArray *objectArr = [context executeFetchRequest:fetchRequest error:&error];
    
    for (Accounts *objAcc in objectArr)
    {
        [arrAccounts addObject:objAcc];
    }
    
    //return objectArr.count;
    
}


-(BOOL)chaeckIfEntryExistForAccount:(Accounts*)account{
    for(Entries *entry in arrEntries){
        if([entry.creditAccount isEqual:account.accountId]||[entry.debitAccount isEqual:account.accountId] ){
            return YES;
        }
        
    }
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Data Source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return arrAccounts.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PinLogsCell";
    UITableViewCell *cell = [tableViewAccounts dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    Accounts *objectAcc = arrAccounts[indexPath.row];
    cell.textLabel.text = objectAcc.accountName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", objectAcc.openingBalance];
    
    //set font family
    cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    updateFlag = YES;
    Accounts *accObj = arrAccounts[indexPath.row];
    oldAccountName = accObj.accountName;
    oldUniqueName = accObj.uniqueName;
    accountID = accObj.accountId;
    
    if( [accObj.accountName caseInsensitiveCompare:@"cash"] == NSOrderedSame ) {
        // strings are equal except for possibly case
        txtAccountName.enabled = false;
    } else {
        txtAccountName.enabled = true;
    }
    txtAccountName.text = accObj.accountName;
    txtOpeningBal.text = [NSString stringWithFormat:@"%@", accObj.openingBalance];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Accounts * account = arrAccounts[indexPath.row];
    if([[account.accountName lowercaseString] isEqual:@"cash"]){
        return  UITableViewCellEditingStyleNone;
        
    }
    if(account.accountId<[NSNumber numberWithInt:17]){
        return  UITableViewCellEditingStyleNone;
        
    }
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Called when 'delete' button is pushed.
        Accounts * account = arrAccounts[indexPath.row];
        if(![self chaeckIfEntryExistForAccount:account]){
            int grpId = [account.groupId intValue];
            NSString *grpType;
            switch (grpId) {
                case 0:
                    grpType = @"Income";
                    break;
                case 1:
                    grpType = @"Expense";
                    break;
                    
                case 2:
                    grpType = @"Liability";
                    break;
                    
                case 3:
                    grpType = @"Assets";
                    break;
                    
                default:
                    break;
            }
            MBProgressHUD * hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"Processing...";
            
            [[ServiceManager sharedManager]deleteAccountForAuthKey:@"" companyid:[NSString stringWithFormat:@"%@",self.companies.companyId] companyName:self.companies.companyName forAccountName:account.accountName uniqueName:account.uniqueName groupName:grpType withCompletionBlock:^(NSDictionary *responce, NSError *error) {
                //NSLog(@"%@",responce);
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSString *status = [NSString stringWithFormat:@"%@",[responce valueForKey:@"status"]];
                NSString *message =[responce valueForKey:@"message"];
                if([status isEqual:@"0"]){
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Opps!!" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    
                }
                else{
                    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    NSManagedObjectContext *context=[appDelegate managedObjectContext];
                    
                    [context deleteObject:account];
                    
                    NSError *saveError = nil;
                    [context save:&saveError];
                    //[self getAccounts];
                }
                [self getBankAccounts];
                [tableViewAccounts reloadData];
                
            }];
            [tableViewAccounts reloadData];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hold On!!" message:@"Account is used for some entry delete the entry first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveAction:(id)sender
{
    [self.view endEditing:YES];
    if ([txtAccountName.text isEqualToString:@""])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter Account Name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    if ([txtOpeningBal.text isEqualToString:@""])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter Opening Balance" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    //check internet
    
    if ([[AppData sharedData] isInternetAvailable])
    {
        if (updateFlag)
        {
            //update account API
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"Processing..";
            int intBalance = [txtOpeningBal.text intValue];
            int balanceType;
            if (intBalance < 0)
            {
                balanceType = 2;
            } else {
                balanceType = 1;
            }
            
            [[ServiceManager sharedManager ] updateAccountForAuthKey:[userDef valueForKey:@"AuthKey"] companyName:globalCompanyName oldAccountName:oldAccountName oldUniqueName:oldUniqueName accountName:txtAccountName.text uniqueName:oldUniqueName openingBalance:txtOpeningBal.text openingBalanceType:balanceType withCompletionBlock:^(NSDictionary *responce, NSError *error)
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 //NSLog(@"response acc = %@",responce);
                 NSString *strStatus = [responce valueForKey:@"status"];
                 int intStatus = [strStatus intValue];
                 
                 if (intStatus == 1)
                 {
                     //NSArray *arrayData = [responce valueForKey:@"data"];
                     //NSDictionary *dictData = arrayData[0];
                     //NSNumber *accountId = [NSNumber numberWithInt:[[dictData valueForKey:@"accountId"] intValue]];
                     //NSString *uniqueName = [dictData valueForKey:@"uniqueName"];
                     
                     //add data in local DB
                     AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
                     NSManagedObjectContext *context =[appDelegate managedObjectContext];
                     //get company name and email id from local DB
                     //NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                     //NSEntityDescription *entity = [NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                     //[fetchRequest setEntity:entity];
                     
                     //new code START
                     NSFetchRequest *request = [[NSFetchRequest alloc] init];
                     [request setEntity:[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context]];
                     
                     NSError *error = nil;
                     NSArray *results = [context executeFetchRequest:request error:&error];
                     
                     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountId == %@", accountID];
                     [request setPredicate:predicate];
                     NSArray *arrData = [results filteredArrayUsingPredicate:predicate].mutableCopy;
                     
                     // add a new company
                     if(arrData.count == 0)
                     {
                         NSManagedObject *accountObj = [NSEntityDescription insertNewObjectForEntityForName:@"Accounts" inManagedObjectContext:context];
                         [accountObj setValue:accountID forKey:@"accountId"];
                         [accountObj setValue:[NSNumber numberWithInt:3] forKey:@"groupId"];
                         [accountObj setValue:txtAccountName.text forKey:@"accountName"];
                         [accountObj setValue:[userDef valueForKey:@"userEmail"] forKey:@"emailId"];
                         [accountObj setValue:[NSNumber numberWithDouble:[txtOpeningBal.text doubleValue]] forKey:@"openingBalance"];
                         [accountObj setValue:oldUniqueName forKey:@"uniqueName"];
                         
                     }
                     else
                     {
                         //Update Account
                         Accounts *accObj = arrData[0];
                         accObj.accountId = accountID;
                         accObj.accountName = txtAccountName.text;
                         accObj.openingBalance = [NSNumber numberWithDouble:[txtOpeningBal.text doubleValue]];
                         accObj.uniqueName = oldUniqueName;
                         
                     }
                     [context save:&error];
                     //new code ENd
                     
                     txtAccountName.text = @"";
                     txtOpeningBal.text = @"";
                     [self getBankAccounts];
                     [tableViewAccounts reloadData];
                 }
                 else
                 {
                     //NSLog(@"Error message = %@",[responce valueForKey:@"message"]);
                 }
                 
             }];
        }
        else
        {
            //check if bank name already exists
            for (Accounts *objAccounts in arrAccounts)
            {
                // NSLog(@"name = %@",objAccounts.accountName);
                //if ([txtAccountName.text isEqualToString:objAccounts.accountName])
                if( [txtAccountName.text caseInsensitiveCompare:objAccounts.accountName] == NSOrderedSame )
                {
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Bank Name %@ already exists",objAccounts.accountName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [av show];
                    return;
                }
            }
            
            //add account API
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"Processing..";
            int intBalance = [txtOpeningBal.text intValue];
            int balanceType;
            if (intBalance < 0)
            {
                balanceType = 2;
            } else {
                balanceType = 1;
            }
            [[ServiceManager sharedManager] addAccountForAuthKey:[userDef valueForKey:@"AuthKey"] andCompanyId:globalCompanyId companyName:globalCompanyName groupName:@"Assets" accountName:txtAccountName.text uniqueName:@"" openingBalance:txtOpeningBal.text openingBalanceType:balanceType withCompletionBlock:^(NSDictionary *responce, NSError *error)
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 //NSLog(@"response acc = %@",responce);
                 NSString *strStatus = [responce valueForKey:@"status"];
                 int intStatus = [strStatus intValue];
                 
                 if (intStatus == 1)
                 {
                     NSArray *arrData = [responce valueForKey:@"data"];
                     NSDictionary *dictData = arrData[0];
                     NSNumber *accountId = [NSNumber numberWithInt:[[dictData valueForKey:@"accountId"] intValue]];
                     NSString *uniqueName = [dictData valueForKey:@"uniqueName"];
                     
                     //add data in local DB
                     AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
                     NSManagedObjectContext *context =[appDelegate managedObjectContext];
                     
                     //get company name and email id from local DB
                     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                     NSEntityDescription *entity = [NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                     [fetchRequest setEntity:entity];
                     
                     //insert entry in tripInfo table
                     NSManagedObject *accountObj = [NSEntityDescription insertNewObjectForEntityForName:@"Accounts" inManagedObjectContext:context];
                     [accountObj setValue:accountId forKey:@"accountId"];
                     [accountObj setValue:[NSNumber numberWithInt:3] forKey:@"groupId"];
                     [accountObj setValue:txtAccountName.text forKey:@"accountName"];
                     [accountObj setValue:[userDef valueForKey:@"userEmail"] forKey:@"emailId"];
                     [accountObj setValue:[NSNumber numberWithDouble:[txtOpeningBal.text doubleValue]] forKey:@"openingBalance"];
                     [accountObj setValue:uniqueName forKey:@"uniqueName"];
                     NSError *error;
                     if (![context save:&error]) {
                         //NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                     }
                     txtAccountName.text = @"";
                     txtOpeningBal.text = @"";
                     [self getBankAccounts];
                     [tableViewAccounts reloadData];
                 }
                 else
                 {
                     //NSLog(@"Error message = %@",[responce valueForKey:@"message"]);
                 }
             }];
        }
        [tableViewAccounts reloadData];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Internet not Available" message:@"Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil] show];
    }
    
    //hit API to add/ update account details
    
}

- (IBAction)clearTextAction:(id)sender
{
    txtAccountName.text = @"";
    txtOpeningBal.text = @"";
    updateFlag = NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
