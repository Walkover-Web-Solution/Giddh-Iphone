//
//  CurrencyListVC.m
//  Giddh
//
//  Created by Admin on 05/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "CurrencyListVC.h"
#import "CurrencyList.h"

@interface CurrencyListVC ()

@end

@implementation CurrencyListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrCurrency = [NSMutableArray array];
    userDef = [NSUserDefaults standardUserDefaults];
    
    //show currency list
    NSLocale *locale = [NSLocale currentLocale];
    for (NSString *code in [NSLocale ISOCurrencyCodes])
    {
        CurrencyList *listObj = [[CurrencyList alloc]init];
        NSLocale *locale1 = [[NSLocale alloc] initWithLocaleIdentifier:code];
        NSString *currencySymbol = [NSString stringWithFormat:@"%@",[locale1 displayNameForKey:NSLocaleCurrencySymbol value:code]];
        listObj.currencyName = [locale displayNameForKey:NSLocaleCurrencyCode value:code];
        listObj.currencyCode = code;
        listObj.currencySymbol = currencySymbol;
        if (listObj.currencyName.length > 0)
        {
            [arrCurrency addObject:listObj];
        }
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return arrCurrency.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PinLogsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    CurrencyList *objList = arrCurrency[indexPath.row];
    cell.textLabel.text = objList.currencyName;
    cell.detailTextLabel.text = objList.currencySymbol;

    //set font family
    cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:17];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CurrencyList *objList = arrCurrency[indexPath.row];
    [userDef setValue:objList.currencyName forKey:@"currencyName"];
    [userDef setValue:objList.currencySymbol forKey:@"currencySymbol"];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
