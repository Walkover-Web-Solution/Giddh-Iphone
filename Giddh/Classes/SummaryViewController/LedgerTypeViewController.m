//
//  LedgerTypeViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 19/06/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "LedgerTypeViewController.h"
#import "LedgerEntryViewController.h"
#import "Accounts.h"
#import "AppDelegate.h"
@interface LedgerTypeViewController (){
    NSArray *arrAccounts;

    __weak IBOutlet UILabel *lblHeader;
    __weak IBOutlet UIButton *btnRecieving;
    __weak IBOutlet UIButton *btnGiving;
}
- (IBAction)RecievingButtonAction:(id)sender;
- (IBAction)givingButoonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

@end

@implementation LedgerTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrAccounts = [NSArray array];
    [self getAccounts];
    
    Accounts *account = [self getAccountNameForAccountId:[NSNumber numberWithInt:[self.accountId intValue]]];
    lblHeader.text = account.accountName;

    //NSLog(@"%@",account.accountName);
    [btnGiving setTitle:[NSString stringWithFormat:@"Giving %@",account.accountName] forState:UIControlStateNormal];
    [btnRecieving setTitle:[NSString stringWithFormat:@"Receiving %@",account.accountName] forState:UIControlStateNormal];

    // Do any additional setup after loading the view.
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(Accounts*)getAccountNameForAccountId:(NSNumber*)accountId{
    for(Accounts *account in arrAccounts){
      if([account.accountId isEqual:accountId])
            return account;
    }
    return nil;
}

- (IBAction)RecievingButtonAction:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
    LedgerEntryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LedgerEntryViewController"];
    vc.companies = self.companies;
    vc.type = @"0";
    vc.accountId =self.accountId;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)givingButoonAction:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
    LedgerEntryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LedgerEntryViewController"];
    vc.companies = self.companies;
    vc.type = @"1";
    vc.accountId =self.accountId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
