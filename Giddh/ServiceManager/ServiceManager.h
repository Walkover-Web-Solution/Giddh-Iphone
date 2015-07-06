//
//  ServiceManager.h
//  Giddh
//
//  Created by Admin on 15/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CommonMacros.h"
#import "MBProgressHUD.h"

// hussain api section
typedef void (^AccountListCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^EntrySummaryCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^CreateEntryCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^DeleteEntryCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^GetAllDeleteEntryCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^UpdateEntryCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^DeleteAccountCompletionBlock)(NSDictionary *responce, NSError *error);

//Anuj Api section
typedef void (^AuthKeyCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^CompanyListCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^TrialBalanceCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^CreateTripCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^ShareTripCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^EditTripCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^DeleteTripCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^RemoveTripCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^SyncTripCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^SyncEmailCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^TripSummaryCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^CompanyNameCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^AddAccountCompletionBlock)(NSDictionary *responce, NSError *error);
typedef void (^UpdateAccountCompletionBlock)(NSDictionary *responce, NSError *error);

@interface ServiceManager : NSObject
{
    NSUserDefaults *userDef;
}

DECLARE_SINGLETON_METHOD(ServiceManager, sharedManager);


// hussain api section
-(void)getAccountListForAuthKey:(NSString*)authKey companyName:(NSString*)companyName companyid:(NSString*)companyId andMobile:(NSString*)mobile withCompletionBlock:(AccountListCompletionBlock)completionBlock;
-(void)getEntrySummaryForAuthKey:(NSString*)authKey companyid:(NSString*)companyId  andEntryId:(NSString*)entryId withCompletionBlock:(EntrySummaryCompletionBlock)completionBlock;
-(void)createEntryForAuthKey:(NSString*)authKey andTripId:(int)tripId andMobile:(NSString*)mobile date:(NSString*)date companyName:(NSString*)companyName withDescription:(NSString*)description withDebit:(NSString*)arrDebit andCredit:(NSString*)arrCredit withTransactionType:(NSString*)transactionType andUniqueName:(NSString*)uniqueName withCompletionBlock:(CreateEntryCompletionBlock)completionBlock;
-(void)deleteEntrywithEntryId:(NSString*)entryId withDeleteStatus:(NSString*)deleteStatus forAuthKey:(NSString*)authKey andCompanyName:(NSString*)companyName withCompletionBlock:(DeleteEntryCompletionBlock)completionBlock;
-(void)getAllDeletedEntriesforAuthKey:(NSString*)authKey andcompanyid:(NSString*)companyId withCompletionBlock:(GetAllDeleteEntryCompletionBlock)completionBlock;
-(void)updateEntryforAuthKey:(NSString*)authKey andcompanyName:(NSString*)companyName forEntryId:(NSString*)entryId date:(NSString*)date description:(NSString*)description mobile:(NSString*)mobile debit:(NSString*)debit credit:(NSString*)credit tripId:(NSNumber*)tripId withCompletionBlock:(UpdateEntryCompletionBlock)completionBlock;
-(void)deleteAccountForAuthKey:(NSString*)authKey companyid:(NSString*)companyId  companyName:(NSString*)companyName forAccountName:(NSString*)accountName uniqueName:(NSString*)uniqueName groupName:(NSString*)grpName withCompletionBlock:(EntrySummaryCompletionBlock)completionBlock;

//Anuj Api section
-(void)getAuthKeyForToken:(NSString*)token andloginType:(NSString*)loginType withCompletionBlock:(AuthKeyCompletionBlock)completionBlock;
-(void)getCompanyListForAuthKey:(NSString*)authKey andMobile:(NSString*)mobile withCompletionBlock:(CompanyListCompletionBlock)completionBlock;
-(void)getTrialBalanceForCompanyName:(NSString*)companyName andCompanyId:(int)companyId andDate:(NSString *)strDate andMobile:(NSString*)mobile andSearchBy:(NSString *)searchText withCompletionBlock:(TrialBalanceCompletionBlock)completionBlock;
-(void)createTripForAuthKey:(NSString*)authKey andTripName:(NSString*)tripName andCompanyId:(NSString *)companyId withCompletionBlock:(CreateTripCompletionBlock)completionBlock;
-(void)shareTripForAuthKey:(NSString*)authKey companyId:(NSString*)companyId andTripId:(int)tripId andEmail:(NSString *)email withCompletionBlock:(CreateTripCompletionBlock)completionBlock;
-(void)editTripForAuthKey:(NSString*)authKey andTripName:(NSString*)tripName andTripId:(int)tripId andCompanyId:(int)companyId withCompletionBlock:(CreateTripCompletionBlock)completionBlock;
-(void)deleteTripForAuthKey:(NSString*)authKey andTripId:(int)tripId andCompanyId:(int)companyId withCompletionBlock:(DeleteTripCompletionBlock)completionBlock;
-(void)removeEmailForAuthKey:(NSString*)authKey andTripId:(int)tripId andCompanyId:(int)companyId andEmail:(NSString *)email withCompletionBlock:(RemoveTripCompletionBlock)completionBlock;
-(void)syncTripForAuthKey:(NSString*)authKey andCompanyId:(int)companyId withCompletionBlock:(SyncTripCompletionBlock)completionBlock;
-(void)syncEmailForAuthKey:(NSString*)authKey andCompanyId:(int)companyId andTripId:(int)tripId withCompletionBlock:(SyncEmailCompletionBlock)completionBlock;
-(void)getTripSummaryForAuthKey:(NSString*)authKey companyId:(int)companyId andTripId:(int)tripId andEntryId:(int)entryId withCompletionBlock:(TripSummaryCompletionBlock)completionBlock;
-(void)updateCompanyNameForAuthKey:(NSString*)authKey prevCompanyName:(NSString *)prevName andNewCompanyName:(NSString *)newName withCompletionBlock:(CompanyNameCompletionBlock)completionBlock;
-(void)addAccountForAuthKey:(NSString*)authKey andCompanyId:(int)compId companyName:(NSString *)compName groupName:(NSString *)groupName accountName:(NSString *)accountName uniqueName:(NSString *)uniqueName openingBalance:(NSString *)openingBal openingBalanceType:(int)balanceType withCompletionBlock:(AddAccountCompletionBlock)completionBlock;
-(void)updateAccountForAuthKey:(NSString*)authKey companyName:(NSString *)compName oldAccountName:(NSString *)oldAccName oldUniqueName:(NSString *)oldUniqueName accountName:(NSString *)accountName uniqueName:(NSString *)uniqueName openingBalance:(NSString *)openingBal openingBalanceType:(int)balanceType withCompletionBlock:(AddAccountCompletionBlock)completionBlock;
@end
