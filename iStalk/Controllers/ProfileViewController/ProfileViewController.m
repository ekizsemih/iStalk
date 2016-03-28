//
//  ProfileViewController.m
//  iStalk
//
//  Created by Semih EKIZ on 14/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import "ProfileViewController.h"
#import "PECropViewController.h"

@interface ProfileViewController ()<PECropViewControllerDelegate>{
    NSInteger pickerNum;
    CGPoint svos;
    UIPickerView *pickerView;
    UIView *fullView, *actionSheet;
}

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic) UIPopoverController *popover;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeFunction];
}

- (void)initializeFunction{
    [Utils flurry:@"ProfileEditScreen" withlogError:@"ProfileEdit_Error"];
    
    [self setNeedsStatusBarAppearanceUpdate];
    pickerNum = [[Session identity].gender integerValue]-1;
    genderArray = [NSMutableArray new];
    [genderArray addObject:[Utils localizedString:@"ITGenderUnspecified"]];
    [genderArray addObject:[Utils localizedString:@"ITGenderMale"]];
    [genderArray addObject:[Utils localizedString:@"ITGenderFemale"]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)keyboardHide:(UITapGestureRecognizer *)gr {
    [self scrollFunction];
    [UIView animateWithDuration:0.5 animations:^{
        [[self getCell].textField1 resignFirstResponder];
        [[self getCell].textField2 resignFirstResponder];
        [[self getCell].textField3 resignFirstResponder];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

- (IBAction)leftMenuFunction:(id)sender {
    [[SlideNavigationController sharedInstance] openMenu:MenuLeft withCompletion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableVC" object:nil];
    }];
}

#pragma mark - UITextField Delegates

- (NSString*)formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar {
    if(simpleNumber.length ==0 ) return @"";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
    if(simpleNumber.length>10)
        simpleNumber = [simpleNumber substringToIndex:10];
    
    if(deleteLastChar)
        simpleNumber = [simpleNumber substringToIndex:[simpleNumber length] - 1];
    
    if(simpleNumber.length<7)
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"($1) $2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    
    else
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    return simpleNumber;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    if(textField.tag == 6) {
        if (range.length == 1)
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:YES];
        else
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:NO ];
        return false;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    
    NSInteger nextTag = textField.tag + 1;
    
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder)
        [nextResponder becomeFirstResponder];
    else {
        [textField resignFirstResponder];
        [self keyboardHide:nil];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (5 > textField.tag)
        return;
    
    svos = _tableView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:_tableView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 140;
    [_tableView setContentOffset:pt animated:YES];
}

#pragma mark - Functions

- (void)scrollFunction{
    [UIView animateWithDuration:0.5 animations:^{
        [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }];
}

- (void)genderFunction:(id)sender{
    
    [self keyboardHide:nil];
    
    fullView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [Utils screenWidth], [Utils screenHeight])];
    fullView.backgroundColor = COLOR_RGBA(0, 0, 0, 0.8);
    fullView.alpha = 0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelFunction)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [fullView addGestureRecognizer:tap];
    
    actionSheet = [[UIView alloc] initWithFrame:CGRectMake(0, [Utils screenHeight]+250, [Utils screenWidth], 250)];
    actionSheet.backgroundColor = COLOR_RGBA(0, 0, 0, 0.8);
    
    CGRect pickerFrame = CGRectMake(0, 44, [Utils screenWidth], 206);
    
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.backgroundColor = [UIColor whiteColor];
    
    pickerView.showsSelectionIndicator=YES;
    
    [pickerView setDelegate: self];
    
    UIToolbar *controllToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, actionSheet.bounds.size.width, 44)];
    
    [[controllToolBar subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [actionSheet addSubview:pickerView];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *setButton = [[UIBarButtonItem alloc] initWithTitle:[Utils localizedString:@"ITOk"] style:UIBarButtonItemStyleDone target:self action:@selector(setFunction)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:[Utils localizedString:@"ITDismiss"] style:UIBarButtonItemStyleDone target:self action:@selector(cancelFunction)];
    
    UIBarButtonItem *spaceItemBetweenbuttons = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemFixedSpace) target:nil action:nil];
    
    spaceItemBetweenbuttons.width = 10.0f;
    
    [controllToolBar setItems:[NSArray arrayWithObjects:spacer, cancelButton, spaceItemBetweenbuttons, setButton, nil] animated:NO];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >=7.0) {
        controllToolBar.barTintColor = [UIColor lightGrayColor];
        
        setButton.tintColor = [UIColor whiteColor];
        
        cancelButton.tintColor = [UIColor whiteColor];
    }
    
    [actionSheet addSubview:controllToolBar];
    
    [pickerView selectRow:pickerNum inComponent:0 animated:YES];
    
    [fullView addSubview:actionSheet];
    [self.view addSubview:fullView];
    [UIView animateWithDuration:0.5 animations:^{
        fullView.alpha = 1;
        actionSheet.transform = CGAffineTransformMakeTranslation(0, -250*2);
    }];
}

- (void)setFunction{
    pickerNum = [pickerView selectedRowInComponent:0];
    [[self getCell].genderButton setTitle:[genderArray objectAtIndex:pickerNum] forState:UIControlStateNormal];
    [self cancelFunction];
}

- (void)cancelFunction{
    [UIView animateWithDuration:0.5 animations:^{
        fullView.alpha = 0;
        actionSheet.transform  = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        [fullView removeFromSuperview];
    }];
}

- (void)backFunction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendFunction:(id)sender {
    
    NSString *namesurname = [self getCell].textField1.text;
    NSString *username = [self getCell].textField2.text;
    NSString *email = [self getCell].textField3.text;
    NSString *photoStr;
    
    if ([Utils stringIsEmpty:namesurname]||[Utils stringIsEmpty:username]||[Utils stringIsEmpty:email])
        [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"ITAllFieldsAreRequired"] withTag:1];
    
    
    if (![Utils stringIsValidEmail:email]){
        [self showAlertView:@"ITAttention" withMessage:[Utils localizedString:@"ITWrongEmail"] withTag:1];
        return;
    }
    
    [self keyboardHide:nil];

    if ([UIImagePNGRepresentation ([self getCell].profileImageButton.currentBackgroundImage) isEqualToData:UIImagePNGRepresentation([UIImage imageWithData:[Session identity].imageData])])
        photoStr = @"-";
    else
        photoStr = [Utils base64forData:[Utils imageWithImage:[self getCell].profileImageButton.currentBackgroundImage scaledToSize:CGSizeMake(640, 640)]];
    
    id params = @{
                  @"userid":[Session identity].userid,
                  @"servicetoken":servicetoken,
                  @"apptoken":[Session identity].userToken,
                  @"namesurname":namesurname,
                  @"username":username,
                  @"email":email,
                  @"gender":[NSString stringWithFormat:@"%ld",(long)pickerNum+1],
                  @"devicetoken":[Utils objForPrefKey:@"UserDeviceToken"],
                  @"photostr":photoStr
                  };
    
    [Utils callPostApi:updateuser params:params integer:0 withType:0 progress:nil success:^(id responseObject) {
        id data = [Utils jsonWithData:responseObject error:nil];
        if ([[data objectForKey:@"returnCode"] boolValue]) {
            [Session identity].nameSurname = namesurname;
            [Session identity].username = username;
            [Session identity].email = email;
            [Session identity].gender = @(pickerNum+1);
            [Session identity].imageData = [Utils imageWithImage:[self getCell].profileImageButton.currentBackgroundImage scaledToSize:CGSizeMake(640, 640)];
        }
        
        [self showAlertView:nil withMessage:[data objectForKey:@"statusMessage"] withTag:1];
    } failure:^(NSError *error){
        NSLog(@"%@",error);
    }];
}

- (void)showAlertView:(NSString *)title withMessage:(NSString *)message withTag:(int)tag{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[Utils localizedString:title] message:[Utils localizedString:message] delegate:self cancelButtonTitle:[Utils localizedString:@"ITOk"] otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
    return;
    
}

- (IBAction)takePhotoFunction:(id)sender {
    [self keyboardHide:nil];
    UIActionSheet *photoactionSheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        photoactionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:[Utils localizedString:@"ITDismiss"]
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:
                            [Utils localizedString:@"ITTakePhoto"],
                            [Utils localizedString:@"ITPickPhotoFromGallery"],
                            nil];
    } else {
        photoactionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:[Utils localizedString:@"ITDismiss"]
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:
                            [Utils localizedString:@"ITPickPhotoFromGallery"],
                            nil];
    }
    
    [photoactionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2)
        return;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && buttonIndex == 0) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        [imagePicker setDelegate:(id)self];
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        [imagePicker setDelegate:(id)self];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - Action methods

- (IBAction)openEditor:(id)sender{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = [self getCell].profileImageButton.currentBackgroundImage;
    controller.cropAspectRatio = 1;
    controller.keepingCropAspectRatio = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [[self getCell].profileImageButton setBackgroundImage:image forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible)
            [self.popover dismissPopoverAnimated:NO];
        [self updateEditButtonEnabled];
        [self openEditor:nil];
    } else
        [picker dismissViewControllerAnimated:YES completion:^{
            [self openEditor:nil];
        }];
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [[self getCell].profileImageButton setBackgroundImage:croppedImage forState:UIControlStateNormal];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self updateEditButtonEnabled];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self updateEditButtonEnabled];
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)updateEditButtonEnabled{
    self.editButton.enabled = !![self getCell].profileImageButton.currentBackgroundImage;
}

#pragma mark - UIDatePickerDelegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return  [genderArray count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 70;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [Utils screenWidth], 0)];
    label.text = [genderArray objectAtIndex:row];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode =  NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [label sizeToFit];
    label.font = [UIFont fontWithName:@"Verdana" size:13];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProfileEditCell *cell = (ProfileEditCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    cell.textField1.delegate = self;
    cell.textField2.delegate = self;
    cell.textField3.delegate = self;
    
    cell.textField1.text = [Session identity].nameSurname;
    cell.textField2.text = [Session identity].username;
    cell.textField3.text = [Session identity].email;
    
    [cell.genderButton setTitle:[genderArray objectAtIndex:[[Session identity].gender integerValue]-1] forState:UIControlStateNormal];
    [cell.genderButton addTarget:self action:@selector(genderFunction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    if ([Session identity].imageData)
        [cell.profileImageButton setBackgroundImage:[UIImage imageWithData:[Session identity].imageData] forState:UIControlStateNormal];
    else{
        NSMutableURLRequest *imgRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[Session identity].imagePath]];
        [imgRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        [imgRequest setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
        
        [cell.profileImageButton.imageView setImageWithURLRequest:imgRequest
                                                 placeholderImage:[UIImage imageNamed:@"profil-default-pf-pic"]
                                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                                              [Session identity].imageData = UIImagePNGRepresentation(image);
                                                              [cell.profileImageButton setBackgroundImage:[UIImage imageWithData:[Session identity].imageData] forState:UIControlStateNormal];
                                                          } failure:nil];
    }
    
    
    
    [cell.profileImageButton addTarget:self action:@selector(takePhotoFunction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (ProfileEditCell *)getCell{
    return (ProfileEditCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
