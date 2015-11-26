//
//  UserInfoViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/14.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "UserInfoViewController.h"
#import "UserInfoCell.h"
#import "UserModel.h"
#import "DescriptionViewController.h"
#import "MainTableViewController.h"

@interface UserInfoViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *logoutButton;
@property (nonatomic, weak) IBOutlet UIButton *avatarImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation UserInfoViewController {
  UIView *_backView;
  UIView *_whiteView;
  UIDatePicker *_picker;
}

#pragma mark - init
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self switchTheme];
  [self.tableView reloadData];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  
  //设置navBav格式
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
  //设置返回button和title
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftArrow"] style:(UIBarButtonItemStylePlain) target:self.revealViewController action:@selector(revealToggle:)];
  leftBarButton.tintColor = [UIColor whiteColor];
  [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
  [self.navigationItem setLeftBarButtonItem:leftBarButton];
  [self.navigationItem setTitle:@"个人信息"];
  
  //圆角的登出button
  self.logoutButton.layer.cornerRadius = 8;
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.scrollEnabled = NO;
  self.tableView.showsVerticalScrollIndicator = NO;
  self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
  
  //设置头像
  NSData *data = [[UserModel currentUser].avatar getData];
  UIImage *image = [UIImage imageWithData:data];
  if (data == nil) {
    image = [UIImage imageNamed:@"noneHead"];
  }
  [self.avatarImageView setImage:image forState:UIControlStateNormal];
  self.avatarImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.avatarImageView.layer.cornerRadius = 50;
  self.avatarImageView.clipsToBounds = YES;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchTheme) name:@"switchTheme" object:nil];
}

- (void)enterBack {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
  [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 视图点击事件
- (IBAction)doLogout:(id)sender {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"知乎日报" message:@"确定退出登录吗？" preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [UserModel logOut];
    //退出后直接进入主界面
    MainTableViewController *mainTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainTableViewController"];
    [self.navigationController pushViewController:mainTableViewController animated:YES];
  }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    [alert dismissViewControllerAnimated:YES completion:nil];
  }];
  [alert addAction:cancel];
  [alert addAction:ok];
  [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)setAvatar:(id)sender {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"设置头像" preferredStyle:UIAlertControllerStyleActionSheet];
  UIAlertAction *fromPic = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
  }];
  UIAlertAction *fromCam = [UIAlertAction actionWithTitle:@"从相机获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
  }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
  [alert addAction:fromCam];
  [alert addAction:fromPic];
  [alert addAction:cancel];
  [self presentViewController:alert animated:YES completion:nil];
  //进入后台是选择关闭alert
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
  
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  UIImage *image = info[UIImagePickerControllerOriginalImage];
  NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
  AVFile *imageFile = [AVFile fileWithName:@"avatar.jpeg" data:imageData];
  [[UserModel currentUser] setObject:imageFile forKey:@"avatar"];
  [[UserModel currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
      NSLog(@"保存成功");
    }
  }];
  self.avatarImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.avatarImageView.layer.cornerRadius = 50;
  self.avatarImageView.clipsToBounds = YES;
  [self.avatarImageView setImage:image forState:UIControlStateNormal];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  //当触摸在_backView范围内
  return touch.view == _backView;
}

- (IBAction)makeCancle:(id)sender {
  [self backViewDismiss];
}

- (IBAction)makeOk:(id)sender {
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"];
  df.dateFormat = @"yyyy'年'MM'月'dd'日'";
  NSString *date = [df stringFromDate:[_picker date]];
  UserInfoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
  cell.detailTextLabel.text = date;
  [[UserModel currentUser] setObject:[_picker date] forKey:@"birthday"];
  [[UserModel currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
      NSLog(@"保存成功");
    }
  }];
  [self backViewDismiss];
}

- (void)backViewDismiss {
  [UIView animateWithDuration:0.2 animations:^{
    _whiteView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 320);
  } completion:^(BOOL finished) {
    [_backView removeFromSuperview];
    [_whiteView removeFromSuperview];
  }];
}

- (void)switchTheme {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (temp) {
    self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    self.logoutButton.backgroundColor = [UIColor colorWithRed:19.0f/255.0f green:152.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
  } else {
    self.view.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f]];
    self.logoutButton.backgroundColor = [UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f];
  }
  [self.tableView reloadData];
}
#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 4;
  }
  return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 22.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"个人信息";
  }
  return @"帐号信息";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UserInfoCell *cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"userTableViewCell"];
  [cell awakeFromNib];
  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.text = @"昵称";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [UserModel currentUser].username];
    }
    if (indexPath.row == 1) {
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.textLabel.text = @"性别";
      GenderType gender = [UserModel currentUser].gender;
      switch (gender) {
        case 0:
          cell.detailTextLabel.text = @"保密";break;
        case 1:
          cell.detailTextLabel.text = @"男♂";break;
        case 2:
          cell.detailTextLabel.text = @"女♀";break;
        default:
          cell.detailTextLabel.text = @"未知";break;
      }
    }
    if (indexPath.row == 2) {
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.textLabel.text = @"生日";
      NSDateFormatter *df = [[NSDateFormatter alloc] init];
      df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"];
      df.dateFormat = @"yyyy'年'MM'月'dd'日'";
      cell.detailTextLabel.text = [df stringFromDate:[UserModel currentUser].birthday];
      if ([UserModel currentUser].birthday == nil) {
        cell.detailTextLabel.text = @"未设置";
      }
    }
    if (indexPath.row == 3) {
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      cell.textLabel.text = @"签名";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [UserModel currentUser].selfDescription];
      [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
      cell.detailTextLabel.numberOfLines = 2;
    }
  }
  if (indexPath.section == 1) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"密码";
    cell.detailTextLabel.text = @"修改密码";
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //设置性别
  if (indexPath.section == 0 && indexPath.row == 1) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"性别" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *male = [UIAlertAction actionWithTitle:@"男♂" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      UserInfoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
      cell.detailTextLabel.text = @"男♂";
      [[UserModel currentUser] setObject:@(GenderMale) forKey:@"gender"];
      [[UserModel currentUser] save];
    }];
    UIAlertAction *famale = [UIAlertAction actionWithTitle:@"女♀" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      UserInfoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
      cell.detailTextLabel.text = @"女♀";
      [[UserModel currentUser] setObject:@(GenderFamale) forKey:@"gender"];
      [[UserModel currentUser] save];
    }];
    UIAlertAction *unknown = [UIAlertAction actionWithTitle:@"保密" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      UserInfoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
      cell.detailTextLabel.text = @"保密";
      [[UserModel currentUser] setObject:@(GenderUnkonwn) forKey:@"gender"];
      [[UserModel currentUser] save];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:male];
    [alert addAction:famale];
    [alert addAction:unknown];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    //进入后台是选择关闭alert
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
  }
  //设置生日
  if (indexPath.section == 0 && indexPath.row == 2) {
    //退出的手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeCancle:)];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;

    //暗色的背景
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
    _backView.backgroundColor = [UIColor blackColor];
    _backView.alpha = 0.2;
    [_backView addGestureRecognizer:tap];
    
    //白色的背景选择框
    _whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 280)];
    _whiteView.backgroundColor = [UIColor whiteColor];
    
    //标题，确定与取消
    UIButton *ok = [UIButton buttonWithType:UIButtonTypeSystem];
    ok.frame = CGRectMake(self.view.frame.size.width-50, 0, 50, 30);
    [ok setTitle:@"确定" forState:UIControlStateNormal];
    [ok setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1] forState:UIControlStateNormal];
    ok.titleLabel.font = [UIFont systemFontOfSize:17];
    ok.titleLabel.textAlignment = NSTextAlignmentLeft;
    [ok addTarget:self action:@selector(makeOk:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    cancel.frame = CGRectMake(0, 0, 50, 30);
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1] forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont systemFontOfSize:17];
    cancel.titleLabel.textAlignment = NSTextAlignmentRight;
    [cancel addTarget:self action:@selector(makeCancle:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *title = [UIButton buttonWithType:UIButtonTypeCustom];
    title.frame = CGRectMake(50, 0, self.view.frame.size.width-100, 30);
    [title setTitle:@"生日" forState:UIControlStateNormal];
    [title setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    title.titleLabel.font = [UIFont systemFontOfSize:17];
    title.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    //时间选择器
    _picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(40, 0, self.view.frame.size.width-80, 280)];
    _picker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"];
    _picker.maximumDate = [NSDate date];
    _picker.date = [NSDate date];
    _picker.datePickerMode = UIDatePickerModeDate;
    [_whiteView addSubview:_picker];
    [_whiteView addSubview:title];
    [_whiteView addSubview:ok];
    [_whiteView addSubview:cancel];
    
    [self.view addSubview:_backView];
    [self.view addSubview:_whiteView];
    
    [UIView animateWithDuration:0.2 animations:^{
      _whiteView.frame = CGRectMake(0, self.view.frame.size.height-280, self.view.frame.size.width, 280);
    }];
  }
  //设置签名
  if (indexPath.section == 0 && indexPath.row == 3) {
    UserInfoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    DescriptionViewController *descriptionViewController = [DescriptionViewController new];
    descriptionViewController.signature = cell.detailTextLabel.text;
    [self.navigationController pushViewController:descriptionViewController animated:YES];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
