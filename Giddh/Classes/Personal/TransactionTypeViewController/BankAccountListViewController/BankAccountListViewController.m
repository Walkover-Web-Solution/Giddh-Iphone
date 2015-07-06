//
//  BankAccountListViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 29/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "BankAccountListViewController.h"
#import "AppDelegate.h"
#import "Accounts.h"
#import "FinalTransactionViewController.h"
@interface BankAccountListViewController (){
    NSMutableArray * arrTableData;
}
- (IBAction)closeButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BankAccountListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrTableData = [NSMutableArray array];
    [self refreshList];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [self.view removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)refreshList{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
    //add arrdata into main table data array
    arrTableData = [NSMutableArray array];
    for(Accounts *accounts in arrData){
        //NSLog(@"%@",accounts.groupId);
        if([accounts.groupId isEqual: [NSNumber numberWithInt:3]]){
            [arrTableData addObject:accounts];
        }
    }
    [self.tableView reloadData];
}

#pragma mark UITableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrTableData.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"dropDwn";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cell.contentView.backgroundColor = [UIColor clearColor];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textAlignment =NSTextAlignmentCenter;
    }
    Accounts *account = arrTableData[indexPath.row];
    cell.textLabel.text =account.accountName;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
    FinalTransactionViewController *finalTransactionViewController = [sb2 instantiateViewControllerWithIdentifier:@"FinalTransactionViewController"];
    Accounts * accounts  = arrTableData[0];
    if([self.type isEqual:@"0"]){
        self.entriesTemp.creditAccount =[NSString stringWithFormat:@"%@",accounts.accountId];
        self.entriesTemp.transactionType = [NSNumber numberWithInt:0];
    }
    else{
        self.entriesTemp.debitAccount =[NSString stringWithFormat:@"%@",accounts.accountId];
        self.entriesTemp.transactionType = [NSNumber numberWithInt:1];
    }
    
    finalTransactionViewController.companies = self.companies;
    finalTransactionViewController.type = self.type;
    finalTransactionViewController.entriesTemp = self.entriesTemp;
    [self.navigationController pushViewController:finalTransactionViewController animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)closeButtonAction:(id)sender {
    [self.view removeFromSuperview];
}
@end
