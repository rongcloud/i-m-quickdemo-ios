//
//  GroupFunctionListVC.m
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/7/12.
//

#import "GroupFunctionListVC.h"
#import "TextViewCell.h"
#import "SelectGroupMemberVC.h"

@interface GroupFunctionListVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation GroupFunctionListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"群组";
    self.dataSource = [@[
        @"创建群组（server API）",
        @"加入群组（server API）",
        @"退出群组（server API）",
        @"发送 @ 消息",
        @"发送群定向消息"
    ] mutableCopy];
    
    self.groupIdTextField.text = [AppGlobalConfig shareInstance].groupId;
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"TextViewCell";
    TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[TextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.txtName.text = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.groupIdTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入群组id"];
        return;
    }
    
    if (![self.groupIdTextField.text isEqualToString:[AppGlobalConfig shareInstance].groupId]) {
        [[AppGlobalConfig shareInstance] setGroupId:self.groupIdTextField.text];
    }
    switch (indexPath.row) {
        case 0:
        {
            // 创建群组（server API）
            [self createGroup];
            break;
        }
        case 1:
        {
            // 加入群组（server API）
            [self joinGroup];
            break;
        }
        case 2:
        {
            // 退出群组（server API）
            [self quitGroup];
            break;
        }
        case 3:
            // 发送 @ 消息
            [self sendMentionedMessage];
            break;
        case 4:
            // 发送群定向消息
            [self sendDirectionalMessage];
            break;
        default:
            break;
    }
}

// 创建群组（server API）
- (void)createGroup {
    NSDictionary *dict = @{@"userId":[AppGlobalConfig shareInstance].userId, @"groupId":self.groupIdTextField.text, @"groupName":[NSString stringWithFormat:@"群组%@", self.groupIdTextField.text]};
    [NetWorkHandler startRequestMethod:POST parameters:dict url:URL_CreateGroup success:^(id  _Nonnull responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"创建群组成功"];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"创建群组失败 %@", error.localizedDescription]];
    }];
}

// 加入群组（server API）
- (void)joinGroup {
    NSDictionary *dict = @{@"userId":[AppGlobalConfig shareInstance].userId, @"groupId":self.groupIdTextField.text};
    [NetWorkHandler startRequestMethod:POST parameters:dict url:URL_JoinGroup success:^(id  _Nonnull responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"加入群组成功"];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"加入群组失败 %@", error.localizedDescription]];
    }];
}

// 退出群组（server API）
- (void)quitGroup {
    NSDictionary *dict = @{@"userId":[AppGlobalConfig shareInstance].userId, @"groupId":self.groupIdTextField.text};
    [NetWorkHandler startRequestMethod:POST parameters:dict url:URL_QuitGroup success:^(id  _Nonnull responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"退出群组成功"];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"退出群组失败 %@", error.localizedDescription]];
    }];
}

// 发送 @ 消息
- (void)sendMentionedMessage {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Group" bundle:nil];
    SelectGroupMemberVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"SelectGroupMemberVC"];
    vc.type = @"mentioned";
    vc.groupId = self.groupIdTextField.text;
    vc.sendMessageBlock = ^(NSMutableArray *selectArary) {
        RCTextMessage *textMessage = [[RCTextMessage alloc] init];
        NSMutableString *text = [[NSMutableString alloc] initWithString:@"测试 @ 消息"];
        RCMentionedInfo *info = [[RCMentionedInfo alloc] init];
        if ([selectArary containsObject:Mentioned_All]) {
            [text appendString:@"@所有人"];
            info.type = RC_Mentioned_All;
        } else {
            for (NSString *userid in selectArary) {
                [text appendString:[NSString stringWithFormat:@"@用户%@ ", userid]];
            }
            info.type = RC_Mentioned_Users;
            info.userIdList = selectArary;
        }
        textMessage.content = text;
        textMessage.mentionedInfo = info;
        [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP targetId:self.groupIdTextField.text content:textMessage pushContent:nil pushData:nil success:^(long messageId) {
            [SVProgressHUD showSuccessWithStatus:@"@消息发送成功"];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"@消息发送失败 %ld",nErrorCode]];
        }];
        
    };
    [self.navigationController pushViewController:vc animated:YES];
}

// 发送群定向消息
- (void)sendDirectionalMessage {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Group" bundle:nil];
    SelectGroupMemberVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"SelectGroupMemberVC"];
    vc.type = @"directional";
    vc.groupId = self.groupIdTextField.text;
    vc.sendMessageBlock = ^(NSMutableArray *selectArary) {
        RCTextMessage *message = [[RCTextMessage alloc] init];
        NSMutableString *text = [[NSMutableString alloc] initWithString:@"测试定向消息，能收到消息的用户userId："];
        [text appendString:[selectArary componentsJoinedByString:@"、"]];
        message.content = text;
        [[RCIM sharedRCIM] sendDirectionalMessage:ConversationType_GROUP targetId:self.groupIdTextField.text toUserIdList:selectArary content:message pushContent:nil pushData:nil success:^(long messageId) {
            [SVProgressHUD showSuccessWithStatus:@"定向消息发送成功"];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"定向消息发送失败 %ld",nErrorCode]];
        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
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
