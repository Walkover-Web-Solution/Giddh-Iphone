//
//  ViewController.m
//  Giddh
//
//  Created by Admin on 10/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AppHomeScreeVC.h"
#import "AppDelegate.h"
#import "ServiceManager.h"
#import "MBProgressHUD.h"
#import "homeViewTableVC.h"
#import "Companies.h"
#import "AppData.h"
#import "PersonalHomeVC.h"
#import "SummaryViewController.h"
@interface AppHomeScreeVC ()

-(void)toggleHiddenState:(BOOL)shouldHide;

@end

@implementation AppHomeScreeVC
@synthesize signInButton,logoutFlag;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogOut"]) {
        [FBSession.activeSession closeAndClearTokenInformation];
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* facebookCookies = [cookies cookiesForURL:
                                    [NSURL URLWithString:@"http://login.facebook.com"]];
        for (NSHTTPCookie* cookie in facebookCookies) {
            [cookies deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogOut"];

    }
    [self toggleHiddenState:YES];
    //self.lblLoginStatus.text = @"";
    self.loginButton.readPermissions = @[@"public_profile", @"email"];
    
    self.loginButton.delegate = self;
    //hide outlets
    self.lblName.hidden = YES;
    self.signOutButton.hidden = YES;
    googleTempFlag = false;
    //[self.loginButton addSubview:];
    //Google Sign In
    //[GIDSignInButton class];
    
    //[GIDSignIn sharedInstance].uiDelegate = self;
    
    // Uncomment to automatically sign in the user.
    //[[GIDSignIn sharedInstance] signInSilently];
    
    //[GIDSignInButton class];
    
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    signIn.shouldFetchBasicProfile = YES;
    signIn.delegate = self;
    signIn.uiDelegate = self;
    
    //set button attributes
    /*
    signInButton = [[GIDSignInButton alloc]init];
    signInButton.layer.backgroundColor = [[UIColor redColor]CGColor];
    signInButton.layer.borderWidth = 2.0f;
    signInButton.backgroundColor = [UIColor redColor];

    UIImageView *googleIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    googleIconView.image = [UIImage imageNamed:@"google_social_icon.png"];
    [signInButton addSubview:googleIconView];
    */
    userDef = [NSUserDefaults standardUserDefaults];
    //logout condition
    
    if (logoutFlag)
    {
        [userDef removeObjectForKey:@"AuthKey"];
        [userDef removeObjectForKey:@"userEmail"];
        [userDef removeObjectForKey:@"userName"];
        [userDef removeObjectForKey:@"userAccessToken"];
        
        [self signOutGoogle:self];
    }
    
    //set condition for already logged in user
    NSString *checkAccess = [userDef valueForKey:@"AuthKey"];//[userDef valueForKey:@"userAccessToken"];
    if ((checkAccess.length > 0) && (checkAccess != (id)[NSNull null]) )
    {
        strName = [userDef valueForKey:@"userName"];
        //[self performSegueWithIdentifier:@"homeScreenSegue" sender:nil];
        //[self performSegueWithIdentifier:@"homeTableSegue" sender:nil];
        [self performSegueWithIdentifier:@"userHomeIdentifier" sender:nil];
        return;
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    //set user defaults
    [userDef setValue:@"facebookSignIn" forKey:@"socialType"];
    loginType = @"1";   //login type= 1:facebook and 2:google
    if (googleTempFlag)
    {
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText=@"Accessing..";
    }
   // self.signInButton.colorScheme = kGIDSignInButtonColorSchemeLight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //Dispose of any resources that can be recreated.
}

#pragma mark Facebook Login Methods
-(void)toggleHiddenState:(BOOL)shouldHide
{
    //self.lblUsername.hidden = shouldHide;
    //self.lblEmail.hidden = shouldHide;
    //self.profilePicture.hidden = shouldHide;
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    //self.lblLoginStatus.text = @"You are logged in.";
    [self toggleHiddenState:NO];
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    //NSLog(@"%@", user);
    //self.profilePicture.profileID = user.id;
    
    //user.
    
    //NSLog(@"FB userid = %@ , username = %@ , email = %@,accesstoken = %@",user.id,user.name,user.email,user.access);
    //self.lblEmail.text = [user objectForKey:@"email"];
    
    //save user data
    //name
    self.lblName.text = user.name;
    strName = user.name;
    
    //email
    strEmail = [user objectForKey:@"email"];
    
    //NSString *checkAccess = [userDef valueForKey:@"AuthKey"];
   //if ((checkAccess.length == 0) || (checkAccess == (id)[NSNull null]) )
    //{
        //access token
        accToken = [[[FBSession activeSession] accessTokenData] accessToken];
        //NSLog(@"fb acc token = %@",accToken);
        
    //hit API for generating authentication key
    if (!logoutFlag)
    {
        [self getAuthenticationKeyForToken:accToken andLoginType:@"1"];
    }
    else if([[userDef valueForKey:@"checkLogin"] isEqualToString:@"newLogin"])
    {
        [self getAuthenticationKeyForToken:accToken andLoginType:@"1"];
    }
    else if (accToken.length > 0)
    {
        [self getAuthenticationKeyForToken:accToken andLoginType:@"1"];
    }
    
    [userDef setValue:strEmail forKey:@"userEmail"];
    [userDef setValue:strName forKey:@"userName"];
    [userDef setValue:accToken forKey:@"userAccessToken"];
        
        //[self performSegueWithIdentifier:@"homeScreenSegue" sender:nil];
        //[self performSegueWithIdentifier:@"homeTableSegue" sender:nil];
    //}
    
}

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error{
    //NSLog(@"%@", [error localizedDescription]);
}

#pragma mark Google Sign In Methods
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //access token
    GIDAuthentication *auth  = user.authentication;
   // NSLog(@"access token = %@",auth.accessToken);
    accToken = auth.accessToken;
    
    if (accToken.length > 0)
    {
        if (!logoutFlag)
        {
            [self getAuthenticationKeyForToken:accToken andLoginType:@"2"];
        }
        else if([[userDef valueForKey:@"checkLogin"] isEqualToString:@"newLogin"])
        {
            [self getAuthenticationKeyForToken:accToken andLoginType:@"2"];
        }
        else if (accToken.length > 0)
        {
            [self getAuthenticationKeyForToken:accToken andLoginType:@"2"];
        }
    }
    
    
    //NSString *userId = user.userID;
    strEmail = user.profile.email;
    
    //profile name
    GIDProfileData *proData = user.profile;
   // NSLog(@"dataa = %@",proData.name);
    strName = proData.name;
    
    //user id and email
   // NSLog(@"user = %@ and email = %@ and des = %@ and ser = %@", userId,strEmail,user.description,user.serverAuthCode);
    
    // Perform any operations on signed in user here.
    
    [self performSelector:@selector(storeGoogleData) withObject:nil afterDelay:0.125];
    
    
}

-(void) storeGoogleData
{
    self.lblName.text = @"Signed in user";
    
    
    [self reportAuthStatus];
    [self updateButtons];
    
    //set condition to skip hittting API
    //NSString *checkAccess = [userDef valueForKey:@"AuthKey"];
    //if ((checkAccess.length == 0) || (checkAccess == (id)[NSNull null]) )
    //{
    [userDef setValue:strEmail forKey:@"userEmail"];
    [userDef setValue:strName forKey:@"userName"];
    [userDef setValue:accToken forKey:@"userAccessToken"];
    
    //[self performSegueWithIdentifier:@"homeScreenSegue" sender:nil];
    //[self performSegueWithIdentifier:@"homeTableSegue" sender:nil];
    
    //}
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    //Perform any operations when the user disconnects from app here.
    self.lblName.text = @"Disconnected user";
    [self reportAuthStatus];
    [self updateButtons];
}

- (void)signOut
{
    [[GIDSignIn sharedInstance] signOut];
    [[NSUserDefaults standardUserDefaults] setValue:@"newLogin" forKey:@"checkLogin"];
    [self reportAuthStatus];
    [self updateButtons];
}

- (void)reportAuthStatus {
    GIDGoogleUser *googleUser = [[GIDSignIn sharedInstance] currentUser];
    if (googleUser.authentication)
    {
        self.lblName.text = @"Status: Authenticated";
    }
    else
    {
        // To authenticate, use Google+ sign-in button.
        self.lblName.text = @"Status: Not authenticated";
    }
    
    [self refreshUserInfo];
}

// Update the interface elements containing user data to reflect the
// currently signed in user.
- (void)refreshUserInfo {
    if ([GIDSignIn sharedInstance].currentUser.authentication == nil) {
        return;
    }
    
    if (![GIDSignIn sharedInstance].currentUser.profile.hasImage) {
        // There is no Profile Image to be loaded.
        return;
    }
    // Load avatar image asynchronously, in background
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)updateButtons {
    BOOL authenticated = ([GIDSignIn sharedInstance].currentUser.authentication != nil);
    
    signInButton.enabled = !authenticated;
    self.signOutButton.enabled = authenticated;

    //self.disconnectButton.enabled = authenticated;
    //self.credentialsButton.hidden = !authenticated;
    
    if (authenticated)
    {
        self.signInButton.alpha = 0.5;
        self.signOutButton.alpha = 1.0;
    } else {
        self.signInButton.alpha = 1.0;
        self.signOutButton.alpha = 0.5;
    }
}

- (IBAction)signOutGoogle:(id)sender
{
    [userDef setValue:@"facebookSignIn" forKey:@"socialType"];
    [userDef setValue:@"" forKey:@"checkLogin"];
    [[GIDSignIn sharedInstance] signOut];
    [self reportAuthStatus];
    [self updateButtons];
}

- (IBAction)customSignInAction:(id)sender
{
    googleTempFlag = true;
    [userDef setValue:@"googleSignIn" forKey:@"socialType"];
}

- (IBAction)customFacebookSignInAction:(id)sender
{
    [userDef setValue:@"facebookSignIn" forKey:@"socialType"];
}

//Navigation Method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark API Methods
-(void) getAuthenticationKeyForToken:(NSString *)token andLoginType:(NSString *)type
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Authenticating";
    
    [[ServiceManager sharedManager ] getAuthKeyForToken:token andloginType:type withCompletionBlock:^(NSDictionary *responce, NSError *error)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
       // NSLog(@"response = %@",responce);
        NSString *strStatus = [responce valueForKey:@"status"];
        //NSLog(@"status = %@",strStatus);
        int intStatus = [strStatus intValue];
        
        if (intStatus == 1)
        {
            NSArray *arrAuth = [responce valueForKey:@"data"];
            NSString *strAuth = arrAuth[0];
            [userDef setValue:strAuth forKey:@"AuthKey"];
            [self getCompanyList];
            //[self performSegueWithIdentifier:@"homeTableSegue" sender:nil];
          //  [self performSegueWithIdentifier:@"userHomeIdentifier" sender:nil];
            
        } else
        {
            //NSLog(@"Error");
        }
    }];
}

-(void) getCompanyList
{
    if( [[AppData sharedData]isInternetAvailable])
    {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"Authenticating";
        
    }
    
    // NSLog(@"authId = %@",[userDef valueForKey:@"AuthKey"]);
    [[ServiceManager sharedManager] getCompanyListForAuthKey:[userDef valueForKey:@"AuthKey"] andMobile:@"1" withCompletionBlock:^(NSDictionary *responce, NSError *error)
     {
         //NSLog(@"data -> %@",responce);
         [MBProgressHUD hideHUDForView:self.view animated:YES];
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
                     [newDevice setValue:[userDef valueForKey:@"userEmail"] forKey:@"emailId"];
                     [newDevice setValue:[dict valueForKey:@"financialYear"] forKey:@"financialYear"];
                     //[context insertObject:newDevice];
                     
                 }
                 else
                 {
                     //Update company
                     Companies *company = [arrData objectAtIndex:0];
                     company.companyName = [dict valueForKey:@"companyName"];
                     company.companyType = compType;
                     company.emailId = [userDef valueForKey:@"userEmail"];
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
         [self getLocalCompanies];
         //fetch updated data from local database
     }];
    
}
-(void) getLocalCompanies
{
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *checkAccess = [userDef valueForKey:@"AuthKey"];//[userDef valueForKey:@"userAccessToken"];
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Companies"];
    NSArray * arrCompanies = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];

    NSEntityDescription *entityDescr=[NSEntityDescription entityForName:@"Entries" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDescr];
    NSError *error;
    NSArray * arrEntries = [[managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    if(arrCompanies.count==1){
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
            [self presentViewController:navController animated:YES completion:NULL];

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
            [self presentViewController:navController2 animated:YES completion:NULL];

        }
        
    }
    else{
        [self performSegueWithIdentifier:@"userHomeIdentifier" sender:nil];

    }
}

@end
