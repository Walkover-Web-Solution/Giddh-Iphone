//
//  ViewController.h
//  Giddh
//
//  Created by Admin on 10/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FacebookSDK/FacebookSDK.h>

//Google SignIn
#import <GoogleSignIn/GoogleSignIn.h>

@interface AppHomeScreeVC : UIViewController<FBLoginViewDelegate,GIDSignInUIDelegate>
{
    NSUserDefaults *userDef;
    NSString *strName,*strEmail,*accToken,*loginType;
    BOOL googleTempFlag;
}

//@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;
@property (weak, nonatomic) IBOutlet FBLoginView *loginButton;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet GIDSignInButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (nonatomic) BOOL logoutFlag;
- (IBAction)signOutGoogle:(id)sender;
- (IBAction)customSignInAction:(id)sender;
- (IBAction)customFacebookSignInAction:(id)sender;

@end

