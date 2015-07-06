//
//  BankInitialBalanceVC.m
//  Giddh
//
//  Created by Admin on 15/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "BankInitialBalanceVC.h"
#import "WalletInitialBalanceVC.h"
#import "ServiceManager.h"
#import "AppDelegate.h"
#import "Accounts.h"

@interface BankInitialBalanceVC ()

@end

@implementation BankInitialBalanceVC
@synthesize companyId,companyName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //set content view
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
    
    [self checkWalletCash];
    
    //set toolbar for numberpad
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           nil];
    [numberToolbar sizeToFit];
    txtAmount.inputAccessoryView = numberToolbar;
    
}

-(void)checkWalletCash
{
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *contextCash = [appDelegate managedObjectContext];
    NSFetchRequest *requestCash = [[NSFetchRequest alloc] initWithEntityName:@"Accounts"];
    [requestCash setPredicate:[NSPredicate predicateWithFormat:@"accountName ==[c] %@",@"Cash"]];
    NSError *errorCash = nil;
    NSArray *arrCash = [contextCash executeFetchRequest:requestCash error:&errorCash];
    Accounts *objectAcc = arrCash[0];
    int walletCash = [objectAcc.openingBalance intValue];
    if (walletCash == 0)
    {
        [self showWalletScreen];
    }
}

-(void)cancelNumberPad{
    [txtAmount resignFirstResponder];
    //  numberTextField.text = @"";
}


-(void) showWalletScreen
{
    UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
    WalletInitialBalanceVC *vc = [sb2 instantiateViewControllerWithIdentifier:@"WalletInitialBalanceVC"];
    vc.companyId = companyId;
    vc.companyName = companyName;
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
}

-(void)doneButtonAction:(id)sender
{
    if (txtAmount.text.length > 0)
    {
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText=@"Processing..";
        int intBalance = [txtAmount.text intValue];
        int balanceType;
        if (intBalance < 0)
        {
            balanceType = 2;
        } else {
            balanceType = 1;
        }
        [[ServiceManager sharedManager] addAccountForAuthKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"] andCompanyId:companyId companyName:companyName groupName:@"Assets" accountName:txtBankName.text uniqueName:@"" openingBalance:txtAmount.text openingBalanceType:balanceType withCompletionBlock:^(NSDictionary *responce, NSError *error)
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
                 [accountObj setValue:txtBankName.text forKey:@"accountName"];
                 [accountObj setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"userEmail"] forKey:@"emailId"];
                 [accountObj setValue:[NSNumber numberWithDouble:[txtAmount.text doubleValue]] forKey:@"openingBalance"];
                 [accountObj setValue:uniqueName forKey:@"uniqueName"];
                 NSError *error;
                 if (![context save:&error]) {
                    // NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                 }
             }
             else
             {
                 [[[UIAlertView alloc] initWithTitle:[responce valueForKey:@"message"] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                 //NSLog(@"Error message = %@",[responce valueForKey:@"message"]);
             }
             
         }];
    }
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
