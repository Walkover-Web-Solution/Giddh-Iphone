//
//  AddAnotherAccountViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 21/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AddAnotherAccountViewController.h"
#import "AppDelegate.h"
#import "Accounts.h"
#import "FinalTransactionViewController.h"
@interface AddAnotherAccountViewController ()<UITextFieldDelegate>{
    
    __weak IBOutlet UILabel *lblHeaderDetail;
    __weak IBOutlet UILabel *lblHeader;
    __weak IBOutlet UIView *contentView;
    
    __weak IBOutlet UIButton *btnCancel;
    __weak IBOutlet UIButton *btnDone;
    __weak IBOutlet UITextField *txtEmailOrCategory;
    __weak IBOutlet UILabel *lblWarning;
    NSArray *arrAccountList;
}
- (IBAction)doneButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

@end

@implementation AddAnotherAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrAccountList =[NSArray array];

    [self accountList];
    if([self.type isEqual:@"category"]){
        lblHeader.text = @"Enter Category name";
        lblHeaderDetail.text = @"This category will be added in your List";
    }else
    {
        lblHeader.text = @"Enter Email";
        lblHeaderDetail.text = @"Email will be saved for future";
    }
    contentView.layer.cornerRadius = 4.0f;
    contentView.alpha =1;
    contentView.layer.cornerRadius = 6.0f;
    contentView.layer.borderWidth = .5f;
    contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect: contentView.bounds].CGPath;
    contentView.layer.masksToBounds = NO;
    contentView.layer.shadowOffset = CGSizeMake(5, 5);
    contentView.layer.shadowRadius = 5;
    contentView.layer.shadowOpacity = 0.5;
    contentView.layer.shouldRasterize = YES;
    contentView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    // Do any additional setup after loading the view.
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
-(BOOL)checkIfSameNameOfAmountExist{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.accountName beginswith[c] %@ ", txtEmailOrCategory.text];
    NSArray *arrData = [arrAccountList filteredArrayUsingPredicate:predicate].mutableCopy;
    if(arrData.count == 0)
        return NO;
    else
        return YES;

}
- (IBAction)doneButtonAction:(id)sender {
    if (![self checkIfSameNameOfAmountExist]) {
        if(txtEmailOrCategory.text.length>0){
            if([self.type isEqual:@"category"]){
                [self addAccount];
                [self.view removeFromSuperview];

            }
            else{
                NSString *emailid = txtEmailOrCategory.text;
                NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
                BOOL myStringMatchesRegEx=[emailTest evaluateWithObject:emailid];
                if(myStringMatchesRegEx){
                    UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
                    FinalTransactionViewController *finalTransactionViewController = [sb2 instantiateViewControllerWithIdentifier:@"FinalTransactionViewController"];
//                    Accounts * accounts  = arrTableData[0];
//                    if([self.type isEqual:@"0"]){
//                        self.entriesTemp.creditAccount =[NSString stringWithFormat:@"%@",accounts.accountId];
//                        self.entriesTemp.transactionType = [NSNumber numberWithInt:0];
//                    }
//                    else{
//                        self.entriesTemp.debitAccount =[NSString stringWithFormat:@"%@",accounts.accountId];
//                        self.entriesTemp.transactionType = [NSNumber numberWithInt:1];
//                    }
                    self.entriesTemp.email = txtEmailOrCategory.text;
                    finalTransactionViewController.companies = self.companies;
                    finalTransactionViewController.type = self.type;
                    finalTransactionViewController.entriesTemp = self.entriesTemp;
                    [self.navigationController pushViewController:finalTransactionViewController animated:YES];

                }
                else{
                    lblWarning.text = [NSString stringWithFormat:@"Please enter valid %@",self.type];

                }
            }
        }
        else{
            lblWarning.text = [NSString stringWithFormat:@"Please enter valid %@",self.type];
        }

    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry!!" message:@"A category with same name already exists." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.view removeFromSuperview];

}

-(void)addAccount{
    NSMutableArray *arrAccountId = [NSMutableArray array];
    for(Accounts *accounts in arrAccountList){
        [arrAccountId addObject:accounts.accountId];
    }
    int max = [[arrAccountId valueForKeyPath:@"@max.intValue"] intValue];
    //NSLog(@"%d",max);
    max++;
    //NSLog(@"%d",max);

    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSError *error = nil;
    NSManagedObject *newAccount;
    newAccount = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Accounts"
                  inManagedObjectContext:context];
    NSNumber *groupId = [NSNumber numberWithInt:self.groupId];
    NSString *openingBalanceNum = @"0";
    NSNumber *openingBalance = [NSNumber numberWithInt:[openingBalanceNum floatValue]];
    NSNumber *accountId = [NSNumber numberWithInt:max];

    [newAccount setValue:txtEmailOrCategory.text forKeyPath:@"accountName"];
    [newAccount setValue:self.companies.emailId forKeyPath:@"emailId"];
    [newAccount setValue:groupId forKeyPath:@"groupId"];
    [newAccount setValue:openingBalance forKeyPath:@"openingBalance"];
    [newAccount setValue:@"" forKeyPath:@"uniqueName"];
    [newAccount setValue:accountId forKeyPath:@"accountId"];
    //NSLog(@"newAccount %@",newAccount);
    [context insertObject:newAccount];
    [context save:&error];
    Accounts *account ;
    account.accountId = accountId;
    account.accountName = txtEmailOrCategory.text;
    account.emailId = self.companies.emailId;
    account.groupId = groupId;
    account.openingBalance = openingBalance;
    account.uniqueName = @"";

    [self.delegate refreshListWithAccount:account];

}
-(void)accountList{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
    arrAccountList = arrData;
    //add arrdata into main table data array
    }

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(txtEmailOrCategory.text.length>0||string.length>0){
        lblWarning.text = @"";
    }
    
    return YES;
}
@end
