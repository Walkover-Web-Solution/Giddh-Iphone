//
//  Accounts.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 20/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Accounts : NSManagedObject

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSString * accountName;
@property (nonatomic, retain) NSString * emailId;
@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSNumber * openingBalance;
@property (nonatomic, retain) NSString * uniqueName;

@end
