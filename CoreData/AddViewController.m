//
//  AddViewController.m
//  CoreData
//
//  Created by Onway on 2017/3/30.
//  Copyright © 2017年 Onway. All rights reserved.
//

#import "AddViewController.h"
#import "AppDelegate.h"
#import "School+CoreDataProperties.h"
#import "Student+CoreDataClass.h"

@interface AddViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *schoolName;
@property (weak, nonatomic) IBOutlet UITextField *schoolArea;
@property (weak, nonatomic) IBOutlet UITextField *studentName;
@property (weak, nonatomic) IBOutlet UITextField *studentNumber;
@property (nonatomic, strong) AppDelegate *appdelegate;

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Do any additional setup after loading the view.
}

- (IBAction)sureAction:(id)sender {
    if ([self.schoolArea.text length] > 0 && [self.schoolName.text length] > 0 && [self.studentName.text length] > 0 && [self.studentNumber.text length] > 0) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"School" inManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
        School *school = [[School alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
        school.name = self.schoolName.text;
        school.area = self.schoolArea.text;
        [self.appdelegate saveContext];
        
        Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
        student.name = self.studentName.text;
        student.number = self.studentNumber.text;
        student.stu_school = school;
        [self.appdelegate saveContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addData" object:nil userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addData" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
