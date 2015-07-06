//
//  FinalTransactionViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 22/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "FinalTransactionViewController.h"
#import "TransactionCell.h"
#import "Accounts.h"
#import "AppDelegate.h"
#import "TransactionHeaderCollectionReusableView.h"
#import "ServiceManager.h"
#import "MBProgressHUD.h"
#import "TripInfo.h"
@interface FinalTransactionViewController ()<UICollectionViewDelegate,UITextFieldDelegate>{
    
    __weak IBOutlet UITextField *txtDescription;
    __weak IBOutlet UILabel *lblHeader;
    NSMutableArray *arrTableDataAssets;
    NSMutableArray *arrTableDataTrip;
    NSString *selectedAssetsIndex;
    Accounts *selectedAssets;
    TripInfo *selectedTrip;
    NSString *selectedTripIndex;
    NSArray *arrAccounts;
}
- (IBAction)doneButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation FinalTransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    txtDescription.delegate = self;
    arrAccounts = [NSArray array];
    arrTableDataTrip = [NSMutableArray array];
    if([self.type isEqual:@"0"])
        lblHeader.text = @"Receiving Money";
    else
        lblHeader.text = @"Giving Money";
    
    selectedAssetsIndex =nil;
    selectedTripIndex =nil;
    
    arrTableDataAssets = [NSMutableArray array];
    arrTableDataTrip = [NSMutableArray array];
    [self refreshListAssets];
    [self refreshListTrip];
    [self refreshAccounts];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
    
    // Do any additional setup after loading the view.
}
- (void)keyboardWillShow:(NSNotification*)notification {
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat newBottomInset = 0.0;
    
    UIEdgeInsets contentInsets;
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ) {
        newBottomInset = keyboardSize.height;
    } else {
        newBottomInset = keyboardSize.width;
    }
    
    contentInsets = UIEdgeInsetsMake(0.0, 0.0, newBottomInset, 0.0);
    self.collectionView.contentInset = contentInsets;
    self.collectionView.scrollIndicatorInsets = contentInsets;
    
}-(void) keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat newBottomInset = 0.0;
    
    UIEdgeInsets contentInsets;
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ) {
        newBottomInset = keyboardSize.height;
    }
    else {
        newBottomInset = keyboardSize.width;
    }
    
    contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.collectionView.contentInset = contentInsets;
    self.collectionView.scrollIndicatorInsets = contentInsets;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    if(section==0)
        return arrTableDataAssets.count;
    else
        return arrTableDataTrip.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"TransactionCell"
                                                                       forIndexPath:indexPath];
    
    //    UIImage *image;
    //    int row = [indexPath row];
    Accounts *accounts ;
    NSString *filePath;
    TripInfo *trip;
    switch (indexPath.section) {
        case 0:
            if(cell!=nil){
                cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"TransactionCell"
                                                                  forIndexPath:indexPath];
                
            }
            accounts = arrTableDataAssets[indexPath.row];
            filePath = [[NSBundle mainBundle] pathForResource:[accounts.accountName lowercaseString] ofType:@"png"];
            
            //            if(filePath.length > 0 && filePath != (id)[NSNull null]) {
            //                cell.imgTranscation.image = [UIImage imageNamed:[accounts.accountName lowercaseString]];
            //                cell.lblInitial.hidden = YES;
            //            }
            cell.lblInitial.text = [self getInitialsFor:accounts.accountName];
            
            if([selectedAssets isEqual:accounts]){
                if(indexPath.section ==0){
                    cell.imgSelectionView.image = [UIImage imageNamed:@"Check_mark11"];
                    cell.lblTransactionName.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
                }
                // cell.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.5f];
            }
            else{
                cell.imgSelectionView.image = nil;
                cell.lblTransactionName.font = [UIFont fontWithName:@"GothamRounded-Light" size:13];
                
                //cell.lblTransactionName.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
                
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.lblTransactionName.text = accounts.accountName;
            return cell;
            
            break;
        case 1:
            if(cell!=nil){
                cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"TransactionCell"
                                                                  forIndexPath:indexPath];
            }
            trip = arrTableDataTrip[indexPath.row];
            if([selectedTrip isEqual:trip]){
                if(indexPath.section ==1)
                    cell.imgSelectionView.image = [UIImage imageNamed:@"Check_mark11"];
                cell.lblTransactionName.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
                //cell.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.5f];
            }
            else{
                cell.imgSelectionView.image = nil;
                cell.lblTransactionName.font = [UIFont fontWithName:@"GothamRounded-Light" size:13];
                
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.lblTransactionName.text = trip.tripName;
            cell.lblInitial.text = [self getInitialsFor:trip.tripName];
            return cell;
            break;
        default:
            break;
            
    }
    
    //cell.lblInitial.text = [self getInitialsFor:accounts.accountName];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section==0){
        selectedAssets = nil;
        selectedAssets = arrTableDataAssets[indexPath.row];
        NSIndexSet *index = [NSIndexSet indexSetWithIndex:0];
        [self.collectionView reloadSections:index];
        
    }
    if(indexPath.section==1){
        selectedTrip = nil;
        selectedTrip = arrTableDataTrip[indexPath.row];
        NSIndexSet *index = [NSIndexSet indexSetWithIndex:1];
        [self.collectionView reloadSections:index];
    }
}
-(NSString*)getInitialsFor:(NSString*)str{
    NSMutableString * firstCharacters = [NSMutableString string];
    NSArray * words = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString * word in words) {
        if ([word length] > 0) {
            NSString * firstLetter = [word substringToIndex:1];
            [firstCharacters appendString:[firstLetter uppercaseString]];
        }
    }
    return firstCharacters;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.collectionView reloadData];
}

#pragma mark UICollectionViewFlowLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(78, 101);
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(320, 50);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if(kind == UICollectionElementKindSectionHeader)
    {
        TransactionHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TransactionHeaderCell" forIndexPath:indexPath];
        if(indexPath.section == 0)
            headerView.lblHeader.text =@"via";
        else
            headerView.lblHeader.text =@"Share with";
        
        return headerView;
        
    }
    return nil;
}
-(void)refreshListAssets{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
    //add arrdata into main table data array
    arrTableDataAssets = [NSMutableArray array];
    for(Accounts *accounts in arrData){
        
        int assetsGrp=3;
        NSNumber *assetsGrpId =[NSNumber numberWithInt:assetsGrp];
        if ([self.entriesTemp.emailIfLoan isEqual:@"atm withdraw"]) {
            if([accounts.groupId isEqual: assetsGrpId]&&[[accounts.accountName lowercaseString] isEqual: @"cash"]){
                [arrTableDataAssets addObject:accounts];
            }
        }
        else if([accounts.groupId isEqual: assetsGrpId]){
            [arrTableDataAssets addObject:accounts];
        }
    }
    [self.collectionView reloadData];
}
-(void)refreshListTrip{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"TripInfo" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
    //add arrdata into main table data array
    arrTableDataTrip = [NSMutableArray array];
    for(TripInfo *tripInfo in arrData){
        [arrTableDataTrip addObject:tripInfo];
    }
    [self.collectionView reloadData];
}


- (IBAction)doneButtonAction:(id)sender {
    if(selectedAssets!=nil){
        self.entriesTemp.descriptionEntry = txtDescription.text;
        if([self.type isEqual:@"0"]){
            self.entriesTemp.debitAccount = [NSString stringWithFormat:@"%@",selectedAssets.accountId];
        }
        else{
            self.entriesTemp.creditAccount = [NSString stringWithFormat:@"%@",selectedAssets.accountId];
            
        }
        
        self.entriesTemp.companyId= self.companies.companyId;
        NSNumber *creditAccId = [NSNumber numberWithInt:[self.entriesTemp.creditAccount intValue]];
        // credit
        Accounts *creditAccount;
        for (Accounts *accounts in arrAccounts){
            if([accounts.accountId isEqual:creditAccId ]){
                creditAccount = accounts;
            }
        }
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
        Accounts *debitAccount;
        NSNumber *debAccId = [NSNumber numberWithInt:[self.entriesTemp.debitAccount intValue]];
        for (Accounts *accounts in arrAccounts){
            if([accounts.accountId isEqual:debAccId ]){
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
        NSString *uniqueName = creditAccount.uniqueName;
        if([uniqueName isEqual:@""])
            uniqueName =debitAccount.uniqueName;
        NSString * strArrCredit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\",\"uniqueName\":\"%@\"}]",creditAccount.accountName,self.entriesTemp.amount,creGrpType,creGrpType,creditAccount.uniqueName];
        NSString * strArrDebit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\",\"uniqueName\":\"%@\"}]",debitAccount.accountName,self.entriesTemp.amount,debGrpType,debGrpType,debitAccount.uniqueName];
        MBProgressHUD * hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText=@"Processing...";
        [[ServiceManager sharedManager]createEntryForAuthKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"] andTripId:[selectedTrip.tripId intValue] andMobile:@"1" date:self.entriesTemp.date companyName:self.companies.companyName withDescription:self.entriesTemp.descriptionEntry withDebit:strArrDebit andCredit:strArrCredit withTransactionType:[NSString stringWithFormat:@"%@",self.entriesTemp.transactionType] andUniqueName:uniqueName withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            //NSLog(@"%@",responce);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *entryId;
            NSString * status = [NSString stringWithFormat:@"%@",[responce valueForKey:@"status"]];
            if([status isEqual:@"1"]){
                NSArray * arrData = [responce valueForKey:@"data"];
                NSDictionary *dataDict = arrData[0];
                entryId = [dataDict valueForKey:@"entryId"];
            }

            AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
            NSManagedObjectContext *context=[appDelegate managedObjectContext];
            NSURL *entriesIfoObjUrl;
            if(selectedTrip!=nil){
                //add entriesInfo object with trip info in tripInfo DataBase
                NSManagedObject *newEntryInfo;
                newEntryInfo = [NSEntityDescription
                                insertNewObjectForEntityForName:@"EntriesInfoTrip"
                                inManagedObjectContext:context];
                [newEntryInfo setValue:self.entriesTemp.amount forKeyPath:@"amount"];
                [newEntryInfo setValue:self.companies.companyId forKeyPath:@"companyId"];
                [newEntryInfo setValue:self.entriesTemp.creditAccount forKeyPath:@"creditAccount"];
                [newEntryInfo setValue:self.entriesTemp.date forKeyPath:@"date"];
                [newEntryInfo setValue:self.entriesTemp.debitAccount forKeyPath:@"debitAccount"];
                [newEntryInfo setValue:self.entriesTemp.descriptionEntry forKeyPath:@"descriptionEntry"];
                [newEntryInfo setValue:self.companies.emailId forKeyPath:@"email"];
                [newEntryInfo setValue:[NSNumber numberWithInt:[entryId intValue]] forKeyPath:@"entryId"];
                [newEntryInfo setValue:[NSNumber numberWithInt:[selectedTrip.tripId intValue]] forKeyPath:@"tripId"];
                [newEntryInfo setValue:self.entriesTemp.groupId forKeyPath:@"groupId"];
                [newEntryInfo setValue:self.entriesTemp.transactionType forKeyPath:@"transactionType"];
                [context insertObject:newEntryInfo];
                [context save:&error];
                entriesIfoObjUrl = [[newEntryInfo objectID] URIRepresentation];
            }
            
            NSManagedObject *newEntry;
            
            newEntry = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Entries"
                        inManagedObjectContext:context];
            [newEntry setValue:self.entriesTemp.amount forKeyPath:@"amount"];
            [newEntry setValue:self.companies.companyId forKeyPath:@"companyId"];
            [newEntry setValue:[NSNumber numberWithInt:[self.entriesTemp.creditAccount intValue]] forKeyPath:@"creditAccount"];
            [newEntry setValue:self.entriesTemp.date forKeyPath:@"date"];
            [newEntry setValue:[NSNumber numberWithInt:[self.entriesTemp.debitAccount intValue]] forKeyPath:@"debitAccount"];
            [newEntry setValue:self.entriesTemp.descriptionEntry forKeyPath:@"descriptionEntry"];
            [newEntry setValue:self.entriesTemp.emailIfLoan forKeyPath:@"emailIfLoan"];
            [newEntry setValue:[NSNumber numberWithInt:[entryId intValue]] forKeyPath:@"entryId"];
            [newEntry setValue:self.entriesTemp.groupId forKeyPath:@"groupId"];
            [newEntry setValue:self.entriesTemp.transactionType forKeyPath:@"transactionType"];
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
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [txtDescription resignFirstResponder];
    return YES;
}
- (IBAction)backButtonAction:(id)sender {
    if([self.entriesTemp.emailIfLoan isEqual:@"Loan"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
