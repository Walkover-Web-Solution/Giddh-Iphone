//
//  TransactionCell.h
//  Giddh
//
//  Created by Hussain Chhatriwala on 20/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionName;
@property (weak, nonatomic) IBOutlet UIImageView *imgTranscation;
@property (weak, nonatomic) IBOutlet UILabel *lblInitial;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelectionView;

@end
