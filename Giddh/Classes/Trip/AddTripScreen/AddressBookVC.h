//
//  AddressBookVC.h
//  Giddh
//
//  Created by Admin on 21/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressBookVC : UITableViewController<UITableViewDataSource,UITableViewDelegate>
{
    //Addressbook
    NSMutableArray *allContactsInfo,*arrContactName,*arrContactEmail,*arrTableData,*arrSelectedPerson;
}
- (IBAction)doneAction:(id)sender;
@property (nonatomic) BOOL checkEditFlag;
@end
