//
//  TransactionTypeViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 20/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TransactionTypeViewController.h"
#import "TransactionCell.h"
#import "AppDelegate.h"
#import "AddAnotherAccountViewController.h"
#import "EntriesInfoTrip.h"
#import "EntriesTemp.h"
#import "FinalTransactionViewController.h"
#import "BankAccountListViewController.h"
#define IS_IPHONE         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_4     (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)

#define EXPIRY_TEXTFIELD_OFFSET        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 480.0f ? 0 :0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6PLUS (IS_IPHONE && [[UIScreen mainScreen] nativeScale] == 3.0f)

@interface TransactionTypeViewController ()<AddAnotherAccountViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UICollectionViewDelegate>{
    NSMutableArray *arrTableData;
    __weak IBOutlet UIButton *btnDate;
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet UILabel *lblHeader;
    __weak IBOutlet UIView *viewPicker;
    __weak IBOutlet UIDatePicker *pickerView;
    __weak IBOutlet UIButton *btnDone;
    __weak IBOutlet UIButton *btnCancel;
    __weak IBOutlet UITextField *txtEnterAmount;
    BOOL keyboardIsShowing;
}
- (IBAction)doneButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)dateButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@end

@implementation TransactionTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrTableData = [NSMutableArray array];
    [txtEnterAmount becomeFirstResponder];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
    //add arrdata into main table data array
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(dismissKeyboard)];
    
    //[self.view addGestureRecognizer:tap];
    
    if([self.type isEqual:@"0"])
        lblHeader.text = @"Receiving Money";
    else
        lblHeader.text = @"Giving Money";
    
    //   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupId beginswith[c] %@ ", [self.type intValue]];
    for(Accounts *accounts in arrData){
        NSNumber *grpId =[NSNumber numberWithInt:[self.type intValue]];
        // NSLog(@"%@",accounts.groupId);
        //NSLog(@"%@",grpId);
        int loanGrp=2;
        NSNumber *loanGrpId =[NSNumber numberWithInt:loanGrp];
        int newGrp=4;
        NSNumber *newGrpId =[NSNumber numberWithInt:newGrp];
        if([accounts.groupId isEqual: grpId]||([accounts.groupId isEqual:loanGrpId]&& [[accounts.accountName lowercaseString] isEqual:@"loan"] )||[accounts.groupId isEqual:newGrpId]){
            [arrTableData addObject:accounts];
        }
    }
    pickerView.datePickerMode= UIDatePickerModeDate;
    [collectionView reloadData];
    //NSLog(@"%@",arrTableData);
    viewPicker.hidden = YES;
    viewPicker.layer.borderWidth = .5f;
    viewPicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self refreshList];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    strAPIDate = [formatter stringFromDate:[NSDate date]];
    
    [formatter setDateFormat:@"dd MMM yyyy"];
    NSString *strSchedule = [formatter stringFromDate:[NSDate date]];
    [btnDate setTitle:strSchedule forState:UIControlStateNormal];
    
    //[btnDate setTitle:[strArry objectAtIndex:0] forState:UIControlStateNormal];
    viewPicker.hidden = YES;
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
    
    [numberToolbar sizeToFit];
    txtEnterAmount.inputAccessoryView = numberToolbar;
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
    txtEnterAmount.layer.borderWidth = 1.0f;
    txtEnterAmount.layer.borderColor = [UIColor colorWithRed:0.0f/245.0f green:122.0f/245.0f  blue:255.0f/245.0f  alpha:1.0f].CGColor;
    txtEnterAmount.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    // set picker max and min date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.year = -1;
    pickerView.maximumDate = [NSDate date];
    pickerView.minimumDate = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    
}

-(void)cancelNumberPad{
    [txtEnterAmount resignFirstResponder];
}

-(void)doneWithNumberPad{
    [txtEnterAmount resignFirstResponder];
}
-(void)dismissKeyboard {
    [txtEnterAmount resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification*)notification {
    txtEnterAmount.layer.borderWidth = 1.0f;
    txtEnterAmount.layer.borderColor = [UIColor colorWithRed:0.0f/245.0f green:122.0f/245.0f  blue:255.0f/245.0f  alpha:1.0f].CGColor;
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
    collectionView.contentInset = contentInsets;
    collectionView.scrollIndicatorInsets = contentInsets;
    
}
-(void) keyboardWillHide:(NSNotification *)notification
{
    txtEnterAmount.layer.borderWidth = 1.0f;
    txtEnterAmount.layer.borderColor = [UIColor lightGrayColor].CGColor;
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
    collectionView.contentInset = contentInsets;
    collectionView.scrollIndicatorInsets = contentInsets;
}

#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return arrTableData.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TransactionCell"
                                                                      forIndexPath:indexPath];
    
    Accounts *accounts = arrTableData[indexPath.row];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[accounts.accountName lowercaseString] ofType:@"png"];
    if(filePath.length > 0 && filePath != (id)[NSNull null]) {
        cell.imgTranscation.image = [UIImage imageNamed:[accounts.accountName lowercaseString]];
        cell.lblInitial.hidden = YES;
    }
    
    cell.lblTransactionName.text = accounts.accountName;
    cell.lblInitial.text = [self getInitialsFor:accounts.accountName];
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(txtEnterAmount.text.length!=0 && (![txtEnterAmount.text isEqual:@"0"])){
        [self.view endEditing:YES];
        UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
        FinalTransactionViewController *finalTransactionViewController = [sb2 instantiateViewControllerWithIdentifier:@"FinalTransactionViewController"];
        finalTransactionViewController.companies = self.companies;
        Accounts *accounts = arrTableData[indexPath.row];
        
        EntriesTemp * entriesInfoTrip = [[EntriesTemp alloc] init];
        NSNumber *amount = [NSNumber numberWithInt:[txtEnterAmount.text floatValue]];
        
        entriesInfoTrip.amount = amount;
        entriesInfoTrip.companyId = self.companies.companyId;
        entriesInfoTrip.groupId = accounts.groupId;
        //NSLog(@"%@",[NSString stringWithFormat:@"%@",accounts.accountId]);
        if([self.type isEqual:@"0"]){
            entriesInfoTrip.creditAccount =[NSString stringWithFormat:@"%@",accounts.accountId];
            entriesInfoTrip.transactionType = [NSNumber numberWithInt:0];
        }
        else{
            entriesInfoTrip.debitAccount =[NSString stringWithFormat:@"%@",accounts.accountId];
            entriesInfoTrip.transactionType = [NSNumber numberWithInt:1];
        }
        //NSLog(@"%@",[NSString stringWithFormat:@"%@",entriesInfoTrip.creditAccount]);
        
        //entriesInfoTrip.date = btnDate.titleLabel.text;
        entriesInfoTrip.date = strAPIDate;
        
        if([[accounts.accountName lowercaseString] isEqual:@"loan"]){
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
            AddAnotherAccountViewController *vc = [sb instantiateViewControllerWithIdentifier:@"AddAnotherAccountViewController"];
            vc.type = @"email";
            entriesInfoTrip.emailIfLoan =@"Loan";
            
            CATransition *applicationLoadViewIn =[CATransition animation];
            [applicationLoadViewIn setDuration:.5f];
            [applicationLoadViewIn setType:kCATransitionReveal];
            [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [[vc.view layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
            vc.companies=self.companies;
            [self.view addSubview:vc.view];
            [self addChildViewController:vc];
        }
        else if([[accounts.accountName lowercaseString] isEqual:@"other"]){
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
            AddAnotherAccountViewController *vc = [sb instantiateViewControllerWithIdentifier:@"AddAnotherAccountViewController"];
            vc.type = @"category";
            vc.groupId = [self.type intValue];
            vc.delegate = self;
            entriesInfoTrip.emailIfLoan =@"atm withdraw";
            
            CATransition *applicationLoadViewIn =[CATransition animation];
            [applicationLoadViewIn setDuration:.5f];
            [applicationLoadViewIn setType:kCATransitionReveal];
            [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[vc.view layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
            vc.companies=self.companies;
            [self.view addSubview:vc.view];
            [self addChildViewController:vc];
        }
        else if([[accounts.accountName lowercaseString] isEqual:@"atm withdraw"])
        {
            //open picker view
            [self showPickerView];
            /*
             BankAccountListViewController *vc = [sb2 instantiateViewControllerWithIdentifier:@"BankAccountListViewController"];
             entriesInfoTrip.emailIfLoan =@"atm withdraw";
             NSLog(@"%@",entriesInfoTrip.creditAccount);
             vc.entriesTemp = entriesInfoTrip;
             vc.type = self.type;
             vc.companies = self.companies;
             [self.view addSubview:vc.view];
             [self addChildViewController:vc];
             */
        }
        else{
            finalTransactionViewController.companies = self.companies;
            finalTransactionViewController.type = self.type;
            finalTransactionViewController.entriesTemp = entriesInfoTrip;
            [self.navigationController pushViewController:finalTransactionViewController animated:YES];
        }
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter amount first." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark UICollectionViewFlowLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(78, 101);
    return size;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [txtEnterAmount resignFirstResponder];
}
- (IBAction)doneButtonAction:(id)sender {
    [self dismissPicker];
    // NSString *date  =[NSString stringWithFormat:@"%@",pickerView.date];
    // NSArray *strArry = [date componentsSeparatedByString:@" "];
    
    //convert date to string
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    strAPIDate = [formatter stringFromDate:pickerView.date];
    
    [formatter setDateFormat:@"dd MMM yyyy"];
    NSString *strSchedule = [formatter stringFromDate:pickerView.date];
    
    [btnDate setTitle:strSchedule forState:UIControlStateNormal];
    
    //[btnDate setTitle:[strArry objectAtIndex:0] forState:UIControlStateNormal];
    
}
-(void)dismissPicker{
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        viewPicker.frame  = CGRectMake(8, 600, 304,194);
        
    } completion:^(BOOL finished) {
        
    }];
    viewPicker.hidden = YES;
    
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
- (IBAction)cancelButtonAction:(id)sender {
    [self dismissPicker];
}

- (IBAction)dateButtonAction:(id)sender {
    CGFloat y =374;
    CGFloat x =8;
    if (IS_IPHONE_4) {
        y=318;
    }
    else if(IS_IPHONE_6){
        y = 473;
        x=35;
    }
    else if(IS_IPHONE_6PLUS){
        y = 573;
        x=54.5;
    }
    //CGFloat center = self.view.center.y;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        viewPicker.frame  = CGRectMake(x, y, 304,194);
        //viewPicker.center = CGPointMake(self.view.center.x, 400);
        
    } completion:^(BOOL finished) {
        
    }];
    viewPicker.hidden = NO;
}

- (IBAction)backButtonAction:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)refreshList{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
    //add arrdata into main table data array
    arrTableData = [NSMutableArray array];
    for(Accounts *accounts in arrData){
        NSNumber *grpId =[NSNumber numberWithInt:[self.type intValue]];
        //NSLog(@"%@",accounts.groupId);
        //NSLog(@"%@",grpId);
        //  int loanGrp=2;
        // NSNumber *loanGrpId =[NSNumber numberWithInt:loanGrp];
        int newGrp=4;
        NSNumber *newGrpId =[NSNumber numberWithInt:newGrp];
        if([accounts.groupId isEqual: grpId]||[accounts.groupId isEqual:newGrpId]){
            [arrTableData addObject:accounts];
        }
    }
    pickerView.datePickerMode= UIDatePickerModeDate;
    [collectionView reloadData];
    
    //add arrdata into main table data array
    arrPickerData = [NSMutableArray array];
    for(Accounts *accounts in arrData){
        // NSLog(@"%@",accounts.groupId);
        if([accounts.groupId isEqual: [NSNumber numberWithInt:3] ]&& (![[accounts.accountName lowercaseString] isEqual:@"cash"])){
            [arrPickerData addObject:accounts];
        }
    }
}
-(void)refreshListWithAccount:(Accounts *)account{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
    //add arrdata into main table data array
    arrTableData = [NSMutableArray array];
    for(Accounts *accounts in arrData){
        NSNumber *grpId =[NSNumber numberWithInt:[self.type intValue]];
        //NSLog(@"%@",accounts.groupId);
        //NSLog(@"%@",grpId);
        int loanGrp=2;
        NSNumber *loanGrpId =[NSNumber numberWithInt:loanGrp];
        int newGrp=4;
        NSNumber *newGrpId =[NSNumber numberWithInt:newGrp];
        if([accounts.groupId isEqual: grpId]||([accounts.groupId isEqual:loanGrpId]&& [[accounts.accountName lowercaseString] isEqual:@"loan"] )||[accounts.groupId isEqual:newGrpId]){
            [arrTableData addObject:accounts];
        }
    }
    pickerView.datePickerMode= UIDatePickerModeDate;
    [collectionView reloadData];
    
    //add arrdata into main table data array
    arrPickerData = [NSMutableArray array];
    for(Accounts *accounts in arrData){
        // NSLog(@"%@",accounts.groupId);
        if([accounts.groupId isEqual: [NSNumber numberWithInt:3] ]&& (![[accounts.accountName lowercaseString] isEqual:@"cash"])){
            [arrPickerData addObject:accounts];
        }
    }
    
    //    UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
    //    FinalTransactionViewController *finalTransactionViewController = [sb2 instantiateViewControllerWithIdentifier:@"FinalTransactionViewController"];
    //    finalTransactionViewController.companies = self.companies;
    //    Accounts *accounts = account;
    
    //    EntriesTemp * entriesInfoTrip = [[EntriesTemp alloc] init];
    //    NSNumber *amount = [NSNumber numberWithInt:[txtEnterAmount.text floatValue]];
    //
    //    entriesInfoTrip.amount = amount;
    //    entriesInfoTrip.companyId = self.companies.companyId;
    //    entriesInfoTrip.groupId = accounts.groupId;
    //    //NSLog(@"%@",[NSString stringWithFormat:@"%@",accounts.accountId]);
    //    if([self.type isEqual:@"0"]){
    //        entriesInfoTrip.creditAccount =[NSString stringWithFormat:@"%@",accounts.accountId];
    //        entriesInfoTrip.transactionType = [NSNumber numberWithInt:0];
    //    }
    //    else{
    //        entriesInfoTrip.debitAccount =[NSString stringWithFormat:@"%@",accounts.accountId];
    //        entriesInfoTrip.transactionType = [NSNumber numberWithInt:1];
    //    }
    //    //NSLog(@"%@",[NSString stringWithFormat:@"%@",entriesInfoTrip.creditAccount]);
    //
    //    //entriesInfoTrip.date = btnDate.titleLabel.text;
    //    entriesInfoTrip.date = strAPIDate;
    //    finalTransactionViewController.companies = self.companies;
    //    finalTransactionViewController.type = self.type;
    //    finalTransactionViewController.entriesTemp = entriesInfoTrip;
    //    [self.navigationController pushViewController:finalTransactionViewController animated:YES];
}

-(void)emailAdded{
    
}
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{   [txtEnterAmount resignFirstResponder];
//    [self.view endEditing:YES];
//}

#pragma mark Picker View Methods
-(void) showPickerView
{
    picView=[[UIPickerView alloc] initWithFrame:CGRectZero];
    CGRect bounds = [self.view bounds];
    int datePickerHeight = picView.frame.size.height;
    picView.frame = CGRectMake(0, bounds.size.height - (datePickerHeight), picView.frame.size.width, picView.frame.size.height);
    picView.dataSource = self;
    picView.delegate = self;
    [picView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:picView];
    
    //picker view header
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, picView.frame.size.width, 40)];
    [headerView setBackgroundColor:[UIColor colorWithRed:230/255.0f green:103/255.0f blue:61/255.0f alpha:1]];
    //[headerView setBackgroundColor:[UIColor lightGrayColor ]];
    [picView addSubview:headerView];
    
    buttonCancel=[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [buttonCancel setFrame:CGRectMake(5, bounds.size.height - (datePickerHeight), 100, 36)];
    buttonCancel.tag=0;
    [buttonCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonCancel];
    
    buttonDone=[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonDone setTitle:@"Done" forState:UIControlStateNormal];
    [buttonDone setFrame:CGRectMake(self.view.frame.size.width-2-100, bounds.size.height - (datePickerHeight), 100, 36)];
    buttonDone.tag=1;
    [buttonDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonDone addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonDone];
}

//cancel button event
-(void) cancelAction : (UIPickerView *)pc
{
    [pc removeFromSuperview];
    picView.hidden = YES;
    buttonCancel.hidden = btnDone.hidden = YES;
    //[btnSchedule setImage:[UIImage imageNamed:@"sch_off.png"] forState:UIControlStateNormal];
    //lblSchedule.text = @"Schedule";
    //[btnSchedule setTitle:@"Schedule" forState:UIControlStateNormal];
}

//done button event
-(void) doneAction : (UIPickerView *)pc
{
    //NSLog(@"selected atm = %@",selAccName);
    [pc removeFromSuperview];
    picView.hidden = YES;
    buttonCancel.hidden = buttonDone.hidden = YES;
    UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
    FinalTransactionViewController *finalTransactionViewController = [sb2 instantiateViewControllerWithIdentifier:@"FinalTransactionViewController"];
    
    
    EntriesTemp * entriesInfoTrip = [[EntriesTemp alloc] init];
    Accounts *accounts  = accObject;
    if([self.type isEqual:@"0"])
    {
        entriesInfoTrip.creditAccount =[NSString stringWithFormat:@"%@",accounts.accountId];
        entriesInfoTrip.transactionType = [NSNumber numberWithInt:0];
    }
    else{
        entriesInfoTrip.debitAccount =[NSString stringWithFormat:@"%@",accounts.accountId];
        entriesInfoTrip.transactionType = [NSNumber numberWithInt:1];
    }
    entriesInfoTrip.amount=[NSNumber numberWithInt:[txtEnterAmount.text intValue]] ;
    entriesInfoTrip.emailIfLoan =@"atm withdraw";
    entriesInfoTrip.date = strAPIDate;
    
    finalTransactionViewController.companies = self.companies;
    finalTransactionViewController.type = self.type;
    finalTransactionViewController.entriesTemp = entriesInfoTrip;
    [self.navigationController pushViewController:finalTransactionViewController animated:YES];
    
}

//picker view methods
#pragma mark UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrPickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Accounts *account = arrPickerData[row];
    return account.accountName;
    //return @"status";
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    int rowInt = (int)row;
    accObject = arrPickerData[rowInt];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [txtEnterAmount resignFirstResponder];
    }
}
@end
