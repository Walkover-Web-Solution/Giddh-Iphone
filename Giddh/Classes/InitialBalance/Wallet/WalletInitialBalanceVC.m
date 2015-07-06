//
//  WalletInitialBalanceVC.m
//  Giddh
//
//  Created by Admin on 15/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "WalletInitialBalanceVC.h"
#import "BankInitialBalanceVC.h"
#import "ServiceManager.h"
#import "AppDelegate.h"
#import "Accounts.h"

@interface WalletInitialBalanceVC ()

@end

@implementation WalletInitialBalanceVC
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

-(void)cancelNumberPad{
    [txtAmount resignFirstResponder];
    //  numberTextField.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [[ServiceManager sharedManager] addAccountForAuthKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"] andCompanyId:companyId companyName:companyName groupName:@"Assets" accountName:@"Cash" uniqueName:@"" openingBalance:txtAmount.text openingBalanceType:balanceType withCompletionBlock:^(NSDictionary *responce, NSError *error)
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //NSLog(@"response acc = %@",responce);
            NSString *strStatus = [responce valueForKey:@"status"];
            int intStatus = [strStatus intValue];
            
            if (intStatus == 1)
            {
                //update local DB
                AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
                NSManagedObjectContext *context =[appDelegate managedObjectContext];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                [request setEntity:[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context]];
                
                NSError *error = nil;
                NSArray *results = [context executeFetchRequest:request error:&error];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName ==[c] %@",@"Cash"];
                [request setPredicate:predicate];
                NSArray *arrData = [results filteredArrayUsingPredicate:predicate].mutableCopy;
                
                //Update Account
                Accounts *accObj = arrData[0];
                accObj.openingBalance = [NSNumber numberWithDouble:[txtAmount.text doubleValue]];
                
                [context save:&error];
            }
            else
            {
               // NSLog(@"Error message = %@",[responce valueForKey:@"message"]);
            }
           
        }];
    }
     [self.view removeFromSuperview];
}

-(void) showBank
{
    UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
    BankInitialBalanceVC *vc = [sb2 instantiateViewControllerWithIdentifier:@"BankInitialBalanceVC"];
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
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
