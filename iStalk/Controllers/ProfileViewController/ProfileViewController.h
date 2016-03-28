//
//  ProfileViewController.h
//  iStalk
//
//  Created by Semih EKIZ on 14/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDelegate>{
    NSMutableArray *genderArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)sendFunction:(id)sender;
@end
