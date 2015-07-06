//
//  TripInfo.h
//  Giddh
//
//  Created by Admin on 23/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TripInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * companyId;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSString * tripName;
@property (nonatomic, retain) NSNumber * tripId;

@end
