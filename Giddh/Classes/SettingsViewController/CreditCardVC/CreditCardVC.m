//
//  CreditCardVC.m
//  Giddh
//
//  Created by Admin on 07/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "CreditCardVC.h"
#import "ServiceManager.h"
#import "AppDelegate.h"
#import "AppData.h"
#import "Entries.h"

@interface CreditCardVC ()
{
    NSArray *arrEntries;
    NSMutableArray *arrAccounts;
}

@end

@implementation CreditCardVC
@synthesize arrAccounts,globalCompanyId,globalCompanyName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    userDef = [NSUserDefaults standardUserDefaults];
    
    [self getAllEntries];
    updateFlag = NO;
    tableViewCredit.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btnSave,btnClear, nil];
    
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

-(void)cancelNumberPad{
    [txtOpeningBal resignFirstResponder];
    //  numberTextField.text = @"";
}

-(void)getAllEntries{
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrEntries = [[context executeFetchRequest:request error:&error]mutableCopy];
}

-(void) getCardCount
{
    arrAccounts = [NSMutableArray array];
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Accounts"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId == %@ AND accountName != %@", [NSNumber numberWithInt:2],@"Loan"]];
    NSError *error = nil;
    NSArray *objectArr = [context executeFetchRequest:fetchRequest error:&error];
    for (Accounts *objAcc in objectArr)
    {
        [arrAccounts addObject:objAcc];
    }
   // return objectArr.count;
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
    UITableViewCell *cell = [tableViewCredit dequeueReusableCellWithIdentifier:cellIdentifier];
    
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
    accountID = accObj.accountId;
    oldUniqueName = accObj.uniqueName;
    txtCreditName.text = accObj.accountName;
    txtOpeningBal.text = [NSString stringWithFormat:@"%@", accObj.openingBalance];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    Accounts * account = arrAccounts[indexPath.row];
    if([[account.accountName lowercaseString] isEqual:@"cash"]){
        return  UITableViewCellEditingStyleNone;
        
    }
    if(account.accountId<[NSNumber numberWithInt:17]){
        return  UITableViewCellEditingStyleNone;
        
    }
     */
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
            
            [[ServiceManager sharedManager]deleteAccountForAuthKey:@"" companyid:[NSString stringWithFormat:@"%d",globalCompanyId] companyName:globalCompanyName forAccountName:account.accountName uniqueName:account.uniqueName groupName:grpType withCompletionBlock:^(NSDictionary *responce, NSError *error) {
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
                [self getCardCount];
                [tableViewCredit reloadData];
                
            }];
            [tableViewCredit reloadData];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hold On!!" message:@"Account is used for some entry delete the entry first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

-(BOOL)chaeckIfEntryExistForAccount:(Accounts*)account{
    for(Entries *entry in arrEntries){
       
        if([entry.creditAccount isEqual:account.accountId]||[entry.debitAccount isEqual:account.accountId] ){
            return YES;
        }
        
    }
    return NO;
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
    if ([txtCreditName.text isEqualToString:@""])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter Credit Card Name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
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
        //hit API to add/ update account details
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
            
            [[ServiceManager sharedManager ] updateAccountForAuthKey:[userDef valueForKey:@"AuthKey"] companyName:globalCompanyName oldAccountName:oldAccountName oldUniqueName:oldUniqueName accountName:txtCreditName.text uniqueName:oldUniqueName openingBalance:txtOpeningBal.text openingBalanceType:balanceType withCompletionBlock:^(NSDictionary *responce, NSError *error)
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
                         [accountObj setValue:[NSNumber numberWithInt:2] forKey:@"groupId"];
                         [accountObj setValue:txtCreditName.text forKey:@"accountName"];
                         [accountObj setValue:[userDef valueForKey:@"userEmail"] forKey:@"emailId"];
                         [accountObj setValue:[NSNumber numberWithDouble:[txtOpeningBal.text doubleValue]] forKey:@"openingBalance"];
                         [accountObj setValue:oldUniqueName forKey:@"uniqueName"];
                         
                     }
                     else
                     {
                         //Update Account
                         Accounts *accObj = arrData[0];
                         accObj.accountId = accountID;
                         accObj.accountName = txtCreditName.text;
                         accObj.openingBalance = [NSNumber numberWithDouble:[txtOpeningBal.text doubleValue]];
                         accObj.uniqueName = oldUniqueName;
                         
                     }
                     [context save:&error];
                     //new code ENd
                     
                     txtCreditName.text = @"";
                     txtOpeningBal.text = @"";
                     [self getCardCount];
                     [tableViewCredit reloadData];
                 }
                 /*
                 if (intStatus == 1)
                 {
                     NSArray *arrData = [responce valueForKey:@"data"];
                     NSDictionary *dictData = arrData[0];
                     NSNumber *accountId = [NSNumber numberWithInt:[[dictData valueForKey:@"accountId"] intValue]];
                     NSString *uniqueName = [dictData valueForKey:@"uniqueName"];
                     
                     //add data in local DB
                     AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
                     NSManagedObjectContext *context =[appDelegate managedObjectContext];
                     
                     //get company name and email id from local DB
                     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                     NSEntityDescription *entity = [NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                     [fetchRequest setEntity:entity];
                     
                     //insert entry in tripInfo table
                     NSManagedObject *accountObj = [NSEntityDescription insertNewObjectForEntityForName:@"Accounts" inManagedObjectContext:context];
                     [accountObj setValue:accountId forKey:@"accountId"];
                     [accountObj setValue:[NSNumber numberWithInt:2] forKey:@"groupId"];
                     [accountObj setValue:txtCreditName.text forKey:@"accountName"];
                     [accountObj setValue:[userDef valueForKey:@"userEmail"] forKey:@"emailId"];
                     [accountObj setValue:[NSNumber numberWithDouble:[txtOpeningBal.text doubleValue]] forKey:@"openingBalance"];
                     [accountObj setValue:uniqueName forKey:@"uniqueName"];
                     NSError *error;
                     if (![context save:&error]) {
                         NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                     }
                     [tableViewCredit reloadData];
                 }
                  */
                 else
                 {
                    // NSLog(@"Error message = %@",[responce valueForKey:@"message"]);
                 }
                 
             }];
        }
        else
        {
            //check if bank name already exists
            for (Accounts *objAccounts in arrAccounts)
            {
               // NSLog(@"name = %@",objAccounts.accountName);
                //if ([txtCreditName.text isEqualToString:objAccounts.accountName])
                if( [txtCreditName.text caseInsensitiveCompare:objAccounts.accountName] == NSOrderedSame )
                {
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Credit Card %@ already exists",objAccounts.accountName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
            [[ServiceManager sharedManager] addAccountForAuthKey:[userDef valueForKey:@"AuthKey"] andCompanyId:globalCompanyId companyName:globalCompanyName groupName:@"Liability" accountName:txtCreditName.text uniqueName:@"" openingBalance:txtOpeningBal.text openingBalanceType:balanceType withCompletionBlock:^(NSDictionary *responce, NSError *error)
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
                     AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                     NSManagedObjectContext *context =[appDelegate managedObjectContext];
                     
                     //get company name and email id from local DB
                     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                     NSEntityDescription *entity = [NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                     [fetchRequest setEntity:entity];
                     
                     //insert entry in tripInfo table
                     NSManagedObject *accountObj = [NSEntityDescription insertNewObjectForEntityForName:@"Accounts" inManagedObjectContext:context];
                     [accountObj setValue:accountId forKey:@"accountId"];
                     [accountObj setValue:[NSNumber numberWithInt:2] forKey:@"groupId"];
                     [accountObj setValue:txtCreditName.text forKey:@"accountName"];
                     [accountObj setValue:[userDef valueForKey:@"userEmail"] forKey:@"emailId"];
                     [accountObj setValue:[NSNumber numberWithDouble:[txtOpeningBal.text doubleValue]] forKey:@"openingBalance"];
                     [accountObj setValue:uniqueName forKey:@"uniqueName"];
                     NSError *error;
                     if (![context save:&error]) {
                        // NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                     }
                     txtCreditName.text = @"";
                     txtOpeningBal.text = @"";
                     [self getCardCount];
                     [tableViewCredit reloadData];
                 }
                 else
                 {
                     //NSLog(@"Error message = %@",[responce valueForKey:@"message"]);
                 }
             }];
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Internet not Available" message:@"Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil] show];
    }
    //[tableViewCredit reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)clearTextAction:(id)sender
{
    txtCreditName.text = @"";
    txtOpeningBal.text = @"";
    updateFlag = NO;
}
@end
