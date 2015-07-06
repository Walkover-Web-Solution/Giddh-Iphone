//
//  TransactionHeaderCollectionReusableView.m
//  Giddh
//
//  Created by Hussain Chhatriwala on 23/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TransactionHeaderCollectionReusableView.h"

@implementation TransactionHeaderCollectionReusableView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    self.lblHeader.adjustsFontSizeToFitWidth=YES;
    self.lblHeader.textColor = [UIColor blackColor];
}


@end
