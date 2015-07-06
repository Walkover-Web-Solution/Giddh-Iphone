//
//  SummaryAccount.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 30/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SummaryAccount : NSObject
@property (strong, nonatomic) NSString * groupName;
@property (strong, nonatomic) NSString * name;
@property (assign, nonatomic) double  sum;
@property (strong, nonatomic) NSString * transactionType;
@property (strong, nonatomic) NSString * accountId;
@property (strong, nonatomic) NSString * emailIfLoan;
@property (strong, nonatomic) NSManagedObjectID *objId;

@end
