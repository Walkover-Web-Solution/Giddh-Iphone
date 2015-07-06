//
//  Groups.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 20/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Groups : NSManagedObject

@property (nonatomic, retain) NSString * emailId;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSNumber * systemId;

@end
