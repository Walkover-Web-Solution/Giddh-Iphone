//
//  EditEntryViewController.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 15/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entries.h"
#import <CoreData/CoreData.h>
#import "Companies.h"
@interface EditEntryViewController : UIViewController
@property (strong, nonatomic) NSManagedObjectID * objId;
@property (nonatomic) BOOL tripSummaryFlag;
@property (strong, nonatomic) Companies *companies;

@end
