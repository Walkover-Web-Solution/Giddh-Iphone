//
//  SummaryViewController.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 30/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "SummaryViewController.h"
#import "SummaryTableViewCell.h"
#import "AppDelegate.h"
#import "Accounts.h"
#import "Entries.h"
#import "SummaryAccount.h"
#import "SummaryGroup.h"
#import "SummaryDetailViewController.h"
#import "RNFrostedSidebar.h"
#import "MSCMoreOptionTableViewCell.h"
#import "MSCMoreOptionTableViewCellDelegate.h"
#import "TripHomeVC.h"
#import "SettingsViewController.h"
#import "BTSimpleSideMenu.h"
#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"
#import "PersonalHomeVC.h"
#import "UserHomeVC.h"
#import "AppData.h"
#import "ServiceManager.h"
#import "TripInfo.h"
#import "CDSideBarController.h"
#import "DeletedEntries.h"
static NSString *const menuCellIdentifier = @"rotationCell";
@interface SummaryViewController ()<UITableViewDataSource,MSCMoreOptionTableViewCellDelegate,RNFrostedSidebarDelegate,BTSimpleSideMenuDelegate,UITableViewDelegate,YALContextMenuTableViewDelegate>{
    NSArray *arrTableData;
    NSArray *arrAccounts;
    NSArray *arrEntries;
    NSArray *arrSummaryGroups;
    CDSideBarController *sideBar;
    NSArray *arrDeletedEntries;
    
}
@property(nonatomic)BTSimpleSideMenu *sideMenu;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;
@property (nonatomic, strong) NSMutableIndexSet *optionIndices;

- (IBAction)menuButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) YALContextMenuTableView * contextMenuTableView;

@end

@implementation SummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"test performed for git");
    NSLog(@" performed for git");

    _sideMenu.delegate = self;
    [self initiateMenuOptions];
    [self syncAccounts];
    [self syncEntryInfo];
    [self syncAllNullEntries];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstPageCompany"])
        [[AppData sharedData]syncCompanyList];
    NSArray *arrTemp =[NSArray array];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToCompany) name:@"goToCompanyNotification" object:nil];
    
    [self syncTripList];
   
    arrEntries = [NSArray array];
    self.optionIndices = [NSMutableIndexSet indexSetWithIndex:1];
    [self initiateMenuOptions];
    arrAccounts = [NSArray array];
    [self getAccounts];
    [self getAllEntries];
    [self sortAllData];
    self.contextMenuTableView.bounces = NO;
    self.contextMenuTableView.scrollEnabled=NO;
    arrDeletedEntries = [NSArray array];
    [self getDeletedEntries];
    // Do any additional setup after loading the view.
}
//-(void)goToCompany{
//    UIViewController *presentingVC = [self presentingViewController];
//    [self dismissViewControllerAnimated:NO completion:
//     ^{
//         [presentingVC presentViewController:navController animated:YES completion:nil];
//     }];
//
//}

-(void)viewWillAppear:(BOOL)animated{
    [self getAccounts];
    [self getAllEntries];
    [self sortAllData];
    [self sortAllData];
    [self.tableView reloadData];
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
-(void)getDeletedEntries{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"DeletedEntries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrDeletedEntries=[[context executeFetchRequest:request error:&error]mutableCopy];
}

-(void)getAllEntries{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    arrEntries = [[context executeFetchRequest:request error:&error]mutableCopy];
}

#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([tableView isEqual:self.tableView]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Liability"];
        NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
        SummaryGroup *sumGrp = arrData[0];
        NSArray *arrLiabilityData =sumGrp.accounts;
        
        // SummaryAccount *summaryAccount = arrLiabilityData[0];
        if(arrLiabilityData.count<=0){
            return 2;
            
        }
        
        return 3;
        
    }
    return 1;
}


-(void)dismissPreviousView{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)sidebar:(RNFrostedSidebar *)sidebar didEnable:(BOOL)itemEnabled itemAtIndex:(NSUInteger)index {
    if (itemEnabled) {
        [self.optionIndices addIndex:index];
    }
    else {
        [self.optionIndices removeIndex:index];
    }
}

-(void)sortAllData{
    NSMutableArray *arrSummaryGroup = [NSMutableArray array];
    NSString *grpName;
    for(int i=0 ;i<4;i++){
        if(i==0){
            grpName = @"Income";
            
        }
        else if(i==1){
            grpName =@"Expense";
            
            
        }
        else if (i==2){
            grpName =@"Liability";
        }
        else if (i==3){
            
            grpName =@"Assets";
            
        }
        //sgc obj
        NSMutableArray *arrAccountList =[NSMutableArray array];
        for(Accounts *account in arrAccounts){
            if([account.groupId isEqual:[NSNumber numberWithInt:i]]){
                [arrAccountList addObject:account];
            }
        }
        SummaryGroup *summaryGroup = [[SummaryGroup alloc]init];
        summaryGroup.groupName = grpName;
        summaryGroup.overAllSum = 0;
        NSMutableArray *arrSummaryAccounts = [NSMutableArray array];
        
        for(Accounts *account in arrAccountList){
            SummaryAccount *summaryAccount = [[SummaryAccount alloc]init];
            double creditBal= 0;
            double debitBal= 0;
            double mainBal = 0;
            for(Entries *entries in arrEntries){
                if([entries.creditAccount isEqual:account.accountId]){
                    creditBal = creditBal + [entries.amount doubleValue];
                }
                if([entries.debitAccount isEqual:account.accountId]){
                    debitBal = debitBal + [entries.amount doubleValue];
                }
            }
            mainBal = debitBal - creditBal + [account.openingBalance doubleValue];
            summaryGroup.overAllSum = summaryGroup.overAllSum + mainBal;
            summaryAccount.groupName = grpName;
            summaryAccount.name = account.accountName;
            summaryAccount.sum = mainBal;
            summaryAccount.accountId = [account.accountId stringValue];
            if(![[summaryAccount.name lowercaseString] isEqual:@"loan"]){
                [arrSummaryAccounts addObject:summaryAccount];
                
            }
            summaryGroup.accounts = arrSummaryAccounts;
        }
        [arrSummaryGroup addObject:summaryGroup];
    }
    arrSummaryGroups =arrSummaryGroup;
    [self.tableView reloadData];
}

- (IBAction)menuButtonAction:(id)sender {
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = .05f;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    [self.contextMenuTableView showInView:self.navigationController.view withEdgeInsets:UIEdgeInsetsZero animated:YES];
    
}
- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(NSString*)formatToTwoDigitValueForNumber:(double)number{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundCeiling];
    
    NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithDouble:number]];
    return numberString;
}
#pragma -mark BTSimpleSideMenuDelegate
-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu didSelectItemAtIndex:(NSInteger)index {
    //NSLog(@"Tapped item at index %lu",(unsigned long)index);
    if (index == 0) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
        TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
        vc.globalCompanyId = [self.companies.companyId intValue];
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //navController.navigationBarHidden =YES;
        vc.companies = self.companies;
        
        [self presentViewController:navController animated:YES completion:nil];
        
        // [sidebar dismissAnimated:YES completion:nil];
    }
    if(index == 1){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        SettingsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        vc.globalCompanyId = [self.companies.companyId intValue];
        vc.globalCompanyName = self.companies.companyName;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //navController.navigationBarHidden =YES;
        [self presentViewController:navController animated:YES completion:nil];
        
        //  [sidebar dismissAnimated:YES completion:nil];
    }
    if (index == 2) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
        SummaryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SummaryViewController"];
        //vc.globalCompanyId = [self.companies.companyId intValue];
        vc.companies =self.companies;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        navController.navigationBarHidden =YES;
        [self presentViewController:navController animated:YES completion:nil];
        
        //  [sidebar dismissAnimated:YES completion:nil];
    }
    if (index == 3) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
#pragma mark - initiateMenuOptions

- (void)initiateMenuOptions {
    self.menuTitles = @[@"",
                        @"Trip",
                        @"Settings",
                        @"Transaction",
                        @"Company",
                        ];
    
    self.menuIcons = @[[UIImage imageNamed:@"icn_close"],
                       [UIImage imageNamed:@"trip_icon1"],
                       [UIImage imageNamed:@"settings_icon1"],
                       [UIImage imageNamed:@"icon_Transaction"],
                       [UIImage imageNamed:@"company_icon1"],
                       ];
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.tableView]){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
        SummaryDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SummaryDetailViewController"];
        vc.companies = self.companies;
        if(indexPath.section==0){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Assets"];
            NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
            SummaryGroup *sumGrp = arrData[0];
            NSArray *arrAssetsData =sumGrp.accounts;
            if(indexPath.row == arrAssetsData.count){
            }
            else{
                SummaryAccount *summaryAccount = arrAssetsData[indexPath.row];
                vc.accountId = summaryAccount.accountId;
                vc.accountName = summaryAccount.name;
                vc.header = summaryAccount.name;
                [self.navigationController pushViewController:vc animated:YES];
                //vc.globalCompanyId = [self.companies.companyId intValue];
            }
        }
        else if (indexPath.section == 1){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Liability"];
            NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
            SummaryGroup *sumGrp = arrData[0];
            NSArray *arrLiabilityData =sumGrp.accounts;
            // SummaryAccount *summaryAccount = arrLiabilityData[0];
            
            
            if(arrLiabilityData.count<=0){
                if(indexPath.row == 0){
                    vc.type = @"Income";
                    vc.header = @"Income";
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }
                else if(indexPath.row == 1){
                    vc.type = @"Expense";
                    vc.header = @"Expense";
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            }
            else{
                if(indexPath.row == arrLiabilityData.count){
                }
                else{
                    SummaryAccount *summaryAccount = arrLiabilityData[indexPath.row];
                    vc.accountId = summaryAccount.accountId;
                    vc.header = summaryAccount.name;
                    vc.accountName = summaryAccount.name;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            }
            
        }
        else{
            if(indexPath.row == 0){
                vc.type = @"Income";
                vc.header = @"Income";
                [self.navigationController pushViewController:vc animated:YES];
                
            }
            else if(indexPath.row == 1){
                vc.type = @"Expense";
                vc.header = @"Expense";
                [self.navigationController pushViewController:vc animated:YES];
            }
            else{
                
            }
        }
    }
    else{
        UIViewController *presentingVC = [self presentingViewController];
        
        if (indexPath.row == 1) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Trip" bundle:nil];
            TripHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"TripHomeVC"];
            vc.globalCompanyId = [self.companies.companyId intValue];
            vc.companies = self.companies;
            
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            NSString *pagetype = [[NSUserDefaults standardUserDefaults]valueForKey:@"firstPageType"];
            if([pagetype isEqual:@"summary"]){
                [self presentViewController:navController animated:YES completion:nil];
            }
            else{
                [self dismissViewControllerAnimated:NO completion:
                 ^{
                     [presentingVC presentViewController:navController animated:YES completion:nil];
                 }];
            }
            
            // [self presentViewController:navController animated:YES completion:nil];
        }
        if(indexPath.row == 2){
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
            SettingsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            vc.globalCompanyId = [self.companies.companyId intValue];
            vc.globalCompanyName = self.companies.companyName;
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            vc.companies = self.companies;
            //navController.navigationBarHidden =YES;
            NSString *pagetype = [[NSUserDefaults standardUserDefaults]valueForKey:@"firstPageType"];
            if([pagetype isEqual:@"summary"]){
                [self presentViewController:navController animated:YES completion:nil];
            }
            else{
                // [[NSNotificationCenter defaultCenter] postNotificationName:@"goToCompanyNotification" object:self];
                
                [self dismissViewControllerAnimated:NO completion:
                 ^{
                     [presentingVC presentViewController:navController animated:YES completion:nil];
                 }];
            }
        }
        //        if (index == 2) {
        //            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
        //            SummaryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SummaryViewController"];
        //            //vc.globalCompanyId = [self.companies.companyId intValue];
        //            vc.companies =self.companies;
        //            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
        //            navController.navigationBarHidden =YES;
        //            [self presentViewController:navController animated:YES completion:nil];
        //
        //            [sidebar dismissAnimated:YES completion:nil];
        //        }
        if(indexPath.row == 3){
//            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
//            PersonalHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"PersonalHomeVC"];
//            vc.companies =self.companies;
//            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
//            navController.navigationBarHidden =YES;
            NSString *pagetype = [[NSUserDefaults standardUserDefaults]valueForKey:@"firstPageType"];
//            if([pagetype isEqual:@"summary"]){
//                [self presentViewController:navController animated:YES completion:nil];
//            }
//            else{
//                [presentingVC dismissViewControllerAnimated:YES completion:nil];
//                     }
            
            if([pagetype isEqual:@"summary"]){
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
                PersonalHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"PersonalHomeVC"];
                vc.companies =self.companies;
                UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
                
                navController.navigationBarHidden =YES;
                if([self presentingViewController]){
                    NSLog(@"presentingVC");
                    [self dismissViewControllerAnimated:NO completion:
                     ^{
                         [presentingVC presentViewController:navController animated:YES completion:nil];
                     }];
                    
                }
                else{
                    [self presentViewController:navController animated:YES completion:nil];
                    
                }

            }
            else{
                [self dismissViewControllerAnimated:YES completion:nil];                
                               //            if([[self presentingViewController] presentedViewController] == self)
                //                NSLog(@"presentedViewController");
                //            [self dismissViewControllerAnimated:NO completion:
                //             ^{
                //                 [presentingVC presentViewController:navController animated:YES completion:nil];
                //             }];
            }

        }
        if (indexPath.row == 4) {
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstPageCompany"]) {
                [self dismissViewControllerAnimated:NO completion:
                 ^{
                     [presentingVC dismissViewControllerAnimated:YES completion:nil];
                 }];
            }
            else{
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UserHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"UserHomeVC"];
                UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
                navController.navigationBarHidden =NO;
                
                [self presentViewController:navController animated:YES completion:NULL];
            }
        }
        
        [tableView dismisWithIndexPath:indexPath];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.tableView]){
        return 50;
    }
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableView isEqual:self.tableView]){
        if(section == 0){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Assets"];
            NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
            SummaryGroup *sumGrp = arrData[0];
            return sumGrp.accounts.count+1;
        }
        else if (section == 1){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Liability"];
            NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
            SummaryGroup *sumGrp = arrData[0];
            NSArray *arrLiabilityData =sumGrp.accounts;
            if(arrLiabilityData.count<=0){
                return 3;
                
            }
            else{
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Liability"];
                NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
                SummaryGroup *sumGrp = arrData[0];
                if(sumGrp.accounts.count==1)
                    return sumGrp.accounts.count;
                
                else
                    return sumGrp.accounts.count+1;
            }
            
            
        }
        else if(section == 2)
            return 3;
    }
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Companies"];
    NSArray *arrCompanies = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if(arrCompanies.count==1){
        return self.menuTitles.count-1;
        
    }
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.tableView]){
        
        static NSString *cellIdentifier = @"SummaryCell";
        MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[MSCMoreOptionTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //  cell.delegate = self;
        }
        cell.clipsToBounds = YES;
        
        if(indexPath.section==0){
            //   [self.tableView setEditing:NO];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Assets"];
            NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
            SummaryGroup *sumGrp = arrData[0];
            NSArray *arrAssetsData =sumGrp.accounts;
            if(indexPath.row == arrAssetsData.count){
                cell.textLabel.text = @"";
                double value = sumGrp.overAllSum;
                cell.detailTextLabel.textColor = [UIColor colorWithRed:9.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
                
                if(value<0){
                    value = value*-1;
                    cell.detailTextLabel.textColor = [UIColor redColor];
                    
                }
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                cell.textLabel.textColor = [UIColor darkGrayColor];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                
            }
            else{
                //[self.tableView setEditing:NO];
                
                SummaryAccount *summaryAccount = arrAssetsData[indexPath.row];
                cell.textLabel.text = summaryAccount.name;
                double value = summaryAccount.sum;
                cell.detailTextLabel.textColor = [UIColor blackColor];
                
                if(value<0){
                    value = value*-1;
                    cell.detailTextLabel.textColor = [UIColor redColor];
                    
                }
                cell.textLabel.textColor = [UIColor darkGrayColor];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
                
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
            }
            return cell;
        }
        else if (indexPath.section == 1){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Liability"];
            NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
            SummaryGroup *sumGrp = arrData[0];
            NSArray *arrLiabilityData =sumGrp.accounts;
            //SummaryAccount *summaryAccount = arrLiabilityData[0];
            
            if(arrLiabilityData.count<=0){
                //
                if(indexPath.row ==0){
                    
                    for(SummaryGroup *summaryGrp in arrSummaryGroups){
                        if([summaryGrp.groupName isEqual:@"Income"]){
                            cell.textLabel.text = @"Income";
                            double value = summaryGrp.overAllSum;
                            if(value<0){
                                value = value*-1;
                            }
                            
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                            cell.textLabel.textColor = [UIColor darkGrayColor];
                            cell.detailTextLabel.textColor = [UIColor colorWithRed:9.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
                        }
                    }
                    
                }
                else if(indexPath.row ==1){
                    for(SummaryGroup *summaryGrp in arrSummaryGroups){
                        if([summaryGrp.groupName isEqual:@"Expense"]){
                            cell.textLabel.text = @"Expense";
                            double value = summaryGrp.overAllSum;
                            if(value<0){
                                value = value*-1;
                            }
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                            cell.textLabel.textColor = [UIColor darkGrayColor];
                            cell.detailTextLabel.textColor = [UIColor redColor];
                            cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
                        }
                        
                    }
                    
                }
                else{
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    double incomeBal = 0.0;
                    double ExpenseBal =0.0;
                    for(SummaryGroup *summaryGrp in arrSummaryGroups){
                        if([summaryGrp.groupName isEqual:@"Expense"]){
                            ExpenseBal = summaryGrp.overAllSum;
                        }
                        if([summaryGrp.groupName isEqual:@"Income"]){
                            incomeBal = summaryGrp.overAllSum;
                        }
                        double valueIncome = incomeBal;
                        if(valueIncome<0){
                            valueIncome = valueIncome*-1;
                        }
                        double valueExpence = ExpenseBal;
                        if(valueExpence<0){
                            valueExpence = valueExpence*-1;
                        }
                        double lossOrProfit = valueIncome-valueExpence;
                        if (lossOrProfit > 0)
                        {
                            // do positive stuff
                            double value = lossOrProfit;
                            if(value<0){
                                value = value*-1;
                            }
                            
                            cell.textLabel.text = @"Profit";
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                        }
                        else if (lossOrProfit == 0)
                        {
                            // do zero stuff
                            double value = lossOrProfit;
                            if(value<0){
                                value = value*-1;
                            }
                            cell.textLabel.text = @"";
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                        }
                        else
                        {
                            double value = lossOrProfit;
                            if(value<0){
                                value = value*-1;
                            }
                            // do negative stuff
                            cell.textLabel.text = @"Loss";
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                        }
                        cell.detailTextLabel.textColor = [UIColor blackColor];
                        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
                        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
                        
                    }
                    
                }
                
            }
            else{
                if(indexPath.row == arrLiabilityData.count){
                    cell.textLabel.text = @"";
                    double value = sumGrp.overAllSum;
                    if(value<0){
                        value = value*-1;
                    }
                    
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                    cell.detailTextLabel.textColor = [UIColor colorWithRed:9.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                else{
                    SummaryAccount *summaryAccount = arrLiabilityData[indexPath.row];
                    cell.textLabel.text = summaryAccount.name;
                    double value = summaryAccount.sum;
                    if(value<0){
                        value = value*-1;
                    }
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                    
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                }
                
                
                
            }
        }
        else if(indexPath.section ==2){
            if(indexPath.row ==0){
                
                for(SummaryGroup *summaryGrp in arrSummaryGroups){
                    if([summaryGrp.groupName isEqual:@"Income"]){
                        cell.textLabel.text = @"Income";
                        double value = summaryGrp.overAllSum;
                        if(value<0){
                            value = value*-1;
                        }
                        
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                        cell.textLabel.textColor = [UIColor darkGrayColor];
                        cell.detailTextLabel.textColor = [UIColor colorWithRed:9.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
                    }
                }
                
            }
            else if(indexPath.row ==1){
                for(SummaryGroup *summaryGrp in arrSummaryGroups){
                    if([summaryGrp.groupName isEqual:@"Expense"]){
                        cell.textLabel.text = @"Expense";
                        double value = summaryGrp.overAllSum;
                        if(value<0){
                            value = value*-1;
                        }
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                        cell.textLabel.textColor = [UIColor darkGrayColor];
                        cell.detailTextLabel.textColor = [UIColor redColor];
                        
                        
                    }
                    
                }
                
            }
            else{
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                double incomeBal = 0.0;
                double ExpenseBal =0.0;
                for(SummaryGroup *summaryGrp in arrSummaryGroups){
                    if([summaryGrp.groupName isEqual:@"Expense"]){
                        ExpenseBal = summaryGrp.overAllSum;
                    }
                    if([summaryGrp.groupName isEqual:@"Income"]){
                        incomeBal = summaryGrp.overAllSum;
                    }
                    double valueIncome = incomeBal;
                    if(valueIncome<0){
                        valueIncome = valueIncome*-1;
                    }
                    double valueExpence = ExpenseBal;
                    if(valueExpence<0){
                        valueExpence = valueExpence*-1;
                    }
                    double lossOrProfit = valueIncome-valueExpence;
                    if (lossOrProfit > 0)
                    {
                        // do positive stuff
                        double value = lossOrProfit;
                        if(value<0){
                            value = value*-1;
                        }
                        
                        cell.textLabel.text = @"Profit";
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                    }
                    else if (lossOrProfit == 0)
                    {
                        // do zero stuff
                        double value = lossOrProfit;
                        if(value<0){
                            value = value*-1;
                        }
                        cell.textLabel.text = @"";
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                    }
                    else
                    {
                        double value = lossOrProfit;
                        if(value<0){
                            value = value*-1;
                        }
                        // do negative stuff
                        cell.textLabel.text = @"Loss";
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self formatToTwoDigitValueForNumber:value]];
                    }
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
                    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
                }
            }
        }
        return cell;
    }
    else{
        
        ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
        
        if (cell) {
            cell.backgroundColor = [UIColor clearColor];
            cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
            cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
            [cell.btnDismiss addTarget:self action:@selector(dismissSideMenu) forControlEvents:UIControlEventAllEvents];
        }
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{   if([tableView isEqual:self.tableView]){
    
    return 15.0f;
}
    return 0;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Assets"];
        NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
        SummaryGroup *sumGrp = arrData[0];
        NSArray *arrAssetsData =sumGrp.accounts;
        if(arrAssetsData.count==1){
            return  UITableViewCellEditingStyleNone;
        }
        if(indexPath.row < arrAssetsData.count){
            SummaryAccount *summaryAccount = arrAssetsData[indexPath.row];
            Accounts * accounts =[self getAccountForAccountId:[NSNumber numberWithInt:[summaryAccount.accountId intValue]]];
            if(accounts.accountId<[NSNumber numberWithInt:17]){
                return  UITableViewCellEditingStyleNone;
            }
            return UITableViewCellEditingStyleDelete;
        }
        else{
            return UITableViewCellEditingStyleNone;
        }
    }
    else if (indexPath.section == 1){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Liability"];
        NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
        SummaryGroup *sumGrp = arrData[0];
        NSArray *arrLiabilityData =sumGrp.accounts;
        if(arrLiabilityData.count==1){
            return  UITableViewCellEditingStyleNone;
            
        }
        if(indexPath.row < arrLiabilityData.count){
            SummaryAccount *summaryAccount = arrLiabilityData[indexPath.row];
            Accounts * accounts =[self getAccountForAccountId:[NSNumber numberWithInt:[summaryAccount.accountId intValue]]];
            if(accounts.accountId<[NSNumber numberWithInt:17]){
                return  UITableViewCellEditingStyleNone;
                
            }
            
            return UITableViewCellEditingStyleDelete;
            
        }
        else{
            return UITableViewCellEditingStyleNone;
            
        }
        
    }
    else if(indexPath.section ==2){
        return UITableViewCellEditingStyleNone;
    }
    // Detemine if it's in editing mode
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(indexPath.section==0){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Assets"];
            NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
            SummaryGroup *sumGrp = arrData[0];
            NSArray *arrAssetsData =sumGrp.accounts;
            if(indexPath.row < arrAssetsData.count){
                SummaryAccount *summaryAccount = arrAssetsData[indexPath.row];
                Accounts * accounts =[self getAccountForAccountId:[NSNumber numberWithInt:[summaryAccount.accountId intValue]]];
                if(accounts.accountId>[NSNumber numberWithInt:16]){
                    if([self chaeckIfEntryExistForAccount:accounts]){
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hold On!!" message:@"Account is used for some entry delete the entry first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    else{
                        [self deleteAccount:accounts];
                    }
                    
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hold On!!" message:@"Account is Default unable to delete." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
            
            
        }
        else if (indexPath.section == 1){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.groupName beginswith[c] %@ ", @"Liability"];
            NSArray *arrData = [arrSummaryGroups filteredArrayUsingPredicate:predicate].mutableCopy;
            SummaryGroup *sumGrp = arrData[0];
            NSArray *arrLiabilityData =sumGrp.accounts;
            if(indexPath.row == arrLiabilityData.count){
                
            }
            else{
                SummaryAccount *summaryAccount = arrLiabilityData[indexPath.row];
                Accounts * accounts =[self getAccountForAccountId:[NSNumber numberWithInt:[summaryAccount.accountId intValue]]];
                if(accounts.accountId>[NSNumber numberWithInt:16]){
                    if([self chaeckIfEntryExistForAccount:accounts]){
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hold On!!" message:@"Account is used for some entry delete the entry first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    else{
                        [self deleteAccount:accounts];
                    }
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hold On!!" message:@"Account is Default unable to delete." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }
        else if(indexPath.section ==2){
            
        }
        
    }
    [self sortAllData];
    [self.tableView reloadData];
}


-(void)deleteAccount:(Accounts*)account{
    MBProgressHUD * hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Deleting...";
    
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
    
    [[ServiceManager sharedManager]deleteAccountForAuthKey:@"" companyid:[NSString stringWithFormat:@"%@",self.companies.companyId] companyName:self.companies.companyName forAccountName:account.accountName uniqueName:account.uniqueName groupName:grpType withCompletionBlock:^(NSDictionary *responce, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //NSLog(@"%@",responce);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *status = [NSString stringWithFormat:@"%@",[responce valueForKey:@"status"]];
        NSString *message =[responce valueForKey:@"message"];
        if([status isEqual:@"0"]){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Opps!!" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else{
            AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
            NSManagedObjectContext *context=[appDelegate managedObjectContext];
            [context deleteObject:account];
            NSError *saveError = nil;
            [context save:&saveError];
            [self getAccounts];
        }
        [self sortAllData];
        [self.tableView reloadData];
        
    }];
    
}
-(BOOL)chaeckIfEntryExistForAccount:(Accounts*)account{
    for(Entries *entry in arrEntries){
        if([entry.creditAccount isEqual:account.accountId]||[entry.debitAccount isEqual:account.accountId] ){
            return YES;
        }
    }
    return NO;
}

-(Accounts*)getAccountForAccountId:(NSNumber*)accountId{
    for(Accounts *account in arrAccounts){
        if([account.accountId isEqual: accountId]){
            return account;
        }
    }
    return nil;
}

- (BOOL) allowsHeaderViewsToFloat{
    return NO;
}

-(void)dismissSideMenu{
    [self.contextMenuTableView dismisWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}
#pragma mark sync database
-(void) syncTripList
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    // MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //  hud.labelText=@"Syncing..";
    [[ServiceManager sharedManager] syncTripForAuthKey:[userDef valueForKey:@"AuthKey"] andCompanyId:[self.companies.companyId intValue] withCompletionBlock:^(NSDictionary *responce, NSError *error)
     {
         // [MBProgressHUD hideHUDForView:self.view animated:YES];
         NSString *strStatus = [responce valueForKey:@"status"];
         int intStatus = [strStatus intValue];
         
         if (intStatus == 1)
         {
             NSArray *arrData = [responce valueForKey:@"data"];
             //get group details
             for (NSMutableDictionary *dictTrip in arrData)
             {
                 AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                 NSManagedObjectContext *contextTrip=[appDelegate managedObjectContext];
                 NSFetchRequest *fetchRequestTrip = [[NSFetchRequest alloc] initWithEntityName:@"TripInfo"];
                 //Apply filter condition
                 [fetchRequestTrip setPredicate:[NSPredicate predicateWithFormat:@"tripId == %@", [NSNumber numberWithInt:[[dictTrip valueForKey:@"tripId"] intValue]]]];
                 
                 NSArray *tripArr = [[contextTrip executeFetchRequest:fetchRequestTrip error:nil] mutableCopy];
                 // add a new company
                 if(tripArr.count == 0)
                 {
                     NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"TripInfo" inManagedObjectContext:contextTrip];
                     [newDevice setValue:[NSNumber numberWithInt:[[dictTrip valueForKey:@"tripId"] intValue]] forKey:@"tripId"];
                     [newDevice setValue:[dictTrip valueForKey:@"tripName"] forKey:@"tripName"];
                     [newDevice setValue:[NSNumber numberWithInt:[[dictTrip valueForKey:@"owner"] intValue]] forKey:@"owner"];
                     [newDevice setValue:[NSNumber numberWithInt:[self.companies.companyId intValue]] forKey:@"companyId"];
                 }
                 else
                 {
                     //Update trip list
                     TripInfo *tripObject = tripArr[0];
                     tripObject.tripName = [dictTrip valueForKey:@"tripName"];
                     tripObject.tripId = [NSNumber numberWithInt:[[dictTrip valueForKey:@"tripId"] intValue]];
                     tripObject.owner = [NSNumber numberWithInt:[[dictTrip valueForKey:@"owner"] intValue]];
                     tripObject.companyId = [NSNumber numberWithInt:[self.companies.companyId intValue]];
                 }
                 [contextTrip save:&error];
             }
         }
         else
         {
             NSLog(@"Error while syncing trip");
         }
     }];
}

-(void)syncAccounts{
    if( [[AppData sharedData]isInternetAvailable]){
        [[ServiceManager sharedManager]getAccountListForAuthKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"authKey"] companyName:self.companies.companyName companyid:[self.companies.companyId stringValue] andMobile:@"1" withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            //NSLog(@"%@",responce);
            NSArray *data = [responce valueForKey:@"data"];
            NSMutableArray *arrAllAccountId = [NSMutableArray array];
            if (data.count > 0)
            {
                NSDictionary *grpDetails = [data objectAtIndex:0];
                NSArray *arrGrpDetails = [grpDetails valueForKey:@"groupDetail"];
                AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                for(NSDictionary *dictionary in arrGrpDetails){
                    // NSLog(@"%@",dictionary);
                    NSString * grpName = [dictionary valueForKey:@"groupName"];
                    NSNumber * grpId;
                    if([[grpName lowercaseString] isEqual:@"income"]){
                        grpId = [NSNumber numberWithInt:0];
                    }
                    else if ([[grpName lowercaseString] isEqual:@"expense"]){
                        grpId = [NSNumber numberWithInt:1];
                    }
                    else if ([[grpName lowercaseString] isEqual:@"liability"]){
                        grpId = [NSNumber numberWithInt:2];
                    }
                    else if ([[grpName lowercaseString] isEqual:@"assets"]){
                        grpId = [NSNumber numberWithInt:3];
                    }
                    NSArray * arrAccountDetails = [dictionary valueForKey:@"accountDetails"];
                    for(NSDictionary *dictAccounts in arrAccountDetails){
                        NSManagedObjectContext *context=[appDelegate managedObjectContext];
                        NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                        NSFetchRequest *request=[[NSFetchRequest alloc]init];
                        //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@ AND groupId contains[cd] %@", [dictAccounts valueForKey:@"accountName"],grpId];
                        // [request setPredicate:predicate];
                        [request setEntity:entityDescr];
                        NSError *error;
                        NSArray * arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                        NSMutableArray *arrtempData = [NSMutableArray array];
                        for(Accounts *account in arrData){
                            if([[account.accountName lowercaseString] isEqual:[[dictAccounts valueForKey:@"accountName"] lowercaseString]] && [account.groupId isEqual:grpId])
                            {
                                [arrtempData addObject:account];
                            }
                        }
                        if(arrtempData.count==0){
                            // add a new account
                            [self refreshAccounts];
                            // create a new account with max account id
                            NSMutableArray *arrAccountId = [NSMutableArray array];
                            for(Accounts *accounts in arrAccounts){
                                [arrAccountId addObject:accounts.accountId];
                            }
                            int max = [[arrAccountId valueForKeyPath:@"@max.intValue"] intValue];
                            max++;
                            NSManagedObject *newAccount;
                            newAccount = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"Accounts"
                                          inManagedObjectContext:context];
                            NSNumber *accountId = [NSNumber numberWithInt:max];
                            [arrAllAccountId addObject:accountId];
                            [newAccount setValue:[dictAccounts valueForKey:@"accountName"] forKeyPath:@"accountName"];
                            [newAccount setValue:self.companies.emailId forKeyPath:@"emailId"];
                            [newAccount setValue:grpId forKeyPath:@"groupId"];
                            [newAccount setValue:[NSNumber numberWithDouble:[[dictAccounts valueForKey:@"openingBalance"] doubleValue]] forKeyPath:@"openingBalance"];
                            [newAccount setValue:[dictAccounts valueForKey:@"uniqueName"] forKeyPath:@"uniqueName"];
                            [newAccount setValue:accountId forKeyPath:@"accountId"];
                            // NSLog(@"newAccount %@",newAccount);
                            [context insertObject:newAccount];
                            [context save:&error];
                            
                        }
                        else{
                            //update existin account
                            Accounts *account = arrtempData[0];
                            [arrAllAccountId addObject:account.accountId];
                            account.openingBalance =[NSNumber numberWithDouble:[[dictAccounts valueForKey:@"openingBalance"] doubleValue]];
                            [context save:&error];
                        }
                        //                        for(Accounts *account in arrAccounts ){
                        //                            if(account.accountId>[NSNumber numberWithInt:16]){
                        //                                if(![arrAllAccountId containsObject:account.accountId]){
                        //                                    NSManagedObjectContext *context=[appDelegate managedObjectContext];
                        //                                    [context deleteObject:account];
                        //                                    [self refreshAccounts];
                        //                                }
                        //
                        //                            }
                        //                                    }
                    }
                }
            }
            
        }];
    }
}

-(void)syncEntryInfo{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self refreshAccounts];
    if( [[AppData sharedData]isInternetAvailable]){
        NSManagedObjectContext *context=[appDelegate managedObjectContext];
        NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
        NSFetchRequest *request=[[NSFetchRequest alloc]init];
        [request setEntity:entityDescr];
        NSError *error;
        NSArray *arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
        NSMutableArray *arrEntryId = [NSMutableArray array];
        for(Entries *entries in arrData){
            [arrEntryId addObject:entries.entryId];
        }
        int max = [[arrEntryId valueForKeyPath:@"@max.intValue"] intValue];
        [[ServiceManager sharedManager]getEntrySummaryForAuthKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"authKey"] companyid:[self.companies.companyId stringValue] andEntryId:[NSString stringWithFormat:@"%d",max ] withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            NSArray * arrData = [responce valueForKey:@"data"];
            NSNumber * creditGrpId;
            NSNumber * transactionType;
            NSNumber *creditAccountId;
            NSNumber *debitAccountId;
            NSString *amount ;
            for(NSDictionary *dict in arrData){
                NSArray * arrCredit = [dict valueForKey:@"credit"];
                NSArray * arrDebit = [dict valueForKey:@"debit"];
                for(NSDictionary * creditDict in arrCredit){
                    NSString *creditGrpName = [creditDict valueForKey:@"groupName"];
                    NSString *creditAccountName = [creditDict valueForKey:@"accountName"];
                    amount = [creditDict valueForKey:@"amount"];
                    
                    // get first credit and debit groupname
                    NSDictionary * debitAt0 = arrDebit[0];
                    NSString * debit0GrpName = [debitAt0 valueForKey:@"groupName"];
                    NSDictionary * creditAt0 = arrCredit[0];
                    NSString * credit0GrpName = [creditAt0 valueForKey:@"groupName"];
                    
                    
                    //set transaction type
                    if([[debit0GrpName lowercaseString] isEqual:@"income"]||[[credit0GrpName lowercaseString] isEqual:@"income"] || [[credit0GrpName lowercaseString] isEqual:@"liability"]){
                        transactionType = [NSNumber numberWithInt:0];
                    }
                    else if([[debit0GrpName lowercaseString] isEqual:@"expense"]||[[credit0GrpName lowercaseString] isEqual:@"expense"] || [[debit0GrpName lowercaseString] isEqual:@"liability"]){
                        transactionType = [NSNumber numberWithInt:1];
                    }
                    else if([[debit0GrpName lowercaseString] isEqual:@"assets"]&&[[credit0GrpName lowercaseString] isEqual:@"assets"] ){
                        transactionType = [NSNumber numberWithInt:0];
                    }
                    // set Group id
                    if([[creditGrpName lowercaseString] isEqual:@"income"]){
                        creditGrpId = [NSNumber numberWithInt:0];
                    }
                    else if ([[creditGrpName lowercaseString] isEqual:@"expense"]){
                        creditGrpId = [NSNumber numberWithInt:1];
                    }
                    else if ([[creditGrpName lowercaseString] isEqual:@"liability"]){
                        creditGrpId = [NSNumber numberWithInt:2];
                    }
                    else if ([[creditGrpName lowercaseString] isEqual:@"assets"]){
                        creditGrpId = [NSNumber numberWithInt:3];
                    }
                    // check for accounts with same grp id and account name.
                    NSManagedObjectContext *context=[appDelegate managedObjectContext];
                    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                    NSFetchRequest *request=[[NSFetchRequest alloc]init];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName == [cd]%@ AND groupId == %@", [creditAccountName lowercaseString],creditGrpId];
                    [request setPredicate:predicate];
                    [request setEntity:entityDescr];
                    NSError *error;
                    arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                    
                    NSMutableArray *arrCreTempData = [NSMutableArray array];
                    for(Accounts *accounts in arrData){
                        if([[accounts.accountName lowercaseString] isEqual:[creditAccountName lowercaseString]]){
                            [arrCreTempData addObject:accounts];
                        }
                    }
                    if(arrCreTempData.count==0){
                        [self refreshAccounts];
                        // create a new account with max account id
                        NSMutableArray *arrAccountId = [NSMutableArray array];
                        for(Accounts *accounts in arrAccounts){
                            [arrAccountId addObject:accounts.accountId];
                        }
                        int max = [[arrAccountId valueForKeyPath:@"@max.intValue"] intValue];
                        max++;
                        NSManagedObject *newAccount;
                        newAccount = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Accounts"
                                      inManagedObjectContext:context];
                        NSString *openingBalanceNum = @"0";
                        NSNumber *openingBalance = [NSNumber numberWithInt:[openingBalanceNum floatValue]];
                        NSNumber *accountId = [NSNumber numberWithInt:max];
                        
                        [newAccount setValue:creditAccountName forKeyPath:@"accountName"];
                        [newAccount setValue:self.companies.emailId forKeyPath:@"emailId"];
                        [newAccount setValue:creditGrpId forKeyPath:@"groupId"];
                        [newAccount setValue:openingBalance forKeyPath:@"openingBalance"];
                        [newAccount setValue:@"" forKeyPath:@"uniqueName"];
                        [newAccount setValue:accountId forKeyPath:@"accountId"];
                        // NSLog(@"newAccount %@",newAccount);
                        [context insertObject:newAccount];
                        [context save:&error];
                        creditAccountId = accountId;
                        [self refreshAccounts];
                    }
                    else{
                        Accounts *accountsCre = arrCreTempData[0];
                        creditAccountId = accountsCre.accountId;
                    }
                    
                }
                // check for debit accounts with same grp id and account name.
                for(NSDictionary * debitDict in arrDebit){
                    
                    NSString *debitGrpName = [debitDict valueForKey:@"groupName"];
                    NSString *debitAccountName = [debitDict valueForKey:@"accountName"];
                    
                    NSNumber * debitGrpId;
                    if([[debitGrpName lowercaseString] isEqual:@"income"]){
                        debitGrpId = [NSNumber numberWithInt:0];
                    }
                    else if ([[debitGrpName lowercaseString] isEqual:@"expense"]){
                        debitGrpId = [NSNumber numberWithInt:1];
                    }
                    else if ([[debitGrpName lowercaseString] isEqual:@"liability"]){
                        debitGrpId = [NSNumber numberWithInt:2];
                    }
                    else if ([[debitGrpName lowercaseString] isEqual:@"assets"]){
                        debitGrpId = [NSNumber numberWithInt:3];
                    }
                    
                    
                    [self refreshAccounts];
                    NSManagedObjectContext *context=[appDelegate managedObjectContext];
                    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Accounts" inManagedObjectContext:context];
                    NSFetchRequest *request=[[NSFetchRequest alloc]init];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName == [cd]%@ AND groupId == %@", debitAccountName ,debitGrpId];
                    [request setPredicate:predicate];
                    [request setEntity:entityDescr];
                    NSError *error;
                    arrData=[[context executeFetchRequest:request error:&error]mutableCopy];
                    NSMutableArray *arrDebTempData = [NSMutableArray array];
                    for(Accounts *accounts in arrData){
                        if([[accounts.accountName lowercaseString] isEqual:[debitAccountName lowercaseString]]){
                            [arrDebTempData addObject:accounts];
                        }
                    }
                    
                    if(arrDebTempData.count==0){
                        [self refreshAccounts];
                        
                        // create a new account with max account id
                        NSMutableArray *arrAccountId = [NSMutableArray array];
                        for(Accounts *accounts in arrAccounts){
                            [arrAccountId addObject:accounts.accountId];
                        }
                        int max = [[arrAccountId valueForKeyPath:@"@max.intValue"] intValue];
                        max++;
                        NSManagedObject *newAccount;
                        newAccount = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Accounts"
                                      inManagedObjectContext:context];
                        NSString *openingBalanceNum = @"0";
                        NSNumber *openingBalance = [NSNumber numberWithInt:[openingBalanceNum floatValue]];
                        NSNumber *accountId = [NSNumber numberWithInt:max];
                        
                        [newAccount setValue:debitAccountName forKeyPath:@"accountName"];
                        [newAccount setValue:self.companies.emailId forKeyPath:@"emailId"];
                        [newAccount setValue:debitGrpId forKeyPath:@"groupId"];
                        [newAccount setValue:openingBalance forKeyPath:@"openingBalance"];
                        [newAccount setValue:@"" forKeyPath:@"uniqueName"];
                        [newAccount setValue:accountId forKeyPath:@"accountId"];
                        [context insertObject:newAccount];
                        [context save:&error];
                        debitAccountId = accountId;
                        [self refreshAccounts];
                    }
                    else{
                        Accounts *accountsDeb = arrDebTempData[0];
                        debitAccountId = accountsDeb.accountId;
                    }
                    
                }
                NSString * strDate = [dict valueForKey:@"entryDate"];
                NSArray * arr = [strDate componentsSeparatedByString:@" "];
                
                NSManagedObjectContext *context=[appDelegate managedObjectContext];
                NSError *error = nil;
                NSManagedObject *newEntry;
                newEntry = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Entries"
                            inManagedObjectContext:context];
                NSString *entryId = [dict valueForKey:@"entryId"];
                [newEntry setValue:transactionType forKey:@"transactionType"];
                [newEntry setValue:[arr objectAtIndex:0] forKey:@"date"];
                [newEntry setValue:[NSNumber numberWithInt:[amount intValue]] forKey:@"amount"];
                [newEntry setValue:debitAccountId forKey:@"debitAccount"];
                [newEntry setValue:creditAccountId forKey:@"creditAccount"];
                [newEntry setValue:[NSNumber numberWithInt:[[dict valueForKey:@"tripId"] intValue]] forKey:@"tripId"];
                [newEntry setValue:self.companies.companyId forKey:@"companyId"];
                [newEntry setValue:[NSNumber numberWithInt:[amount intValue]] forKey:@"amount"];
                [newEntry setValue:[NSNumber numberWithInt:[entryId intValue]] forKey:@"entryId"];
                [context insertObject:newEntry];
                [context save:&error];
            }
            [self getAllEtries];
            [self deleteAllDeletedEntries];
            [self deleteLocallyDeletedEntriesFromServer];
            NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
            [DateFormatter setDateFormat:@"dd-MMM-yyyy HH:mm:ss"];
            NSString * strDateTime = [DateFormatter stringFromDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setValue:strDateTime forKey:@"syncDateTime"];
        }];
    }
}
-(void)deleteLocallyDeletedEntriesFromServer{
    for(DeletedEntries *deletedEntry in arrDeletedEntries){
        [[ServiceManager sharedManager]deleteEntrywithEntryId:[NSString stringWithFormat:@"%@",deletedEntry.entryId] withDeleteStatus:@"1" forAuthKey:@"" andCompanyName:self.companies.companyName withCompletionBlock:^(NSDictionary *responce, NSError *error) {
            // NSLog(@"%@",responce);
            AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
            NSManagedObjectContext *context=[appDelegate managedObjectContext];
            [context deleteObject:deletedEntry];
            [context save:&error];
        }];
    }
    
}
-(void)deleteAllDeletedEntries{
    [[ServiceManager sharedManager]getAllDeletedEntriesforAuthKey:@"" andcompanyid:[NSString stringWithFormat:@"%@",self.companies.companyId] withCompletionBlock:^(NSDictionary *responce, NSError *error) {
        //   NSLog(@"%@",responce);
        NSArray *arrData = [responce valueForKey:@"data"];
        NSDictionary *dictData = [arrData objectAtIndex:0];
        NSArray *arrEntryId = [dictData valueForKey:@"entryId"];
        for(NSString *entryId in arrEntryId){
            for(Entries *entry in arrEntries){
                if([entry.entryId isEqual:[NSNumber numberWithInt:[entryId intValue]]]){
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    //create managed object context
                    NSManagedObjectContext *context = [appDelegate managedObjectContext];
                    NSError *error;
                    [context deleteObject:entry];
                    [context save:&error];
                    [self sortAllData];
                }
            }
        }
        
    }];
}

-(void)syncAllNullEntries{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrAllEntries =[[context executeFetchRequest:request error:&error]mutableCopy];
    for(Entries *entry in arrAllEntries){
        if([entry.entryId isEqual:[NSNumber numberWithInt:0]]){
            if(!([entry.date isEqual:nil]))
                [self syncEntry:entry];
        }
    }
}
-(void)syncEntry:(Entries*)entry{
    Accounts *creditAccount;
    Accounts *debitAccount;
    for(Accounts *account in arrAccounts){
        if([account.accountId isEqual:entry.creditAccount]){
            creditAccount = account;
        }
        else if ([account.accountId isEqual:entry.debitAccount]){
            debitAccount =account;
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
    int creGrpId = [creditAccount.groupId intValue];
    
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
    
    NSString * strArrCredit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\",,\"uniqueName\":\"%@\"}]",creditAccount.accountName,entry.amount,creGrpType,creGrpType,creditAccount.uniqueName];
    NSString * strArrDebit = [NSString stringWithFormat:@"[{\"accountName\":\"%@\",\"amount\":%@,\"groupName\":\"%@\",\"subGroup\":\"%@\",,\"uniqueName\":\"%@\"}]",debitAccount.accountName,entry.amount,debGrpType,debGrpType,debitAccount.uniqueName];
    //   NSError *error = nil;
    NSString *uniqueName = creditAccount.uniqueName;
    if([uniqueName isEqual:@""])
        uniqueName =debitAccount.uniqueName;
    [[ServiceManager sharedManager]createEntryForAuthKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"] andTripId:[entry.tripId intValue] andMobile:@"1" date:entry.date companyName:self.companies.companyName withDescription:entry.descriptionEntry  withDebit:strArrDebit andCredit:strArrCredit withTransactionType:[NSString stringWithFormat:@"%@",entry.transactionType] andUniqueName:uniqueName withCompletionBlock:^(NSDictionary *responce, NSError *error) {
        NSString * status = [NSString stringWithFormat:@"%@",[responce valueForKey:@"status"]];
        NSString *entryId;
        
        if([status isEqual:@"1"]){
            NSArray * arrData = [responce valueForKey:@"data"];
            NSDictionary *dataDict = arrData[0];
            entryId = [dataDict valueForKey:@"entryId"];
            
        }
        AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context=[appDelegate managedObjectContext];
        entry.entryId = [NSNumber numberWithInt:[entryId intValue]];
        [context save:&error];
    }];
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

-(void)getAllEtries{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray *arrAccounts1=[[context executeFetchRequest:request error:&error]mutableCopy];
    arrEntries = arrAccounts1;
}



@end
