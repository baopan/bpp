//
//  ViewController.m
//  CoreData
//
//  Created by Onway on 2017/3/30.
//  Copyright © 2017年 Onway. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "School+CoreDataProperties.h"
#import "Student+CoreDataProperties.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) AppDelegate *appdelegate;
@property (nonatomic, strong) NSMutableArray *schoolArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (NSMutableArray *)schoolArr {
    if (!_schoolArr) {
        _schoolArr = [NSMutableArray new];
    }
    return _schoolArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveData:) name:@"addData" object:nil];
    
    self.appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    self.schoolArr = [self query];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.schoolArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    School *school = self.schoolArr[section];
    return school.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    School *school = self.schoolArr[section];
    return [school.school_stu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    School *school = self.schoolArr[indexPath.section];
//    NSMutableArray *arr = [NSMutableArray new];
//    for (Student *student in school.school_stu) {
//        [arr addObject:student];
//    }
    NSArray *arr = [school.school_stu allObjects];
    Student *student = arr[indexPath.row];
    cell.textLabel.text = student.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"提示" message:@"修改学生名字？" preferredStyle:UIAlertControllerStyleAlert];
    [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
       textField.placeholder = @"name";
    }];
    [alertCtl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        School *school = self.schoolArr[indexPath.section];
        NSArray *arr = [school.school_stu allObjects];
        Student *student = arr[indexPath.row];
        UITextField *nameTextfield = alertCtl.textFields.firstObject;
        if (nameTextfield.text.length == 0) {
            return ;
        }
        student.name = nameTextfield.text;
        [self.appdelegate saveContext];
        self.schoolArr = [self query];
        [self.tableView reloadData];
    }]];
    [alertCtl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertCtl animated:YES completion:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        School *school = self.schoolArr[indexPath.section];
        NSArray *arr = [school.school_stu allObjects];
        [self.appdelegate.persistentContainer.viewContext deleteObject:arr[indexPath.row]];
        [self.appdelegate saveContext];
        self.schoolArr = [self query];
        [self.tableView reloadData];
        NSLog(@"delete");
    }
}

- (NSMutableArray *)query {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"School" inManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
    NSArray *arr = [self.appdelegate.persistentContainer.viewContext executeFetchRequest:fetchRequest error:nil];
    for (School *school in arr) {
        for (Student *student in school.school_stu) {
            NSLog(@"==%@",student.name);
        }
        NSLog(@"%@---%@",school.name,school.area);
    }

    return [arr mutableCopy];
}

- (void)saveData:(NSNotification *)not {
    self.schoolArr = [self query];
    [self.tableView reloadData];
}

//添加
- (IBAction)addSchool:(id)sender {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"School" inManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
    School *school = [[School alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
    school.name = @"浙江大学";
    school.area = @"杭州";
    [self.appdelegate saveContext];
}

//删除
- (IBAction)deleteAction:(id)sender {
    if ([self.schoolArr count] == 0) {
        return;
    }
    [self.appdelegate.persistentContainer.viewContext deleteObject:self.schoolArr[0]];
    [self.appdelegate saveContext];
}

//修改
- (IBAction)modifyAction:(id)sender {
    School *school = self.schoolArr[0];
    school.name = @"深圳大学";
    school.area = @"深圳";
    [self.appdelegate saveContext];
}

//查询
- (IBAction)queryAction:(id)sender {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"School" inManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    self.schoolArr = [[self.appdelegate.persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (self.schoolArr == nil) {
        NSLog(@"------");
    }else {
        for (School *school in self.schoolArr) {
            for (Student *student in school.school_stu) {
                NSLog(@"==%@",student.name);
            }
            NSLog(@"%@---%@",school.name,school.area);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
