//
//  EntriesInfoTrip.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 16/05/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntriesInfoTrip : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * companyId;
@property (nonatomic, retain) NSString * creditAccount;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * debitAccount;
@property (nonatomic, retain) NSString * descriptionEntry;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * entryId;
@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSNumber * transactionType;
@property (nonatomic, retain) NSNumber * tripId;

@end
