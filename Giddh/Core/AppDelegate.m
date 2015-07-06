//
//  AppDelegate.m
//  Giddh
//
//  Created by Admin on 10/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AppDelegate.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "homeViewTableVC.h"
#import "TripHomeVC.h"
#import "MBProgressHUD.h"
#import "AppHomeScreeVC.h"
#import "UserHomeVC.h"
#import "SummaryViewController.h"
#import "Companies.h"
#import "PersonalHomeVC.h"
#import "AppData.h"
#import <SplunkMint/SplunkMint.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize socialString;

//#import <FBSDKCoreKit/FBSDKCoreKit.h>

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   // [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
    NSArray* fontFamilies = [UIFont familyNames];
    for(NSString* family in fontFamilies)
    {
        NSArray* fonts = [UIFont fontNamesForFamilyName:family];
        
        for(NSString* fontName in fonts)
        {
            NSLog(@"%@", fontName);
        }
    }
    */
    [FBLoginView class];
    //Google Sign In
    [GIDSignIn sharedInstance].clientID = @"402794356201-aimr06ft92u7h5d2rie9qq1tlc1ljihu.apps.googleusercontent.com";
  //[GIDSignIn sharedInstance].clientID = @"589453917038-qaoga89fitj2ukrsq27ko56fimmojac6.apps.googleusercontent.com";
                                          //402794356201-aimr06ft92u7h5d2rie9qq1tlc1ljihu.apps.googleusercontent.com
 //   [[Mint sharedInstance] initAndStartSession:@"e85bcc91"];
    [[Mint sharedInstance] initAndStartSession:@"31c26fc3"];
    //set condition for already logged in user
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *checkAccess = [userDef valueForKey:@"AuthKey"];//[userDef valueForKey:@"userAccessToken"];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Companies"];

    NSManagedObjectContext *context=self.managedObjectContext;
    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray * arrEntries = [[context executeFetchRequest:request error:&error]mutableCopy];
    NSArray * arrCompanies = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if(arrCompanies.count==1){
        [[AppData sharedData]syncCompanyList];
        if(arrEntries.count == 0){
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionsStroryboard" bundle:nil];
            PersonalHomeVC *vc = [sb instantiateViewControllerWithIdentifier:@"PersonalHomeVC"];
            Companies *companies = arrCompanies[0];
            [[NSUserDefaults standardUserDefaults]setValue:@"transaction" forKey:@"firstPageType"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFirstPageCompany"];
            vc.companies =companies;
            vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            navController.navigationBarHidden =YES;
            self.window.rootViewController=navController;
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]setValue:@"summary" forKey:@"firstPageType"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFirstPageCompany"];
            UIStoryboard *sb2 = [UIStoryboard storyboardWithName:@"Summary" bundle:nil];
            SummaryViewController *vc2 = [sb2 instantiateViewControllerWithIdentifier:@"SummaryViewController"];
            vc2.isFirstTime =YES;
            [[NSUserDefaults standardUserDefaults]setValue:@"summary" forKey:@"firstPageType"];

            //vc.globalCompanyId = [self.companies.companyId intValue];
            Companies *companies = arrCompanies[0];
            vc2.companies =companies;
            UINavigationController *navController2 = [[UINavigationController alloc]initWithRootViewController:vc2];
            navController2.navigationBarHidden =YES;
            self.window.rootViewController=navController2;
            
        }

    }
    else if ((checkAccess.length > 0) && (checkAccess != (id)[NSNull null]) )
    {
        //homeViewTableVC *loginController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"homeViewTableVC"]; //or the homeController
        UserHomeVC *userCon=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserHomeVC"];
        UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:userCon];
        self.window.rootViewController=navController;
         /*
        TripHomeVC *loginController=[[UIStoryboard storyboardWithName:@"Trip" bundle:nil] instantiateViewControllerWithIdentifier:@"TripHomeVC"]; //or the homeController
        UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:loginController];
        self.window.rootViewController=navController;
          */
    }
    
    //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:228/255.0f green:103/255.0f blue:68/255.0f alpha:1.0]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:230/255.0f green:103/255.0f blue:61/255.0f alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],NSFontAttributeName: [UIFont fontWithName:@"GothamRounded-Light" size:20.0f],}];
    //UITextAttributeFont: [UIFont fontWithName:@"Arial-Bold" size:0.0],
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    return YES;
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    def = [NSUserDefaults standardUserDefaults];
    
    //NSString *accToken = [[[FBSession activeSession] accessTokenData] accessToken];
    //NSLog(@"fb acc token = %@",accToken);
    if ([[def valueForKey:@"socialType"] isEqualToString:@"facebookSignIn"])
    {
        [def setValue:@"newLogin" forKey:@"checkLogin"];
        return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }
    else
    {
        [def setValue:@"newLogin" forKey:@"checkLogin"];
        AppHomeScreeVC *vc = (AppHomeScreeVC *)[[UIViewController alloc] init];
        UIView *vcView = vc.view;
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:vcView animated:YES];
        hud.labelText=@"Accessing..";
        return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
    }
}

#pragma mark google Signin SDK
- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    // Perform any operations when the user disconnects from app here.
    // ...
    NSLog(@"user disconnected");
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
    // ...
    NSLog(@"user sign in successfully");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.walkover.Giddh" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Giddh" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Giddh.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}
@end
