//
//  AppData.h
//  MSG91
//
//  Created by shubhendra Agrawal on 05/03/2015.
//  Copyright (c) 2015 Walkover. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonMacros.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "Companies.h"
@interface AppData : NSObject
@property (strong, nonatomic) MBProgressHUD *hud;
-(BOOL) isInternetAvailable;
-(void) syncCompanyList;
@property (strong, nonatomic) Companies *companies;
//- (BOOL)askContactsPermission ;
DECLARE_SINGLETON_METHOD(AppData, sharedData)
@end
