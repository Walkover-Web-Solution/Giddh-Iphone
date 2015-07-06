//
//  LedgerEntryViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 19/06/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "LedgerEntryViewController.h"
#import "ButtonTableViewCell.h"
#import "TextFieldTableViewCell.h"
#import "Accounts.h"
#import "AppDelegate.h"
#import "TripInfo.h"
#import "MBProgressHUD.h"
#import "ServiceManager.h"
#define IS_IPHONE         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4     (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)

#define AMOUNT_TEXTFIELD_OFFSET        (IS_IPHONE_4 ? 60 :0)
#define DESCRIPTION_TEXTFIELD_OFFSET        (IS_IPHONE_4 ? 80 :0)

@interface LedgerEntryViewController (){
    NSArray *arrAccounts;
    NSArray *arrBankAccount;
    NSArray *arrTripInfo;
    NSMutableArray *arrPickerAccounts;
    NSMutableArray *arrPickerTrips;
    NSString *selectedDate;
    NSString *selectedType;
    Accounts * selectedAccount;
    TripInfo * selectedTripInfo;
    Accounts *selectedCreditAccount;
    Accounts *selectedDebitAccount;
    __weak IBOutlet UILabel *lblHeader;

    __weak IBOutlet UILabel *lblPickerHeader;
    __weak IBOutlet UIButton *btnChoseAccount2;
    __weak IBOutlet UIButton *btnChoseAccount1;
    __weak IBOutlet UIButton *btnDate;
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UITextField *txtAmount;
    __weak IBOutlet UITextField *txtDescription;
    NSArray *arrPickerData;
    __weak IBOutlet UIButton *btnTrip;
}
@property (strong, nonatomic) Accounts *accounts;
- (IBAction)choseAccount1ButtonAction:(id)sender;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)dateButtonAction:(id)sender;
- (IBAction)choseAccount2ButttonAction:(id)sender;
- (IBAction)choseTripButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewPicker;
- (IBAction)pickerDoneButtonAction:(id)sender;

- (IBAction)cancelButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
- (IBAction)DoneButtonAction:(id)sender;
@end

@implementation LedgerEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrAccounts = [NSArray array];
    arrBankAccount = [NSArray array];
    arrPickerData = [NSArray array];
    arrTripInfo = [NSArray array];
    [self getAccounts];
    [self setCurrentDate];
    [self getTrip];
    [self getPickerData];
    self.viewPicker.hidden = YES;
    Accounts *account =self.accounts= [self getAccountForAccountId:[NSNumber numberWithInt:[self.accountId intValue]]];
    lblHeader.text = account.accountName;
    if([account.groupId intValue] ==0){
        selectedCreditAccount = self.accounts;
    }
    else{
        selectedDebitAccount = self.accounts;
    }
    if(self.type ==nil){
        if([account.groupId intValue] ==0)
            self.type = @"0";
        else if([account.groupId intValue] ==1)
            self.type = @"1";
    }
    [btnTrip setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.6f] forState:UIControlStateNormal];
    [btnChoseAccount1 setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.6f] forState:UIControlStateNormal];

    self.viewPicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewPicker.layer.borderWidth = .5f;
    
    // set picker max and min date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.year = -1;
    datePicker.maximumDate = [NSDate date];
    datePicker.minimumDate = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    //    numberToolbar.items = [NSArray arrayWithObjects:
    //                           [[UIBarButtonItem alloc]initWithTitle:@"Hide" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
    //                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
    //                           nil];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"downArrow"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           nil];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    [numberToolbar setFrame:CGRectMake(0, 35, screenWidth, 35)];
    numberToolbar.barTintColor = [UIColor colorWithRed:(244/256.0) green:(244/256.0) blue:(244/256.0) alpha:1];
    numberToolbar.backgroundColor = [UIColor colorWithRed:(244/256.0) green:(244/256.0) blue:(244/256.0) alpha:1];
    txtAmount.inputAccessoryView = numberToolbar;
}

-(void)cancelNumberPad{
    [txtAmount resignFirstResponder];
    //  numberTextField.text = @"";
}

-(void)getPickerData{
    Accounts *account = [self getAccountForAccountId:[NSNumber numberWithInt:[self.accountId intValue]]];
    NSMutableArray *arrTempData = [NSMutableArray array];
    arrPickerAccounts = [NSMutableArray array];
    if(self.type != nil){
        if([self.type isEqual:@"1"]){
            for(Accounts * account in arrAccounts){
                if([account.groupId intValue] == 1){
                    if(!([[account.accountName lowercaseString] isEqual:@"loan"] || [[account.accountName lowercaseString] isEqual:@"other"]))
                        [arrTempData addObject:account];
                }
            }
        }
        else{
            for(Accounts * account in arrAccounts){
                if([account.groupId intValue] == 0){
                    if(!([[account.accountName lowercaseString] isEqual:@"loan"] || [[account.accountName lowercaseString] isEqual:@"other"]))
                        [arrTempData addObject:account];
                }
            }
        }
    }
    else if([account.groupId intValue]<=1){
        for(Accounts * account in arrAccounts){
            if([account.groupId intValue] > 1){
                if(!([[account.accountName lowercaseString] isEqual:@"loan"] || [[account.accountName lowercaseString] isEqual:@"other"]))
                   [arrTempData addObject:account];
            }
        }
    }
    else{
        for(Accounts * account in arrAccounts){
            if([account.groupId intValue] <= 1){
                if(!([[account.accountName lowercaseString] isEqual:@"loan"] || [[account.accountName lowercaseString] isEqual:@"other"]))
                   [arrTempData addObject:account];
            }
        }
    }
    arrPickerAccounts = arrTempData;
}
-(void)getTrip{
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"TripInfo" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrPickerTrips=[[context executeFetchRequest:request error:&error]mutableCopy];
}

-(void)setCurrentDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    selectedDate = [formatter stringFromDate:[NSDate date]];

    [formatter setDateFormat:@"dd MMM yyyy"];
    NSString *strSchedule = [formatter stringFromDate:[NSDate date]];
    [btnDate setTitle:strSchedule forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(Accounts*)getAccountForAccountId:(NSNumber*)accountId{
    for(Accounts *account in arrAccounts){
        if([account.accountId isEqual: accountId]){
            return account;
        }
    }
    return nil;
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dateButtonAction:(id)sender {
    lblPickerHeader.text = @"Select Date";
    [self.view endEditing:YES];

    self.viewPicker.hidden = NO;
    self.viewPicker.hidden = NO;
    datePicker.hidden = NO;
    self.pickerView.hidden = YES;
}

- (IBAction)choseAccount2ButttonAction:(id)sender {
}

- (IBAction)choseTripButtonAction:(id)sender {
    lblPickerHeader.text = @"Select Trip";
    [self.view endEditing:YES];

    selectedType = @"trip";
    self.viewPicker.hidden = NO;
    datePicker.hidden = YES;
    self.pickerView.hidden = NO;
    arrPickerData=arrPickerTrips;

    [self.pickerView reloadAllComponents];
}

- (IBAction)DoneButtonAction:(id)sender {
    if(txtAmount.text.length==0 || selectedCreditAccount == nil || selectedDebitAccount == nil){
        NSString *message;
        if(txtAmount.text.length==0){
            message = @"Please enter amount first.";
        }
        else{
            message = @"Please chose a account";
        }
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Opps!!" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        NSArray *array = [self.navigationController viewControllers];
        if(selectedAccount!=nil){
            
            // credit
            Accounts *creditAccount = selectedCreditAccount;
            NSString * creGrpIdStr = [NSString stringWithFormat:@"%@", creditAccount.groupId];
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
            Accounts *debitAccount = selectedDebitAccount;
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
            NSString *uniqueName = creditAccount.uniqueName;
            if([uniqueName isEqual:@""])
                uniqueName =debitAccount.uniqueName;
            NSNumber * transactionType;
            if([self.type isEqual:@"0"]){
                transactionType = [NSNumber numberWithInt:0];
            }
            else{
                transactionType = [NSNumber numberWithInt:1];
            }
            
            NSString * strArrCredit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\",\"uniqueName\":\"%@\"}]",creditAccount.accountName,txtAmount.text,creGrpType,creGrpType,creditAccount.uniqueName];
            NSString * strArrDebit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\",\"uniqueName\":\"%@\"}]",debitAccount.accountName,txtAmount.text,debGrpType,debGrpType,debitAccount.uniqueName];
            MBProgressHUD * hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"Processing...";
            [[ServiceManager sharedManager]createEntryForAuthKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"] andTripId:[selectedTripInfo.tripId intValue] andMobile:@"1" date:selectedDate companyName:self.companies.companyName withDescription:txtDescription.text withDebit:strArrDebit andCredit:strArrCredit withTransactionType:[NSString stringWithFormat:@"%@",transactionType] andUniqueName:uniqueName withCompletionBlock:^(NSDictionary *responce, NSError *error) {
                NSLog(@"%@",responce);
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSArray * arrData = [responce valueForKey:@"data"];
                NSDictionary *dataDict = arrData[0];
                NSString *entryId = [dataDict valueForKey:@"entryId"];
                AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                NSManagedObjectContext *context=[appDelegate managedObjectContext];
                NSURL *entriesIfoObjUrl;
                if(selectedTripInfo!=nil){
                    //add entriesInfo object with trip info in tripInfo DataBase
                    NSManagedObject *newEntryInfo;
                    newEntryInfo = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"EntriesInfoTrip"
                                    inManagedObjectContext:context];
                    [newEntryInfo setValue:[NSNumber numberWithInt:[txtAmount.text intValue]] forKeyPath:@"amount"];
                    [newEntryInfo setValue:self.companies.companyId forKeyPath:@"companyId"];
                    [newEntryInfo setValue:[creditAccount.accountId stringValue] forKeyPath:@"creditAccount"];
                    [newEntryInfo setValue:selectedDate forKeyPath:@"date"];
                    [newEntryInfo setValue:[debitAccount.accountId stringValue] forKeyPath:@"debitAccount"];
                    [newEntryInfo setValue:txtDescription.text forKeyPath:@"descriptionEntry"];
                    [newEntryInfo setValue:self.companies.emailId forKeyPath:@"email"];
                    [newEntryInfo setValue:[NSNumber numberWithInt:[entryId intValue]] forKeyPath:@"entryId"];
                    [newEntryInfo setValue:[NSNumber numberWithInt:[selectedTripInfo.tripId intValue]] forKeyPath:@"tripId"];
                    [newEntryInfo setValue:selectedAccount.groupId forKeyPath:@"groupId"];
                    [newEntryInfo setValue:transactionType forKeyPath:@"transactionType"];
                    [context insertObject:newEntryInfo];
                    [context save:&error];
                    entriesIfoObjUrl = [[newEntryInfo objectID] URIRepresentation];
                }
                
                NSManagedObject *newEntry;
                
                newEntry = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Entries"
                            inManagedObjectContext:context];
                [newEntry setValue:[NSNumber numberWithInt:[txtAmount.text intValue]] forKeyPath:@"amount"];
                [newEntry setValue:self.companies.companyId forKeyPath:@"companyId"];
                [newEntry setValue:creditAccount.accountId forKeyPath:@"creditAccount"];
                [newEntry setValue:selectedDate forKeyPath:@"date"];
                [newEntry setValue:debitAccount.accountId forKeyPath:@"debitAccount"];
                [newEntry setValue:txtDescription.text forKeyPath:@"descriptionEntry"];
                //[newEntry setValue:self.entriesTemp.emailIfLoan forKeyPath:@"emailIfLoan"];
                [newEntry setValue:[NSNumber numberWithInt:[entryId intValue]] forKeyPath:@"entryId"];
                [newEntry setValue:self.accounts.accountId forKeyPath:@"groupId"];
                [newEntry setValue:transactionType forKeyPath:@"transactionType"];
                [newEntry setValue:[NSString stringWithFormat:@"%@",entriesIfoObjUrl] forKey:@"entriesInfoObjId"];
                NSLog(@"newEntry :-%@",newEntry);
                [context insertObject:newEntry];
                [context save:&error];
                Accounts *account = [self getAccountForAccountId:[NSNumber numberWithInt:[self.accountId intValue]]];
                if([account.groupId intValue]>1){
                    [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
                }
                else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }];
            
        }
        else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Hold on!!" message:@"Select a category first." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }

    }
  
    
}
- (IBAction)choseAccount1ButtonAction:(id)sender {
    [self.view endEditing:YES];
    lblPickerHeader.text = @"Select Account";
    selectedType = @"accounts";
    datePicker.hidden = YES;
    self.viewPicker.hidden = NO;
    self.pickerView.hidden = NO;
    arrPickerData=arrPickerAccounts;
    [self.pickerView reloadAllComponents];
}
- (IBAction)pickerDoneButtonAction:(id)sender {
    // NSString *date  =[NSString stringWithFormat:@"%@",pickerView.date];
    // NSArray *strArry = [date componentsSeparatedByString:@" "];
    if([selectedType isEqual:@"accounts"] || [selectedType isEqual:@"bankAccount"]||[selectedType isEqual:@"trip"]){
       ;
        if([selectedType isEqualToString:@"accounts"]){
            Accounts * account =  [arrPickerData objectAtIndex:[self.pickerView selectedRowInComponent:0]];
            selectedAccount= account;
            if([self.accounts.groupId intValue] ==3 && ![[self.accounts.accountName lowercaseString] isEqual:@"cash"]){
                [btnChoseAccount1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                selectedAccount = [self getAccountForAccountId:[NSNumber numberWithInt:11]];
                [btnChoseAccount1 setTitle:selectedAccount.accountName forState:UIControlStateNormal];
                if(selectedDebitAccount ==nil){
                    selectedCreditAccount = selectedAccount;
                }
                else{
                    selectedDebitAccount = selectedAccount;
                }
                self.pickerView.hidden = YES;
                self.viewPicker.hidden = YES;
            }
            else if([account.accountId intValue] == 16 ){
                [self loadPickerWithBankAccounts];
            }
            else{
                [btnChoseAccount1 setTitle:account.accountName forState:UIControlStateNormal];
                [btnChoseAccount1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                if(selectedDebitAccount ==nil){
                    selectedDebitAccount = selectedAccount;
                }
                else{
                    selectedCreditAccount = selectedAccount;
                }
                self.pickerView.hidden = YES;
                self.viewPicker.hidden = YES;
            }
        }
        else if([selectedType isEqualToString:@"trip"]){
            TripInfo *trip =  [arrPickerData objectAtIndex:[self.pickerView selectedRowInComponent:0]];
            selectedTripInfo = trip;
            [btnTrip setTitle:trip.tripName forState:UIControlStateNormal];
            [btnTrip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.pickerView.hidden = YES;
            self.viewPicker.hidden = YES;
            
        }
        else if([selectedType isEqualToString:@"bankAccount"]){
            Accounts * account =  [arrPickerData objectAtIndex:[self.pickerView selectedRowInComponent:0]];
            selectedAccount= account;
            [btnChoseAccount1 setTitle:account.accountName forState:UIControlStateNormal];
            [btnChoseAccount1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            if(selectedDebitAccount ==nil){
                selectedCreditAccount = selectedAccount;
            }
            else{
                selectedDebitAccount = selectedAccount;
            }
            self.pickerView.hidden = YES;
            self.viewPicker.hidden = YES;

            
        }
        

    }
    else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        selectedDate = [formatter stringFromDate:datePicker.date];
        [formatter setDateFormat:@"dd MMM yyyy"];
        NSString *strSchedule = [formatter stringFromDate:datePicker.date];
        
        [btnDate setTitle:strSchedule forState:UIControlStateNormal];
        self.viewPicker.hidden = YES;
        [btnDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    }
    //convert date to string
   }

- (IBAction)cancelButtonAction:(id)sender {
    self.viewPicker.hidden = YES;

}
- (IBAction)doneButtonAction:(id)sender {
    if(selectedAccount!=nil){
        // credit
        Accounts *creditAccount = selectedCreditAccount;

        NSString * creGrpIdStr = [NSString stringWithFormat:@"%@", creditAccount.groupId];
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
        Accounts *debitAccount = selectedDebitAccount;
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
        NSString *uniqueName = creditAccount.uniqueName;
        if([uniqueName isEqual:@""])
            uniqueName =debitAccount.uniqueName;
        NSNumber * transactionType;
        if([self.type isEqual:@"0"]){
            transactionType = [NSNumber numberWithInt:0];
        }
        else{
            transactionType = [NSNumber numberWithInt:1];
        }

        NSString * strArrCredit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\",\"uniqueName\":\"%@\"}]",creditAccount.accountName,txtAmount.text,creGrpType,creGrpType,creditAccount.uniqueName];
        NSString * strArrDebit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\",\"uniqueName\":\"%@\"}]",debitAccount.accountName,txtAmount.text,debGrpType,debGrpType,debitAccount.uniqueName];
        MBProgressHUD * hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText=@"Processing...";
        [[ServiceManager sharedManager]createEntryForAuthKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"] andTripId:[selectedTripInfo.tripId intValue] andMobile:@"1" date:selectedDate companyName:self.companies.companyName withDescription:txtDescription.text withDebit:strArrDebit andCredit:strArrCredit withTransactionType:[NSString stringWithFormat:@"%@",transactionType] andUniqueName:uniqueName withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            //NSLog(@"%@",responce);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString * status = [NSString stringWithFormat:@"%@",[responce valueForKey:@"status"]];
            NSString *entryId;
            if([status isEqual:@"1"]){
                NSArray * arrData = [responce valueForKey:@"data"];
                NSDictionary *dataDict = arrData[0];
                entryId = [dataDict valueForKey:@"entryId"];

            }
            AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
            NSManagedObjectContext *context=[appDelegate managedObjectContext];
            NSURL *entriesIfoObjUrl;
            if(selectedTripInfo!=nil){
                //add entriesInfo object with trip info in tripInfo DataBase
                NSManagedObject *newEntryInfo;
                newEntryInfo = [NSEntityDescription
                                insertNewObjectForEntityForName:@"EntriesInfoTrip"
                                inManagedObjectContext:context];
                [newEntryInfo setValue:[NSNumber numberWithInt:[txtAmount.text intValue]] forKeyPath:@"amount"];
                [newEntryInfo setValue:self.companies.companyId forKeyPath:@"companyId"];
                [newEntryInfo setValue:[creditAccount.accountId stringValue] forKeyPath:@"creditAccount"];
                [newEntryInfo setValue:selectedDate forKeyPath:@"date"];
                [newEntryInfo setValue:[debitAccount.accountId stringValue] forKeyPath:@"debitAccount"];
                [newEntryInfo setValue:txtDescription.text forKeyPath:@"descriptionEntry"];
                [newEntryInfo setValue:self.companies.emailId forKeyPath:@"email"];
                [newEntryInfo setValue:[NSNumber numberWithInt:[entryId intValue]] forKeyPath:@"entryId"];
                [newEntryInfo setValue:[NSNumber numberWithInt:[selectedTripInfo.tripId intValue]] forKeyPath:@"tripId"];
                [newEntryInfo setValue:selectedAccount.groupId forKeyPath:@"groupId"];
                [newEntryInfo setValue:transactionType forKeyPath:@"transactionType"];
                [context insertObject:newEntryInfo];
                [context save:&error];
                entriesIfoObjUrl = [[newEntryInfo objectID] URIRepresentation];
            }
            
            NSManagedObject *newEntry;
            
            newEntry = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Entries"
                        inManagedObjectContext:context];
            [newEntry setValue:[NSNumber numberWithInt:[txtAmount.text intValue]]forKeyPath:@"amount"];
            [newEntry setValue:self.companies.companyId forKeyPath:@"companyId"];
            [newEntry setValue:creditAccount.accountId forKeyPath:@"creditAccount"];
            [newEntry setValue:selectedDate forKeyPath:@"date"];
            [newEntry setValue:debitAccount.accountId forKeyPath:@"debitAccount"];
            [newEntry setValue:txtDescription.text forKeyPath:@"descriptionEntry"];
            //[newEntry setValue:self.entriesTemp.emailIfLoan forKeyPath:@"emailIfLoan"];
            [newEntry setValue:[NSNumber numberWithInt:[entryId intValue]] forKeyPath:@"entryId"];
            [newEntry setValue:self.accounts.accountId forKeyPath:@"groupId"];
            [newEntry setValue:transactionType forKeyPath:@"transactionType"];
            [newEntry setValue:[NSString stringWithFormat:@"%@",entriesIfoObjUrl] forKey:@"entriesInfoObjId"];
            [context insertObject:newEntry];
            [context save:&error];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }];
        
    }
    else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Hold on!!" message:@"Select a category first." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark UIPickerViewDataSource
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if([selectedType isEqualToString:@"accounts"]){
        Accounts * account = arrPickerData[row];
        return account.accountName;
    }
    else if([selectedType isEqualToString:@"trip"]){
        TripInfo *trip = arrPickerData[row];
        return trip.tripName;
    }
    else if([selectedType isEqualToString:@"bankAccount"]){
        Accounts *account = arrPickerData[row];
        return account.accountName;
    }
    NSString *returnStr = @"";
    return returnStr;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    if([selectedType isEqualToString:@"accounts"]){
//        Accounts * account = arrPickerData[row];
//        selectedAccount= account;
//        if([self.accounts.groupId intValue] ==3 && ![[self.accounts.accountName lowercaseString] isEqual:@"cash"]){
//            [btnChoseAccount1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            selectedAccount = [self getAccountForAccountId:[NSNumber numberWithInt:11]];
//            [btnChoseAccount1 setTitle:selectedAccount.accountName forState:UIControlStateNormal];
//            if(selectedDebitAccount ==nil){
//                selectedCreditAccount = selectedAccount;
//            }
//            else{
//                selectedDebitAccount = selectedAccount;
//            }
//            self.pickerView.hidden = YES;
//            self.viewPicker.hidden = YES;
//        }
//        else if([account.accountId intValue] == 16 ){
//            NSLog(@"Show list of all bank account");
//            [self loadPickerWithBankAccounts];
//        }
//        else{
//            [btnChoseAccount1 setTitle:account.accountName forState:UIControlStateNormal];
//            [btnChoseAccount1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            if(selectedDebitAccount ==nil){
//                selectedCreditAccount = selectedAccount;
//            }
//            else{
//                selectedDebitAccount = selectedAccount;
//            }
//            self.pickerView.hidden = YES;
//            self.viewPicker.hidden = YES;
//        }
//      
//
//    }
//    else if([selectedType isEqualToString:@"trip"]){
//        TripInfo *trip = arrPickerData[row];
//        selectedTripInfo = trip;
//        [btnTrip setTitle:trip.tripName forState:UIControlStateNormal];
//        [btnTrip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        self.pickerView.hidden = YES;
//        self.viewPicker.hidden = YES;
//
//    }
//    else if([selectedType isEqualToString:@"bankAccount"]){
//        Accounts * account = arrPickerData[row];
//        selectedAccount= account;
//        [btnChoseAccount1 setTitle:account.accountName forState:UIControlStateNormal];
//        [btnChoseAccount1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        if(selectedDebitAccount ==nil){
//            selectedCreditAccount = selectedAccount;
//        }
//        else{
//            selectedDebitAccount = selectedAccount;
//        }
//
//        
//    }
//
   
    
}
#pragma  mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [txtDescription resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

-(void)loadPickerWithBankAccounts{
    NSMutableArray *arrTempData = [NSMutableArray array];

    for(Accounts * account in arrAccounts){
        if([account.groupId intValue] == 3){
            if(!([[account.accountName lowercaseString] isEqual:@"cash"] || [[account.accountName lowercaseString] isEqual:@"cash"]))
                [arrTempData addObject:account];
        }
    }
    lblPickerHeader.text = @"Select Bank account";

    self.viewPicker.hidden = NO;
    selectedType = @"bankAccount";
    arrBankAccount = arrTempData;
    datePicker.hidden = YES;
    self.pickerView.hidden = NO;
    arrPickerData=arrBankAccount;
    
    [self.pickerView reloadAllComponents];

}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrPickerData.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.view endEditing:YES];    }
}


#pragma mark UITextFieldDelegate
- (void) performKeyboardAnimation: (NSInteger) offset  {
    [UIView beginAnimations:@"moveKeyboard" context:nil];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == txtAmount) {
        [self performKeyboardAnimation:-AMOUNT_TEXTFIELD_OFFSET];
    }
    else if (textField == txtDescription) {
        [self performKeyboardAnimation:-DESCRIPTION_TEXTFIELD_OFFSET];

    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == txtAmount) {
        [self performKeyboardAnimation:AMOUNT_TEXTFIELD_OFFSET];
        //  [self.txtUserName becomeFirstResponder];
    }
    else if (textField == txtDescription) {
        [self performKeyboardAnimation:DESCRIPTION_TEXTFIELD_OFFSET];
    }
    
    
}
    @end
