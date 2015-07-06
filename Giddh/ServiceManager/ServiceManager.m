//
//  ServiceManager.m
//  Giddh
//
//  Created by Admin on 15/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "ServiceManager.h"
#define domainName @"http://giddh.com/api/"
@implementation ServiceManager

SYNTHESIZE_SINGLETON_METHOD(ServiceManager, sharedManager);
// Anuj api section

-(void)getAuthKeyForToken:(NSString*)token andloginType:(NSString*)loginType withCompletionBlock:(AuthKeyCompletionBlock)completionBlock
{
    // http://giddh.com/api/generateAuthKey?token=ya29.LQH-n314aZumnfUFQmv3jinbSbCCKWChhvJYzcUVqE4wnoQk0ZlGczYInwfZlWymRwLHkNjc_QN1JA&loginType=2
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com/api/generateAuthKey?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"token=%@&loginType=%@",token,loginType];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else
        {
            completionBlock (nil,error);
        }
    }];
    
}

-(void)getCompanyListForAuthKey:(NSString *)authKey andMobile:(NSString *)mobile withCompletionBlock:(CompanyListCompletionBlock)completionBlock
{
    //http://giddh.com/api/companyListApi?authId=3EhnefWYEi06DiB551277e1&mobile=1
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com/api/companyListApi?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&mobile=%@",authKey,mobile];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}


//get company trial balance
-(void)getTrialBalanceForCompanyName:(NSString *)companyName andCompanyId:(int)companyId andDate:(NSString *)strDate andMobile:(NSString *)mobile andSearchBy:(NSString *)searchText withCompletionBlock:(TrialBalanceCompletionBlock)completionBlock
{
    userDef = [NSUserDefaults standardUserDefaults];
    //?companyName=demo&authId=3EhnefWYEi06DiB551277e1&fromDate=2015-03-17&toDate=2015-04-17&mobile=1
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com/api/trialBalanceNew?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost;
    if (searchText.length > 0)
    {
        strPost = [NSString stringWithFormat:@"companyName=%@&companyId=%d&authId=%@&fromDate=%@&toDate=%@&mobile=%@&searchBy=%@",companyName,companyId,[userDef valueForKey:@"AuthKey"],strDate,strDate,mobile,searchText];
    }
    else
    {
        strPost = [NSString stringWithFormat:@"companyName=%@&companyId=%d&authId=%@&fromDate=%@&toDate=%@&mobile=%@",companyName,companyId,[userDef valueForKey:@"AuthKey"],strDate,strDate,mobile];
    }
    
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}


//create trip
-(void)createTripForAuthKey:(NSString *)authKey andTripName:(NSString *)tripName andCompanyId:(NSString *)companyId withCompletionBlock:(CreateTripCompletionBlock)completionBlock
{
    //authId,tripName,companyId
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com:8080/giddh/tripcreate.jsp?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&tripName=%@&companyId=%@",authKey,tripName,companyId];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}


//Share Trip with Email
-(void)shareTripForAuthKey:(NSString *)authKey companyId:(NSString*)companyId andTripId:(int)tripId andEmail:(NSString *)email withCompletionBlock:(CreateTripCompletionBlock)completionBlock
{
    //authId,tripId,email
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com:8080/giddh/tripshare.jsp?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&tripId=%d&email=%@&companyId=%@",authKey,tripId,email,companyId];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}

//Edit Trip
-(void)editTripForAuthKey:(NSString *)authKey andTripName:(NSString *)tripName andTripId:(int)tripId andCompanyId:(int)companyId withCompletionBlock:(CreateTripCompletionBlock)completionBlock
{
    //authId,tripId,tripName,companyId
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com:8080/giddh/tripedit.jsp?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&tripId=%d&tripName=%@&companyId=%d",authKey,tripId,tripName,companyId];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}

//Delete Trip
-(void)deleteTripForAuthKey:(NSString *)authKey andTripId:(int)tripId andCompanyId:(int)companyId withCompletionBlock:(DeleteTripCompletionBlock)completionBlock
{
    //authId,tripId,companyId
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com:8080/giddh/tripdelete.jsp?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&tripId=%d&companyId=%d",authKey,tripId,companyId];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}

//Remove email from trip
-(void)removeEmailForAuthKey:(NSString *)authKey andTripId:(int)tripId andCompanyId:(int)companyId andEmail:(NSString *)email withCompletionBlock:(DeleteTripCompletionBlock)completionBlock
{
    //authId,tripId,companyId,email
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com:8080/giddh/tripemailremove.jsp?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&tripId=%d&companyId=%d&email=%@",authKey,tripId,companyId,email];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}

//Sync Trip List
-(void)syncTripForAuthKey:(NSString *)authKey andCompanyId:(int)companyId withCompletionBlock:(SyncTripCompletionBlock)completionBlock
{
    //authId,companyId
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com:8080/giddh/tripgetlist.jsp?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&companyId=%d",authKey,companyId];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}

//Sync Email List
-(void)syncEmailForAuthKey:(NSString *)authKey andCompanyId:(int)companyId andTripId:(int)tripId withCompletionBlock:(SyncEmailCompletionBlock)completionBlock
{
    //authId,companyId,tripId
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com:8080/giddh/tripgetinfo.jsp?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&companyId=%d&tripId=%d",authKey,companyId,tripId];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}

//trip Summary Method
-(void)getTripSummaryForAuthKey:(NSString *)authKey companyId:(int)companyId andTripId:(int)tripId andEntryId:(int)entryId withCompletionBlock:(TripSummaryCompletionBlock)completionBlock
{
    //authId,companyId,tripId,entryId
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com:8080/giddh/tripsummary.jsp?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&companyId=%d&tripId=%d&entryId=%d",authKey,companyId,tripId,entryId];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}

//Settings: update Company Name Method
-(void)updateCompanyNameForAuthKey:(NSString *)authKey prevCompanyName:(NSString *)prevName andNewCompanyName:(NSString *)newName withCompletionBlock:(CompanyNameCompletionBlock)completionBlock
{
    //authId,companyName,newCompanyName,mobile
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com/api/updateCompanyName?"];
    
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&companyName=%@&newCompanyName=%@&mobile=1",authKey,prevName,newName];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
}
-(void)updateEntryforAuthKey:(NSString *)authKey andcompanyName:(NSString *)companyName forEntryId:(NSString *)entryId date:(NSString *)date description:(NSString *)description mobile:(NSString *)mobile debit:(NSString *)debit credit:(NSString *)credit tripId:(NSNumber*)tripId withCompletionBlock:(UpdateEntryCompletionBlock)completionBlock{
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com/api/updateEntry?"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"entryId=%@&companyName=%@&authId=%@&date=%@&description=%@&mobile=1&debit=%@&credit=%@",entryId,companyName,[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"],date,description,debit,credit];
    if(![tripId isEqual:nil]){
        strPost = [NSString stringWithFormat:@"entryId=%@&companyName=%@&authId=%@&date=%@&description=%@&mobile=1&debit=%@&credit=%@&tripId=%@",entryId,companyName,[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"],date,description,debit,credit,tripId];

    }
     //NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];

}
//add Account
-(void)addAccountForAuthKey:(NSString *)authKey andCompanyId:(int)compId companyName:(NSString *)compName groupName:(NSString *)groupName accountName:(NSString *)accountName uniqueName:(NSString *)uniqueName openingBalance:(NSString *)openingBal openingBalanceType:(int)balanceType withCompletionBlock:(AddAccountCompletionBlock)completionBlock
{
    //authId,companyId,companyName,groupName,accountName,uniqueName,mobile,openingBalance
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com/api/addAccountApi?"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&companyId=%d&companyName=%@&groupName=%@&accountName=%@&uniqueName=%@&openingBalance=%@&openingBalanceType=%d",authKey,compId,compName,groupName,accountName,uniqueName,openingBal,balanceType];
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];

}

//update account
-(void)updateAccountForAuthKey:(NSString *)authKey companyName:(NSString *)compName oldAccountName:(NSString *)oldAccName oldUniqueName:(NSString *)oldUniqueName accountName:(NSString *)accountName uniqueName:(NSString *)uniqueName openingBalance:(NSString *)openingBal openingBalanceType:(int)balanceType withCompletionBlock:(AddAccountCompletionBlock)completionBlock
{
    //authId,oldAccountName,oldUniqueName,mobile,openingBalance
    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com/api/updateAccount?"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost;
    if ([accountName isEqualToString:oldAccName])
    {
          strPost = [NSString stringWithFormat:@"authId=%@&accountNameOld=%@&uniqueNameOld=%@&accountName=%@&uniqueName=%@&openingBalance=%@&openingBalanceType=%d&mobile=1&companyName=%@",authKey,oldAccName,oldUniqueName,accountName,uniqueName,openingBal,balanceType,compName];
    } else {
         strPost = [NSString stringWithFormat:@"authId=%@&accountNameOld=%@&uniqueNameOld=%@&accountName=%@&uniqueName=%@&openingBalance=%@&openingBalanceType=%d&mobile=1&companyName=%@&type=2",authKey,oldAccName,oldUniqueName,accountName,uniqueName,openingBal,balanceType,compName];
    }
   
    
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------------
// hussain api section


-(void)getAccountListForAuthKey:(NSString*)authKey companyName:(NSString*)companyName companyid:(NSString*)companyId andMobile:(NSString*)mobile withCompletionBlock:(CompanyListCompletionBlock)completionBlock{
    NSString *strUrl = [NSString stringWithFormat:@"%@accountList",domainName];
    //http://giddh.com/api/accountList?companyId=22&authId=3EhnefWYEi06DiB551277e1&companyName=ravi%20soni&mobile=1
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"companyName=%@&authId=%@&companyId=%@&mobile=%@",companyName,[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"],companyId,mobile];
    // NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];

}
-(void)getEntrySummaryForAuthKey:(NSString*)authKey companyid:(NSString*)companyId andEntryId:(NSString*)entryId withCompletionBlock:(EntrySummaryCompletionBlock)completionBlock{
    NSString *strUrl = [NSString stringWithFormat:@"http://www.giddh.com:8080/giddh/entrysummary.jsp"];
    //http://giddh.com/api/accountList?companyId=22&authId=3EhnefWYEi06DiB551277e1&companyName=ravi%20soni&mobile=1
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&companyId=%@&entryId=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"],companyId,entryId];
    //NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];

}

-(void)createEntryForAuthKey:(NSString *)authKey andTripId:(int)tripId andMobile:(NSString *)mobile date:(NSString*)date companyName:(NSString *)companyName withDescription:(NSString *)description withDebit:(NSString *)arrDebit andCredit:(NSString *)arrCredit withTransactionType:(NSString*)transactionType andUniqueName:(NSString*)uniqueName withCompletionBlock:(CreateEntryCompletionBlock)completionBlock{
    NSString *strUrl = [NSString stringWithFormat:@"%@createEntry",domainName];
    //http://giddh.com/api/accountList?companyId=22&authId=3EhnefWYEi06DiB551277e1&companyName=ravi%20soni&mobile=1
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];

    [request setHTTPMethod:@"POST"];
   
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&tripId=%d&mobile=%@&companyName=%@&date=%@&description=%@&debit=%@&credit=%@&transactionType=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"],tripId,mobile,companyName
                         ,date,description,arrDebit,arrCredit,transactionType];
    
    if ((tripId == 0) || (tripId == nil))
    {
        strPost = [NSString stringWithFormat:@"authId=%@&mobile=%@&companyName=%@&date=%@&description=%@&debit=%@&credit=%@&transactionType=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"],mobile,companyName
                             ,date,description,arrDebit,arrCredit,transactionType];
    }
    
    //NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];

}

-(void)deleteEntrywithEntryId:(NSString *)entryId withDeleteStatus:(NSString *)deleteStatus forAuthKey:(NSString *)authKey andCompanyName:(NSString *)companyName withCompletionBlock:(DeleteEntryCompletionBlock)completionBlock
{
    NSString *strUrl = [NSString stringWithFormat:@"%@deleteEntry",domainName];
    //http://giddh.com/api/accountList?companyId=22&authId=3EhnefWYEi06DiB551277e1&companyName=ravi%20soni&mobile=1
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *strPost = [NSString stringWithFormat:@"companyName=%@&authId=%@&deleteStatus=%@&entryId=%@",companyName,[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"],deleteStatus
                         ,entryId];
    
       //NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];

}

-(void)getAllDeletedEntriesforAuthKey:(NSString *)authKey andcompanyid:(NSString *)companyId withCompletionBlock:(GetAllDeleteEntryCompletionBlock)completionBlock{
    NSString *strUrl = [NSString stringWithFormat:@"http://www.giddh.com:8080/account/entry/getAllDeleted"];
   // NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
//    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com:8080/account/entry/getAllDeleted.jsp"];
//    NSLog(@"%@",strUrl);
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
//    
//    [request setHTTPMethod:@"POST"];
    
    NSString *strPost = [NSString stringWithFormat:@"authId=%@&companyId=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"],companyId];
    
    //NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];

}

-(void)deleteAccountForAuthKey:(NSString *)authKey companyid:(NSString *)companyId companyName:(NSString*)companyName forAccountName:(NSString *)accountName uniqueName:(NSString *)uniqueName groupName:(NSString *)grpName withCompletionBlock:(EntrySummaryCompletionBlock)completionBlock{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@deleteAccount",domainName];
    //NSLog(@"%@",strUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"POST"];
    //    NSString *strUrl = [NSString stringWithFormat:@"http://giddh.com:8080/account/entry/getAllDeleted.jsp"];
    //   NSLog(@"%@",strUrl);
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    //
    //    [request setHTTPMethod:@"POST"];
    
    NSString *strPost = [NSString stringWithFormat:@"companyId=%@&authId=%@&companyName=%@&accountName=%@​&uniqueName=%@&groupName=%@​",companyId,[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"],companyName,accountName,uniqueName,grpName];
    
    //NSLog(@"%@",strPost);
    [request setHTTPBody:[strPost dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *responce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            //NSLog(@"%@",responce);
            completionBlock (responce,nil);
        }
        else {
            completionBlock (nil,error);
        }
    }];

}

@end
