//
//  SelectGroupMemberVC.m
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/8/1.
//

#import "SelectGroupMemberVC.h"
#import "SelectGroupMemberCell.h"

@interface SelectGroupMemberVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *memberArray;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@end

@implementation SelectGroupMemberVC

- (NSMutableArray *)memberArray {
    if (!_memberArray) {
        _memberArray = [NSMutableArray array];
    }
    return _memberArray;
}

- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择成员";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage)];
    self.navigationItem.rightBarButtonItem = item;
    NSDictionary *dict = @{@"groupId":self.groupId};
    __weak typeof(self)weakSelf = self;
    [NetWorkHandler startRequestMethod:POST parameters:dict url:URL_QueryGroupMember success:^(id  _Nonnull responseObject) {
        NSArray *array = [responseObject objectForKey:@"users"];
        if (array && array.count > 0) {
            weakSelf.memberArray = [array mutableCopy];
            [weakSelf.memberArray insertObject:@{@"id":Mentioned_All} atIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取群组成员失败 %@", error.localizedDescription]];
    }];
}

- (void)sendMessage {
    if (self.selectedArray.count > 0) {
        if (self.sendMessageBlock) {
            self.sendMessageBlock(self.selectedArray);
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:@"至少选择一个成员"];
    }
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"SelectGroupMemberCell";
    SelectGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[SelectGroupMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSDictionary *dict = [self.memberArray objectAtIndex:indexPath.row];
    NSString *userId = [NSString stringWithFormat:@"%@", dict[@"id"]];
    if (indexPath.row == 0) {
        cell.userIdLabel.text = @"所有人";
    } else {
        cell.userIdLabel.text = userId;
    }
    if ([self.selectedArray containsObject:Mentioned_All]) {
        if (indexPath.row == 0) {
            cell.userInteractionEnabled = YES;
            cell.selectImageView.image = [UIImage imageNamed:@"selected"];
        } else {
            cell.userInteractionEnabled = NO;
            cell.selectImageView.image = [UIImage imageNamed:@"disabled"];
        }
    } else {
        if ([self.type isEqualToString:@"directional"] && indexPath.row == 0) {
            cell.userInteractionEnabled = NO;
            cell.selectImageView.image = [UIImage imageNamed:@"disabled"];
        } else if ([userId isEqualToString:[AppGlobalConfig shareInstance].userId]) {
            cell.userInteractionEnabled = NO;
            cell.selectImageView.image = [UIImage imageNamed:@"disabled"];
        } else {
            cell.userInteractionEnabled = YES;
            if ([self.selectedArray containsObject:userId]) {
                cell.selectImageView.image = [UIImage imageNamed:@"selected"];
            } else {
                cell.selectImageView.image = [UIImage imageNamed:@"unselected"];
            }
        }
    }
   
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [self.memberArray objectAtIndex:indexPath.row];
    NSString *userid = dict[@"id"];
    if (userid && userid.length > 0) {
        if ([self.selectedArray containsObject:userid]) {
            [self.selectedArray removeObject:userid];
        } else {
            if (indexPath.row == 0) {
                [self.selectedArray removeAllObjects];
            }
            [self.selectedArray addObject:userid];
            
        }
        [tableView reloadData];
    }
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
