//
//  ChatRoomFunctionListVC.m
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/7/12.
//

#import "ChatRoomFunctionListVC.h"
#import "TextViewCell.h"

@interface ChatRoomFunctionListVC ()<UITableViewDelegate, UITableViewDataSource,RCChatRoomKVStatusChangeDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ChatRoomFunctionListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"聊天室";
    self.dataSource = [@[
        @"加入聊天室",
        @"退出聊天室",
        @"获取聊天室历史消息",
        @"设置kv",
        @"获取kv",
        @"删除kv",
        @"发聊天室消息"
    ] mutableCopy];
        
    [[RCChatRoomClient sharedChatRoomClient] addChatRoomKVStatusChangeDelegate:self];
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
    
    if(self.roomIdTextField.text.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入聊天室ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    NSString * roomId = self.roomIdTextField.text;
    
    switch (indexPath.row) {
        case 0:
            // 加入聊天室
            [self joinChatRoom:roomId];
            break;
        case 1:
            // 退出聊天室
            [self quitChatRoom:roomId];
            break;
        case 2:
            // 获取聊天室历史消息
            [self getMessage:roomId];
            break;
        case 3:
            // 设置kv
            [self setChatRoomEntry:roomId];
            break;
        case 4:
            // 获取kv
            [self getAllChatRoomEntries:roomId];
            break;
        case 5:
            // 删除kv
            [self removeChatRoomEntry:roomId];
            break;
        case 6:
            // 发聊天室消息
            [self sendChatRoomMessage:roomId];
            break;
        default:
            break;
    }
}

// 加入聊天室
- (void)joinChatRoom:(NSString *)roomId {
    
    [[RCIMClient sharedRCIMClient] joinChatRoom:roomId messageCount:10 success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"加入聊天室成功"];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"加入聊天失败 code: %ld",(long)status]];
        });
        
    }];
}
// 退出聊天室
- (void)quitChatRoom:(NSString *)roomId {
    
    [[RCIMClient sharedRCIMClient] quitChatRoom:roomId success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"退出聊天室成功"];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"退出聊天失败 code: %ld",(long)status]];
        });
    }];
}
// 获取聊天室历史消息
- (void)getMessage:(NSString *)roomId {
    
    [[RCIMClient sharedRCIMClient] getRemoteChatroomHistoryMessages:roomId recordTime:0 count:10 order:RC_Timestamp_Desc success:^(NSArray<RCMessage *> * _Nonnull messages, long long syncTime) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"获取聊天室历史"];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取聊天室历史失败 code: %ld",(long)status]];
        });
    }];
}
// 设置kv
- (void)setChatRoomEntry:(NSString *)roomId {
    
    [[RCIMClient sharedRCIMClient] setChatRoomEntry:roomId key:@"gift" value:@"1" sendNotification:YES autoDelete:YES notificationExtra:@"RC:chrmKVAAAA" success:^{
        
        NSString *targetString =
        [NSString stringWithFormat:@"设置 kv 成功：\n"
         @"key:%@，value:%@，extra:%@，\n"
         @"是否发送通知:%d，退出时是否删除:%d",
         @"gift", @"1", @"RC:chrmKVAAAA", YES, YES];
        NSLog(@"%@",targetString);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"设置KV成功"];
        });
    } error:^(RCErrorCode nErrorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"设置KV失败 code: %ld",(long)nErrorCode]];
        });
    }];
    
}
// 获取kv
- (void)getAllChatRoomEntries:(NSString *)roomId{
    [[RCIMClient sharedRCIMClient] getAllChatRoomEntries:roomId success:^(NSDictionary<NSString *,NSString *> * _Nonnull entry) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"获取KV成功"];
        });
        NSLog(@"获取 kv 成功：%@", entry);
    } error:^(RCErrorCode nErrorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取KV失败 code: %ld",(long)nErrorCode]];
        });
    }];
}
// 删除kv
- (void)removeChatRoomEntry:(NSString *)roomId{
    
    [[RCIMClient sharedRCIMClient] removeChatRoomEntry:roomId key:@"gift" sendNotification:YES notificationExtra:@"RC:chrmKVAAAA" success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"删除KV成功"];
            NSString *targetString = @"删除kv 成功";
            NSLog(@"%@",targetString);
        });
    } error:^(RCErrorCode nErrorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"删除KV失败 code: %ld",(long)nErrorCode]];
        });
    }];
}

// 发送聊天室消息
- (void)sendChatRoomMessage:(NSString *)roomId{
    
    RCTextMessage * message = [RCTextMessage messageWithContent:@"123"];
    
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_CHATROOM targetId:roomId content:message pushContent:nil pushData:nil success:^(long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"发聊天室消息成功"];
        });
    } error:^(RCErrorCode nErrorCode, long messageId) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"发聊天室消息失败 code: %ld",(long)nErrorCode]];
        });
    }];
}

#pragma mark - 聊天室kv回调
/**
 IMLib 刚加入聊天室时 KV 同步完成的回调
 
 @param roomId 聊天室 Id
 */
- (void)chatRoomKVDidSync:(NSString *)roomId {
    
}

/**
 IMLib 聊天室 KV 变化的回调
 
 @param roomId 聊天室 Id
 @param entry KV 字典，如果刚进入聊天室时存在  KV，会通过此回调将所有 KV 返回，再次回调时为其他人设置或者修改 KV
 */
- (void)chatRoomKVDidUpdate:(NSString *)roomId entry:(NSDictionary<NSString *, NSString *> *)entry {
    
}

/**
 IMLib 聊天室 KV 被删除的回调
 
 @param roomId 聊天室 Id
 @param entry KV 字典
 */
- (void)chatRoomKVDidRemove:(NSString *)roomId entry:(NSDictionary<NSString *, NSString *> *)entry {
    
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
