//
//  SummaryGroup.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 30/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SummaryGroup : NSObject
@property (strong, nonatomic) NSString * groupName;
@property (assign, nonatomic) double  overAllSum;
@property (strong, nonatomic) NSArray * accounts;

@end
