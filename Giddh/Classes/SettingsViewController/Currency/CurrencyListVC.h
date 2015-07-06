//
//  CurrencyListVC.h
//  Giddh
//
//  Created by Admin on 05/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyListVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrCurrency;
    NSUserDefaults *userDef;
}

@end
