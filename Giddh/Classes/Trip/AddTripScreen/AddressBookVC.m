//
//  AddressBookVC.m
//  Giddh
//
//  Created by Admin on 21/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AddressBookVC.h"
#import <AddressBook/AddressBook.h>
#import "Person.h"
#import "AddTripVC.h"

@interface AddressBookVC ()

@end

@implementation AddressBookVC
@synthesize checkEditFlag;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    allContactsInfo = [NSMutableArray array];
    arrContactEmail = [NSMutableArray array];
    arrContactName = [NSMutableArray array];
    arrTableData = [NSMutableArray array];
    arrSelectedPerson = [NSMutableArray array];
    // Do any additional setup after loading the view.
    
    //addressbook contacts
    [self getAddressBookContacts];
    
    //remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return arrTableData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Person *personObj = arrTableData[indexPath.row];
    
    cell.textLabel.text = personObj.name;
    cell.detailTextLabel.text = personObj.emailId;
    //set font family
    cell.textLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
    return cell;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        Person *selPerson = arrTableData[indexPath.row];
        [arrSelectedPerson addObject:selPerson];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        Person *selPerson = arrTableData[indexPath.row];
        [arrSelectedPerson removeObject:selPerson];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark Address Book Methods
-(BOOL)isABAddressBookCreateWithOptionsAvailable {
    return &ABAddressBookCreateWithOptions != NULL;
}

-(void) getAddressBookContacts
{
    [arrContactName removeAllObjects];
    [arrContactEmail removeAllObjects];
    
    CFErrorRef * error = NULL;
    ABAddressBookRef *addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
                                                         CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
                                                         
                                                         for(int i = 0; i < numberOfPeople; i++){
                                                             ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                                                             
                                                             NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                                                             NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                                                             //NSLog(@"Name:%@ %@", firstName, lastName);
                                                             if (firstName.length == 0)
                                                             {
                                                                 firstName = @"";
                                                             }
                                                             if (lastName.length == 0)
                                                             {
                                                                 lastName = @"";
                                                             }
                                                             ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                                                             
                                                             ABMultiValueRef emails = ABRecordCopyValue(person,kABPersonEmailProperty);
                                                             NSUInteger j = 0;
                                                             for (j = 0; j < ABMultiValueGetCount(emails); j++)
                                                             {
                                                                 //NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
                                                                 
                                                                 //Challenges *newChallenge = [[Challenge alloc]initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
                                                                 //
                                                                 //NSManagedObjectContext *context = [self managedObjectContext];
                                                                 Person *objPerson = [[Person alloc]init];
                                                                 
                                                                 NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                                                                 
                                                                 //check valid email
                                                                 BOOL isValid = [self NSStringIsValidEmail:email];
                                                                 if (isValid)
                                                                 {
                                                                     //NSLog(@"name -> %@ %@",firstName,lastName);
                                                                     if (j == 0)
                                                                     {
                                                                         NSString *strSave;
                                                                         if ((firstName.length == 0) && (lastName.length == 0))
                                                                         {
                                                                             strSave = @"";
                                                                         }
                                                                         else
                                                                         {
                                                                             strSave = [NSString stringWithFormat:@"%@ %@ (Home)",firstName,lastName];
                                                                         }
                                                                         [arrContactName addObject:strSave];
                                                                         [arrContactEmail addObject:email];
                                                                         objPerson.name = strSave;
                                                                         //persons.homeEmail = email;
                                                                         //NSLog(@"email home -=> %@",email);
                                                                     }
                                                                     else if (j==1)
                                                                     {
                                                                         NSString *strSave;
                                                                         if ((firstName.length == 0) && (lastName.length == 0))
                                                                         {
                                                                             strSave = @"";
                                                                         }
                                                                         else
                                                                         {
                                                                             strSave = [NSString stringWithFormat:@"%@ %@ (Work)",firstName,lastName];
                                                                         }
                                                                         objPerson.name = strSave;
                                                                         [arrContactName addObject:strSave];
                                                                         [arrContactEmail addObject:email];
                                                                     }
                                                                     objPerson.emailId = email;
                                                                     [arrTableData addObject:objPerson];
                                                                 }
                                                                 else
                                                                 {
                                                                    // NSLog(@"Invalid Email");
                                                                 }
                                                                 
                                                                 //persons.workEmail = email;
                                                                 //NSLog(@"email work-=> %@",email);
                                                                 
                                                             }
                                                             
                                                             //reload table
                                                             [self.tableView reloadData];
                                                             
                                                             NSMutableArray *numbers = [NSMutableArray array];
                                                             for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
                                                             {
                                                                 NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                                                                 [numbers addObject:phoneNumber];
                                                             }
                                                             
                                                             NSMutableDictionary *contact = [NSMutableDictionary dictionary];
                                                             if (firstName.length == 0)
                                                             {
                                                                 firstName = @"";
                                                             }
                                                             [contact setObject:firstName forKey:@"name"];
                                                             [contact setObject:numbers forKey:@"numbers"];
                                                             
                                                             [allContactsInfo addObject:contact];
                                                         }
                                                     });
                                                     //return allContactsInfo;
                                                     //NSLog(@"all contacts = %@",allContactsInfo);
                                                     [self.tableView reloadData];
                                                 }
                                                 
                                             });
    
}

#pragma mark Email Validation

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

/*
 #pragma mark DB Methods
 - (NSManagedObjectContext *)managedObjectContext {
 NSManagedObjectContext *context = nil;
 id delegate = [[UIApplication sharedApplication] delegate];
 if ([delegate performSelector:@selector(managedObjectContext)]) {
 context = [delegate managedObjectContext];
 }
 return context;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    /*
     AddTripVC *vc = [segue destinationViewController];
     NSLog(@"vc = %@",vc);
     vc.arrSelectedPersons = arrSelectedPerson;
     [self.navigationController popToViewController:vc animated:YES];
     */
    if ([[segue identifier] isEqualToString:@"backIdentifier"])
    {
        AddTripVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTripVC"];
        vc.arrSelectedPersons = arrSelectedPerson;
        [self.navigationController popToViewController:vc animated:YES];
    }
}


- (IBAction)doneAction:(id)sender
{
    if (arrSelectedPerson.count > 0)
    {
        //[self performSegueWithIdentifier:@"backIdentifier" sender:nil];
        int index = 0;
        if (checkEditFlag)
        {
            index = 3;
        }
        else
        {
            index = 2;
        }
        
        //AddTripVC *vc = [self.navigationController.viewControllers objectAtIndex:index];
        int prevVC = [self.navigationController.viewControllers count];
        AddTripVC *vc = [self.navigationController.viewControllers objectAtIndex:prevVC-2];
        //NSLog(@"vc = %@",vc);
        vc.arrSelectedPersons = arrSelectedPerson;
        [self.navigationController popToViewController:vc animated:YES];
        
        /*
         AddTripVC *vc = [[AddTripVC alloc]init];
         vc.arrSelectedPersons = arrSelectedPerson;
         //[self.navigationController presentViewController:vc animated:YES completion:nil];
         [self.navigationController popToViewController:vc animated:YES];
         */
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
@end
