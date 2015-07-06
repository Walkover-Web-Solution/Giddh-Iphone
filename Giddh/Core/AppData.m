//
//  AppData.m
//  MSG91
//
//  Created by shubhendra Agrawal on 05/03/2015.
//  Copyright (c) 2015 Walkover. All rights reserved.
//

#import "AppData.h"
#import "AppDelegate.h"
#import "ServiceManager.h"
#import "Companies.h"
@implementation AppData

SYNTHESIZE_SINGLETON_METHOD(AppData, sharedData);
-(BOOL) isInternetAvailable{
    BOOL available = NO;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (!networkStatus == NotReachable) {
        available = YES;
    }
    return available;
}

#pragma mark SyncCompanyList
-(void) syncCompanyList;
{
    // NSLog(@"authId = %@",[userDef valueForKey:@"AuthKey"]);
    [[ServiceManager sharedManager] getCompanyListForAuthKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"AuthKey"] andMobile:@"1" withCompletionBlock:^(NSDictionary *responce, NSError *error)
     {
         //NSLog(@"data -> %@",responce);
         //NSLog(@"response = %@",responce);
         NSString *strStatus = [responce valueForKey:@"status"];
         //NSLog(@"status = %@",strStatus);
         int intStatus = [strStatus intValue];
         
         //if status is Success
         if (intStatus == 1)
         {
             //save data in database
             AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
             NSManagedObjectContext *context =[appDelegate managedObjectContext];
             
             NSArray *arrAuth = [responce valueForKey:@"data"];
             //NSLog(@"arr auth = %@",arrAuth);
             
             for (NSDictionary *dict in arrAuth)
             {
                 NSNumber *compId = [NSNumber numberWithInt:[[dict valueForKey:@"companyId"] intValue]];
                 NSNumber *compType = [NSNumber numberWithInt:[[dict valueForKey:@"companyType"] intValue]];
                 //NSString *strEmail = [dict valueForKey:@"emailId"];
                 //NSLog(@"email == > %@",strEmail);
                 
                 NSFetchRequest *request = [[NSFetchRequest alloc] init];
                 [request setEntity:[NSEntityDescription entityForName:@"Companies" inManagedObjectContext:context]];
                 
                 NSError *error = nil;
                 NSArray *results = [context executeFetchRequest:request error:&error];
                 
                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId == %@", compId];
                 [request setPredicate:predicate];
                 NSArray *arrData = [results filteredArrayUsingPredicate:predicate].mutableCopy;
                 
                 // add a new company
                 if(arrData.count == 0)
                 {
                     NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Companies" inManagedObjectContext:context];
                     [newDevice setValue:compId forKey:@"companyId"];
                     [newDevice setValue:[dict valueForKey:@"companyName"] forKey:@"companyName"];
                     [newDevice setValue:compType forKey:@"companyType"];
                     [newDevice setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"userEmail"] forKey:@"emailId"];
                     [newDevice setValue:[dict valueForKey:@"financialYear"] forKey:@"financialYear"];
                     //[context insertObject:newDevice];
                     
                 }
                 else
                 {
                     //Update company
                     Companies *company = [arrData objectAtIndex:0];
                     company.companyName = [dict valueForKey:@"companyName"];
                     company.companyType = compType;
                     company.emailId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userEmail"];
                     company.financialYear = [dict valueForKey:@"financialYear"];
                 }
                 if ((compId != 0) && (compId != (id)[NSNull null]))
                 {
                     [context save:&error];
                 }
             }
             //code END
         }
         else
         {
             NSLog(@"Error");
         }
     }];
    
}


@end
