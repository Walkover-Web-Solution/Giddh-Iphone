//
//  AddTripVC.h
//  Giddh
//
//  Created by Admin on 21/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceManager.h"

@interface AddTripVC : UIViewController<UITextFieldDelegate>
{
    
    IBOutlet UITextField *txtTripName;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITableView *tableViewPerson;
    
    NSMutableArray *arrTableData;
    NSUserDefaults *userDef;
    
    //int compId;
    NSString *strCompName,*strCompEmail;
    IBOutlet UIButton *btnSaveEditTrip;
    IBOutlet UIButton *btnSelectUser;
}
- (IBAction)createTripAction:(id)sender;
@property (nonatomic , strong ) NSMutableArray *arrSelectedPersons;
@property (nonatomic) BOOL editFlag;
@property (nonatomic , strong ) NSString *strEditTripName;
@property (nonatomic) int intEditTripId ;
@property (nonatomic) int intCompanyId ;
@property (nonatomic) int ifTripOwner;
@end
