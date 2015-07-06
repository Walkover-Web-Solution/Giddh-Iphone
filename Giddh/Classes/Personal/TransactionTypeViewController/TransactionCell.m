//
//  TransactionCell.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 20/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TransactionCell.h"

@implementation TransactionCell

-(void)awakeFromNib{
    self.lblTransactionName.adjustsFontSizeToFitWidth=YES;
    self.lblInitial.layer.cornerRadius = 25;
    self.lblInitial.layer.masksToBounds = YES;
    self.lblInitial.font = [UIFont fontWithName:@"McHandwriting" size:24];
    
}

@end
