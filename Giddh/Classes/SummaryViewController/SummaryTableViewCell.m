//
//  SummaryDetailViewController.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 01/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Companies.h"
@interface SummaryDetailViewController : UIViewController
{
    IBOutlet UILabel *lblMessage;
    IBOutlet UILabel *lblHeader;
}
@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *accountName;

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString * header;
@property (strong, nonatomic) Companies *companies;

@end
