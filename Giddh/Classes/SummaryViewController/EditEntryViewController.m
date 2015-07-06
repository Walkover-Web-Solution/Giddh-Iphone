//
//  EditEntryViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 15/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "EditEntryViewController.h"
#import "AppDelegate.h"
#import "Accounts.h"
#import "TripInfo.h"
#import "ServiceManager.h"
#import "EntriesInfoTrip.h"
@interface EditEntryViewController (){
    NSArray *arrEntries;
    
    __weak IBOutlet UIButton *btnTrip;
    __weak IBOutlet UIButton *btnAcoount2;
    __weak IBOutlet UIButton *btnAccount1;
    __weak IBOutlet UIButton *btnDate;
    __weak IBOutlet UIView *viewPicker;
    Entries *editEntry;
    EntriesInfoTrip *editEntryInfo;
    Accounts * forAccount;
    Accounts * viaAccount;
    NSNumber *forAccountId;
    NSNumber *viaAccountId;
    TripInfo *selectedTripInfo;
    TripInfo *preTripInfo;
    NSArray *arrAccounts;
    NSArray *arrTripInfo;
    NSArray *arrEntriesInfoTrip;
    __weak IBOutlet UITextField *txtDescription;
    __weak IBOutlet UITextField *txtAmount;
    NSMutableArray *arrPickerData;
    NSString *selectedType;
    BOOL isTripDoneEmpty;
    BOOL isInitialyNoTrip;
}
- (IBAction)dateButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)updateButtonAction:(id)sender;
- (IBAction)account1ButtonAction:(id)sender;
- (IBAction)account2ButtonAction:(id)sender;
- (IBAction)tripButtonAction:(id)sender;
- (IBAction)removeTripButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonAction;
@property (weak, nonatomic) IBOutlet UIButton *DoneButtonAction;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)DoneButtonAction:(id)sender;

@end

@implementation EditEntryViewController
@synthesize tripSummaryFlag;

- (void)viewDidLoad {
    [super viewDidLoad];
    arrEntries = [NSArray array];
    arrPickerData = [NSMutableArray array];
    self.pickerView.hidden = YES;
    arrEntriesInfoTrip = [NSArray array];
    
    arrAccounts = [NSArray array];
    arrTripInfo = [NSArray array];
    btnTrip.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btnTrip.layer.borderWidth = .5f;
    btnAccount1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btnAccount1.layer.borderWidth = .5f;
    btnAcoount2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btnAcoount2.layer.borderWidth = .5f;
    btnDate.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btnDate.layer.borderWidth = .5f;
    
    [self getAccounts];
    [self getAllEntries];
    [self getAllEntriesInfoTrip];
    [self getEntryForObjId];
    [self getTrip];
    
    
    [self feedAllEntryDataInForm];
    self.datePicker.datePickerMode= UIDatePickerModeDate;
    viewPicker.hidden = YES;
    
    // set picker max and min date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.year = -1;
    self.datePicker.maximumDate = [NSDate date];
    self.datePicker.minimumDate = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    
    // Do any additional setup after loading the view.
}

-(void)getAllEntries{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrEntries = [[context executeFetchRequest:request error:&error]mutableCopy];
}
-(void)getAllEntriesInfoTrip{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"EntriesInfoTrip" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrEntriesInfoTrip = [[context executeFetchRequest:request error:&error]mutableCopy];
}
-(void)getEntryForObjId{
    // add entry in delete entry table
    if (tripSummaryFlag)
    {
        for(EntriesInfoTrip * entries in arrEntriesInfoTrip){
            if([entries.objectID isEqual:self.objId])
            {
                editEntryInfo = entries;
            }
        }
    }
    else
    {
        for(Entries * entries in arrEntries){
            
            if([entries.objectID isEqual:self.objId]){
                editEntry= entries;
            }
        }
    }
    
}

-(void)feedAllEntryDataInForm
{
    
    if (!editEntryInfo)
    {
        //edit screen for summary
        NSString *transctionType = [NSString stringWithFormat:@"%@",editEntry.transactionType];
        if([transctionType isEqualToString:@"0"]){
            forAccount =[self getAccountForAccountId:editEntry.creditAccount];
            viaAccount =[self getAccountForAccountId:editEntry.debitAccount];
        }
        else{
            forAccount =[self getAccountForAccountId:editEntry.debitAccount];
            viaAccount =[self getAccountForAccountId:editEntry.creditAccount];
        }
        forAccountId = forAccount.groupId;
        viaAccountId = viaAccount.groupId;
        
        [btnAccount1 setTitle:forAccount.accountName forState:UIControlStateNormal];
        [btnAcoount2 setTitle:viaAccount.accountName forState:UIControlStateNormal];
        [btnDate setTitle:editEntry.date forState:UIControlStateNormal];
        txtAmount.text =[NSString stringWithFormat:@"%@", editEntry.amount];
        NSNumber *tripId;
        
        if([editEntry.entryId isEqual:0]){
            // fetch the entriesTripInfoObj using the objId
            for(EntriesInfoTrip * entriesInfo in arrEntriesInfoTrip){
                NSURL * entriesObjIdUrl =[NSURL URLWithString:editEntry.entriesInfoObjId];
                NSURL *entriesInfoObjId = [[entriesInfo objectID] URIRepresentation];
                if([entriesInfoObjId isEqual:entriesObjIdUrl]){
                    tripId = entriesInfo.tripId;
                }
            }
        }
        else{
            //fetch the entriesTripInfoObj using the entry id
            for(EntriesInfoTrip * entriesInfo in arrEntriesInfoTrip){
                if([entriesInfo.entryId isEqual:editEntry.entryId]){
                    tripId = entriesInfo.tripId;
                    
                }
            }
            
        }
        isInitialyNoTrip=YES;
        for(TripInfo *tripInfo in arrTripInfo){
            //NSLog(@"%@",editEntry.tripId);
            if([tripInfo.tripId isEqual:tripId]){
                [btnTrip setTitle:tripInfo.tripName forState:UIControlStateNormal];
                preTripInfo = tripInfo;
                isInitialyNoTrip = NO;
            }
        }
    }
    else
    {
        NSString *transctionType = [NSString stringWithFormat:@"%@",editEntryInfo.transactionType];
        if([transctionType isEqualToString:@"0"])
        {
            forAccount =[self getAccountForAccountId:[NSNumber numberWithInt:[editEntryInfo.creditAccount intValue]]];
            viaAccount =[self getAccountForAccountId:[NSNumber numberWithInt:[editEntryInfo.debitAccount intValue]]];
        }
        else{
            forAccount =[self getAccountForAccountId:[NSNumber numberWithInt:[editEntryInfo.debitAccount intValue]]];
            viaAccount =[self getAccountForAccountId:[NSNumber numberWithInt:[editEntryInfo.creditAccount intValue]]];
        }
        forAccountId = forAccount.groupId;
        viaAccountId = viaAccount.groupId;
        [btnAccount1 setTitle:forAccount.accountName forState:UIControlStateNormal];
        [btnAcoount2 setTitle:viaAccount.accountName forState:UIControlStateNormal];
        
        //remove time and set date format
        NSArray *arrDateTime = [editEntryInfo.date componentsSeparatedByString:@" "];
        NSString *strDate = arrDateTime[0];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *entryDate = [formatter dateFromString:strDate];
        [formatter setDateFormat:@"dd MMM yyyy"];
        NSString *strNewDate = [formatter stringFromDate:entryDate];
        
        [btnDate setTitle:strNewDate forState:UIControlStateNormal];
        txtAmount.text =[NSString stringWithFormat:@"%@", editEntryInfo.amount];
        NSNumber *tripId;
        
        if([editEntryInfo.entryId isEqual:0]){
            // fetch the entriesTripInfoObj using the objId
            for(EntriesInfoTrip * entriesInfo in arrEntriesInfoTrip){
                NSURL * entriesObjIdUrl =[NSURL URLWithString:(id)editEntryInfo.objectID];
                NSURL *entriesInfoObjId = [[entriesInfo objectID] URIRepresentation];
                if([entriesInfoObjId isEqual:entriesObjIdUrl]){
                    tripId = entriesInfo.tripId;
                }
            }
        }
        else{
            //fetch the entriesTripInfoObj using the entry id
            for(EntriesInfoTrip * entriesInfo in arrEntriesInfoTrip){
                if([entriesInfo.entryId isEqual:editEntryInfo.entryId]){
                    tripId = entriesInfo.tripId;
                    
                }
            }
            
        }
        
        for(TripInfo *tripInfo in arrTripInfo){
            // NSLog(@"%@",editEntryInfo.tripId);
            if([tripInfo.tripId isEqual:editEntryInfo.tripId]){
                [btnTrip setTitle:tripInfo.tripName forState:UIControlStateNormal];
                preTripInfo = tripInfo;
                selectedTripInfo = tripInfo;
            }
        }
    }
    
    
}
-(void)getEntriesInfoTripForTripId:(NSNumber*)tripId{
    
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
-(Accounts*)getAccountForAccountId:(NSNumber*)accountId
{
    //NSLog(@"acc id =%@",accountId);
    for(Accounts *account in arrAccounts)
    {
        //NSLog(@"loop account id = %@",account.accountId);
        if([account.accountId isEqual: accountId]){
            return account;
        }
    }
    return nil;
}
-(void)getAccounts{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrAccounts=[[context executeFetchRequest:request error:&error]mutableCopy];
}

-(void)getTrip{
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"TripInfo" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrTripInfo=[[context executeFetchRequest:request error:&error]mutableCopy];
}

- (IBAction)dateButtonAction:(id)sender
{
    viewPicker.hidden = NO;
    self.pickerView.hidden= YES;
    self.datePicker.hidden = NO;
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updateButtonAction:(id)sender {
    NSString * strArrCredit;
    NSString * strArrDebit;
    NSString *transctionType = [NSString stringWithFormat:@"%@",editEntry.transactionType];
    if([transctionType isEqualToString:@"0"]){
        editEntry.creditAccount = forAccount.accountId;
        editEntry.debitAccount = viaAccount.accountId;
        NSString * creGrpIdStr = [NSString stringWithFormat:@"%@", forAccount.groupId];
        int creGrpId = [creGrpIdStr intValue];
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
        Accounts *debitAccount;
        for (Accounts *accounts in arrAccounts){
            if([accounts.accountId isEqual:viaAccount.accountId ]){
                debitAccount = accounts;
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
        
        strArrCredit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\"}]",forAccount.accountName,txtAmount.text,creGrpType,creGrpType];
        strArrDebit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\"}]",viaAccount.accountName,txtAmount.text,debGrpType,debGrpType];
        
    }
    else{
        NSString * creGrpIdStr = [NSString stringWithFormat:@"%@", forAccount.groupId];
        int creGrpId = [creGrpIdStr intValue];
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
        Accounts *debitAccount;
        for (Accounts *accounts in arrAccounts){
            if([accounts.accountId isEqual:viaAccount.accountId ]){
                debitAccount = accounts;
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
        
        strArrCredit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\"}]",forAccount.accountName,txtAmount.text,creGrpType,creGrpType];
        strArrDebit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\"}]",viaAccount.accountName,txtAmount.text,debGrpType,debGrpType];
        
        editEntry.debitAccount = forAccount.accountId;
        editEntry.creditAccount = viaAccount.accountId;
    }
    
    MBProgressHUD * hud;
    hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (tripSummaryFlag)
    {
        //change date format
        NSString *strDate = btnDate.titleLabel.text;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yyyy"];
        NSDate *entryDate = [formatter dateFromString:strDate];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *strNewDate = [formatter stringFromDate:entryDate];
        
        
        [[ServiceManager sharedManager]updateEntryforAuthKey:@"" andcompanyName:self.companies.companyName forEntryId:[NSString stringWithFormat:@"%@",editEntryInfo.entryId] date:strNewDate description:txtDescription.text mobile:@"1" debit:strArrDebit credit:strArrCredit tripId:preTripInfo.tripId withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            //NSLog(@"%@",responce);
            if([[NSString stringWithFormat:@"%@",[responce valueForKey:@"status"]] isEqual:@"1"]){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSArray *arrData = [responce valueForKey:@"data"];
                NSDictionary *dataDict = [arrData objectAtIndex:0];
                NSString * entryId = [dataDict valueForKey:@"entryId"];
                AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
                
                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                NSString *transctionType = [NSString stringWithFormat:@"%@",editEntryInfo.transactionType];
                if([transctionType isEqualToString:@"0"]){
                    editEntryInfo.creditAccount = [forAccount.accountId stringValue];
                    editEntryInfo.debitAccount = [viaAccount.accountId stringValue];
                    
                }
                else{
                    editEntryInfo.debitAccount = [forAccount.accountId stringValue];
                    editEntryInfo.creditAccount = [viaAccount.accountId stringValue];
                }
                if(![selectedTripInfo isEqual:nil]||![preTripInfo isEqual:nil]){
                    if([editEntryInfo.entryId isEqual:0]){
                        // fetch the entriesTripInfoObj using the objId
                        for(EntriesInfoTrip * entriesInfo in arrEntriesInfoTrip){
                            NSURL * entriesObjIdUrl =[NSURL URLWithString:editEntry.entriesInfoObjId];
                            NSURL *entriesInfoObjId = [[entriesInfo objectID] URIRepresentation];
                            if([entriesInfoObjId isEqual:entriesObjIdUrl]){
                                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                                NSError *error;
                                entriesInfo.date = strNewDate;
                                if([transctionType isEqualToString:@"0"]){
                                    entriesInfo.creditAccount = [forAccount.accountId stringValue];
                                    entriesInfo.debitAccount = [viaAccount.accountId stringValue];
                                }
                                else{
                                    entriesInfo.debitAccount = [forAccount.accountId stringValue];
                                    entriesInfo.creditAccount = [viaAccount.accountId stringValue];
                                }
                                entriesInfo.amount =[NSNumber numberWithInt:[txtAmount.text intValue]];
                                entriesInfo.tripId = selectedTripInfo.tripId;
                                // [context insertObject:editEntry];
                                [context save:&error];
                            }
                        }
                    }
                    else{
                        if(isInitialyNoTrip){
                            if(![preTripInfo isEqual:nil]){
                                
                                NSManagedObjectContext *context=[appDelegate managedObjectContext];
                                NSManagedObject *newEntryInfo;
                                newEntryInfo = [NSEntityDescription
                                                insertNewObjectForEntityForName:@"EntriesInfoTrip"
                                                inManagedObjectContext:context];
                                [newEntryInfo setValue:[NSNumber numberWithInt:[txtAmount.text intValue]] forKeyPath:@"amount"];
                                [newEntryInfo setValue:self.companies.companyId forKeyPath:@"companyId"];
                                [newEntryInfo setValue:editEntryInfo.creditAccount forKeyPath:@"creditAccount"];
                                [newEntryInfo setValue:strNewDate forKeyPath:@"date"];
                                [newEntryInfo setValue:editEntryInfo.debitAccount forKeyPath:@"debitAccount"];
                                [newEntryInfo setValue:txtDescription.text forKeyPath:@"descriptionEntry"];
                                [newEntryInfo setValue:self.companies.emailId forKeyPath:@"email"];
                                [newEntryInfo setValue:[NSNumber numberWithInt:[entryId intValue]] forKeyPath:@"entryId"];
                                [newEntryInfo setValue:preTripInfo.tripId forKeyPath:@"tripId"];
                                [newEntryInfo setValue:editEntryInfo.groupId forKeyPath:@"groupId"];
                                [newEntryInfo setValue:editEntryInfo.transactionType forKeyPath:@"transactionType"];
                                [context insertObject:newEntryInfo];
                                [context save:&error];
                                
                            }
                        }
                        //fetch the entriesTripInfoObj using the entry id
                        for(EntriesInfoTrip * entriesInfo in arrEntriesInfoTrip){
                            if([entriesInfo.entryId isEqual:editEntry.entryId]){
                                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                                NSError *error;
                                entriesInfo.date = strNewDate;
                                if([transctionType isEqualToString:@"0"]){
                                    entriesInfo.creditAccount = [forAccount.accountId stringValue];
                                    entriesInfo.debitAccount = [viaAccount.accountId stringValue];
                                }
                                else{
                                    entriesInfo.debitAccount = [forAccount.accountId stringValue];
                                    entriesInfo.creditAccount = [viaAccount.accountId stringValue];
                                }
                                entriesInfo.entryId = [NSNumber numberWithInt:[entryId intValue]];
                                
                                entriesInfo.amount =[NSNumber numberWithInt:[txtAmount.text intValue]];
                                entriesInfo.tripId = preTripInfo.tripId;
                                // [context insertObject:editEntry];
                                [context save:&error];
                            }
                        }
                        
                    }
                }
                editEntryInfo.entryId = [NSNumber numberWithInt:[entryId intValue]];
                editEntryInfo.amount = [NSNumber numberWithInt:[txtAmount.text intValue]];
                editEntryInfo.date= strNewDate;
                // [context insertObject:editEntry];
                [context save:&error];
                if(isTripDoneEmpty){
                    for(EntriesInfoTrip * entriesInfo in arrEntriesInfoTrip){
                        if([entriesInfo.tripId isEqual:preTripInfo.tripId]){
                            NSManagedObjectContext *context = [appDelegate managedObjectContext];
                            [context deleteObject:entriesInfo];
                        }
                    }
                }
                
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Opps" message:@"An Error occoured please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else
    {
        [[ServiceManager sharedManager]updateEntryforAuthKey:@"" andcompanyName:self.companies.companyName forEntryId:[NSString stringWithFormat:@"%@",editEntry.entryId] date:btnDate.titleLabel.text description:txtDescription.text mobile:@"1" debit:strArrDebit credit:strArrCredit tripId:preTripInfo.tripId withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            //NSLog(@"%@",responce);
            if([[NSString stringWithFormat:@"%@",[responce valueForKey:@"status"]] isEqual:@"1"]){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSArray *arrData = [responce valueForKey:@"data"];
                NSDictionary *dataDict = [arrData objectAtIndex:0];
                NSString * entryId = [dataDict valueForKey:@"entryId"];
                AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
                
                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                NSString *transctionType = [NSString stringWithFormat:@"%@",editEntry.transactionType];
                if([transctionType isEqualToString:@"0"]){
                    editEntry.creditAccount = forAccount.accountId;
                    editEntry.debitAccount = viaAccount.accountId;
                    
                }
                else{
                    editEntry.debitAccount = forAccount.accountId;
                    editEntry.creditAccount = viaAccount.accountId;
                }
                if(![selectedTripInfo isEqual:nil]||![preTripInfo isEqual:nil]){
                    if([editEntry.entryId isEqual:0]){
                        // fetch the entriesTripInfoObj using the objId
                        for(EntriesInfoTrip * entriesInfo in arrEntriesInfoTrip){
                            NSURL * entriesObjIdUrl =[NSURL URLWithString:editEntry.entriesInfoObjId];
                            NSURL *entriesInfoObjId = [[entriesInfo objectID] URIRepresentation];
                            if([entriesInfoObjId isEqual:entriesObjIdUrl]){
                                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                                NSError *error;
                                entriesInfo.date = btnDate.titleLabel.text;
                                if([transctionType isEqualToString:@"0"]){
                                    entriesInfo.creditAccount = [forAccount.accountId stringValue];
                                    entriesInfo.debitAccount = [viaAccount.accountId stringValue];
                                }
                                else{
                                    entriesInfo.debitAccount = [forAccount.accountId stringValue];
                                    entriesInfo.creditAccount = [viaAccount.accountId stringValue];
                                }
                                entriesInfo.amount =[NSNumber numberWithInt:[txtAmount.text intValue]];
                                entriesInfo.tripId = selectedTripInfo.tripId;
                                // [context insertObject:editEntry];
                                [context save:&error];
                            }
                        }
                    }
                    else{
                        if(isInitialyNoTrip){
                            if(![preTripInfo isEqual:nil]){
                                
                                NSManagedObjectContext *context=[appDelegate managedObjectContext];
                                NSManagedObject *newEntryInfo;
                                newEntryInfo = [NSEntityDescription
                                                insertNewObjectForEntityForName:@"EntriesInfoTrip"
                                                inManagedObjectContext:context];
                                [newEntryInfo setValue:[NSNumber numberWithInt:[txtAmount.text intValue]] forKeyPath:@"amount"];
                                [newEntryInfo setValue:self.companies.companyId forKeyPath:@"companyId"];
                                [newEntryInfo setValue:[editEntry.creditAccount stringValue] forKeyPath:@"creditAccount"];
                                [newEntryInfo setValue:btnDate.titleLabel.text forKeyPath:@"date"];
                                [newEntryInfo setValue:[editEntry.debitAccount stringValue] forKeyPath:@"debitAccount"];
                                [newEntryInfo setValue:txtDescription.text forKeyPath:@"descriptionEntry"];
                                [newEntryInfo setValue:self.companies.emailId forKeyPath:@"email"];
                                [newEntryInfo setValue:[NSNumber numberWithInt:[entryId intValue]] forKeyPath:@"entryId"];
                                [newEntryInfo setValue:preTripInfo.tripId forKeyPath:@"tripId"];
                                [newEntryInfo setValue:editEntry.groupId forKeyPath:@"groupId"];
                                [newEntryInfo setValue:editEntry.transactionType forKeyPath:@"transactionType"];
                                [context insertObject:newEntryInfo];
                                [context save:&error];
                                
                            }
                        }
                        //fetch the entriesTripInfoObj using the entry id
                        for(EntriesInfoTrip * entriesInfo in arrEntriesInfoTrip){
                            if([entriesInfo.entryId isEqual:editEntry.entryId]){
                                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                                NSError *error;
                                entriesInfo.date = btnDate.titleLabel.text;
                                if([transctionType isEqualToString:@"0"]){
                                    entriesInfo.creditAccount = [forAccount.accountId stringValue];
                                    entriesInfo.debitAccount = [viaAccount.accountId stringValue];
                                }
                                else{
                                    entriesInfo.debitAccount = [forAccount.accountId stringValue];
                                    entriesInfo.creditAccount = [viaAccount.accountId stringValue];
                                }
                                entriesInfo.entryId = [NSNumber numberWithInt:[entryId intValue]];
                                
                                entriesInfo.amount =[NSNumber numberWithInt:[txtAmount.text intValue]];
                                entriesInfo.tripId = preTripInfo.tripId;
                                // [context insertObject:editEntry];
                                [context save:&error];
                            }
                        }
                        
                    }
                }
                editEntry.entryId = [NSNumber numberWithInt:[entryId intValue]];
                editEntry.amount = [NSNumber numberWithInt:[txtAmount.text intValue]];
                editEntry.date= btnDate.titleLabel.text;
                // [context insertObject:editEntry];
                [context save:&error];
                if(isTripDoneEmpty){
                    for(EntriesInfoTrip * entriesInfo in arrEntriesInfoTrip){
                        if([entriesInfo.tripId isEqual:preTripInfo.tripId]){
                            NSManagedObjectContext *context = [appDelegate managedObjectContext];
                            [context deleteObject:entriesInfo];
                        }
                    }
                }
                
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Opps" message:@"An Error occoured please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    
    
    
    // call update api
    
}

- (IBAction)account1ButtonAction:(id)sender {
    viewPicker.hidden = NO;
    self.datePicker.hidden = YES;
    arrPickerData = [NSMutableArray array];
    for(Accounts *accounts in arrAccounts){
        if([forAccountId isEqual:accounts.groupId]){
            [arrPickerData addObject:accounts];
        }
    }
    self.pickerView.hidden = NO;
    selectedType = @"accounts1";
    
    [self.pickerView reloadAllComponents];
}

- (IBAction)account2ButtonAction:(id)sender {
    viewPicker.hidden = NO;
    self.datePicker.hidden = YES;
    
    arrPickerData = [NSMutableArray array];
    for(Accounts *accounts in arrAccounts){
        if([viaAccountId isEqual:accounts.groupId]){
            [arrPickerData addObject:accounts];
        }
    }
    self.pickerView.hidden = NO;
    selectedType = @"accounts2";
    [self.pickerView reloadAllComponents];
    
    
}
- (IBAction)tripButtonAction:(id)sender {
    viewPicker.hidden = NO;
    self.datePicker.hidden = YES;
    
    arrPickerData = arrTripInfo.mutableCopy;
    self.pickerView.hidden = NO;
    selectedType = @"trip";
    [self.pickerView reloadAllComponents];
    
}

- (IBAction)removeTripButtonAction:(id)sender {
    [btnTrip setTitle:@"No associated trip" forState:UIControlStateNormal];
    selectedTripInfo=nil;
    isTripDoneEmpty = YES;
    
}
#pragma mark UIPickerViewDataSource
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if([selectedType isEqualToString:@"accounts1"]||[selectedType isEqualToString:@"accounts2"]){
        Accounts * account = arrPickerData[row];
        return account.accountName;
    }
    else if([selectedType isEqualToString:@"trip"]){
        TripInfo *trip = arrPickerData[row];
        return trip.tripName;
    }
    NSString *returnStr = @"";
    return returnStr;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if([selectedType isEqualToString:@"accounts1"]){
        Accounts * account = arrPickerData[row];
        forAccount= account;
        [btnAccount1 setTitle:account.accountName forState:UIControlStateNormal];
        
    }
    else if([selectedType isEqualToString:@"trip"]){
        TripInfo *trip = arrTripInfo[row];
        selectedTripInfo = trip;
        preTripInfo = trip;
        [btnTrip setTitle:trip.tripName forState:UIControlStateNormal];
        
    }
    else if([selectedType isEqualToString:@"accounts2"]){
        Accounts * account = arrPickerData[row];
        viaAccount = account;
        [btnAcoount2 setTitle:account.accountName forState:UIControlStateNormal];
        
    }
    self.pickerView.hidden = YES;
    viewPicker.hidden = YES;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrPickerData.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (IBAction)cancelButtonAction:(id)sender {
    viewPicker.hidden=YES;
    
}

- (IBAction)DoneButtonAction:(id)sender {
    NSDate *date = self.datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // [formatter setDateFormat:@"yyyy-MM-dd"];
    
    [formatter setDateFormat:@"dd MMM yyyy"];
    [btnDate setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];
    viewPicker.hidden=YES;
}
@end
