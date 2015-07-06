//
//  TransactionTypeViewController.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 20/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Companies.h"
#import "Accounts.h"

@interface TransactionTypeViewController : UIViewController
{
    NSString *strAPIDate,*selAccName;
    
    //picker view properties
    UIPickerView *picView;
    UIButton *buttonCancel,*buttonDone;
    NSMutableArray *arrPickerData;
    Accounts *accObject;
}
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) Companies *companies;

@end
