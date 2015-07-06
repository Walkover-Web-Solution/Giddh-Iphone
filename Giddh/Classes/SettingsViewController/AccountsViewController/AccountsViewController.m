//
//  AccountsViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 19/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AccountsViewController.h"
#import "AppDelegate.h"
#import "Accounts.h"
#import "Entries.h"
#import "ServiceManager.h"
@interface AccountsViewController (){
    NSMutableArray *arrAccounts;
    NSArray *arrEntries;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrAccounts = [NSMutableArray array];
    arrEntries = [NSArray array];
    [self getAllEntries];
    [self getAccounts];
    [self.tableView reloadData];

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
    NSArray *temp=[[context executeFetchRequest:request error:&error]mutableCopy];
    arrAccounts = [NSMutableArray array];
    for(Accounts *accounts in temp){
        int accountId =17;
        NSString * storedAccountId = [NSString stringWithFormat:@"%@",accounts.accountId];
        if([storedAccountId intValue]>accountId){
            [arrAccounts addObject:accounts];
        }
    }
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
#pragma mark UITableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return arrAccounts.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"PinLogsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //int count = self.arrTableData.count;
    
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        //cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //cell.contentView.backgroundColor = [UIColor clearColor];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    Accounts *accounts = arrAccounts[indexPath.row];
    cell.textLabel.text = accounts.accountName;
      return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
                    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
                    NSManagedObjectContext *context=[appDelegate managedObjectContext];
                    
                    [context deleteObject:account];
                    
                    NSError *saveError = nil;
                    [context save:&saveError];
                    [self getAccounts];
                }
               
                [self.tableView reloadData];

            }];
            [self.tableView reloadData];

        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hold On!!" message:@"Account is used for some entry delete the entry first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
//        if(account.accountId> [NSNumber numberWithInt:16]){
//            if([self chaeckIfEntryExistForAccount:account]){
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hold On!!" message:@"Account is used for some entry delete the entry first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//            else{
//               // [ServiceManager sharedManager];
//            }
//
//        }
//        else{
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hold On!!" message:@"Account is default cant delete" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
//
//        }
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


@end
