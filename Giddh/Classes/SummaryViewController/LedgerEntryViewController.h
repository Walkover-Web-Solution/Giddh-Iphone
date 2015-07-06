//
//  LedgerEntryViewController.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 19/06/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Companies.h"
#import "LedgerTypeViewController.h"
@protocol LedgerEntryViewControllerDelegate<NSObject>
-(void)removeView;
@end
@interface LedgerEntryViewController : UIViewController
@property (strong, nonatomic) Companies *companies;
@property (weak, nonatomic) id <LedgerEntryViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *type;

@end
