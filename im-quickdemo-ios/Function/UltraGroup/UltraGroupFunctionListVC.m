//
//  UltraGroupFunctionListVC.m
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/7/12.
//

#import "UltraGroupFunctionListVC.h"
#import "TextViewCell.h"

@interface UltraGroupFunctionListVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *uidArray;
@end

@implementation UltraGroupFunctionListVC

- (NSMutableArray *)uidArray {
    if (!_uidArray) {
        _uidArray = [NSMutableArray array];
    }
    return _uidArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"超级群";
    self.dataSource = [@[
        @"创建超级群（Server API）",
        @"创建频道（Server API）",
        @"加入超级群（Server API）",
        @"获取本地频道列表",
        @"发送超级群消息",
        @"多端同步消息阅读状态（清除未读数）",
        @"升序获取历史消息",
        @"降序获取历史消息"
    ] mutableCopy];
    
    self.channelIdTextField.text = [AppGlobalConfig shareInstance].channelId;
    self.ultraGroupIdTextField.text = [AppGlobalConfig shareInstance].ultraGroupId;
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
    if (self.ultraGroupIdTextField.text.length > 0) {
        [AppGlobalConfig shareInstance].ultraGroupId = self.ultraGroupIdTextField.text;
    }
    if (self.channelIdTextField.text.length > 0) {
        [AppGlobalConfig shareInstance].channelId = self.channelIdTextField.text;
    }
    switch (indexPath.row) {
        case 0:
            // 创建超级群（Server API）
            [self createUltraGroup];
            break;
        case 1:
            // 创建频道（Server API）
            [self createChannel];
            break;
        case 2:
            // 加入超级群（Server API）
            [self joinUltraGroup];
            break;
        case 3:
            // 获取本地频道列表
            [self getConversationListForAllChannel];
            break;
        case 4:
            // 发送超级群消息
            [self sendUltraGroupMessage];
            break;
        case 5:
            // 多端同步消息阅读状态（清除未读数）
            [self syncUltraGroupReadStatus];
            break;
        case 6:
            // 升序获取历史消息
            [self.uidArray removeAllObjects];
            [self getMessagesByAscOrder:1659089124163 - 1];
            break;
        case 7:
            // 降序获取历史消息
            [self.uidArray removeAllObjects];
            [self getMessagesByDescOrder:0];
            break;
        default:
            break;
    }
}

// 创建超级群（Server API）
- (void)createUltraGroup {
    
    if(self.ultraGroupIdTextField.text.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入超级群ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    NSString * groupID = self.ultraGroupIdTextField.text;
    //超级群
    NSDictionary *dict = @{@"userId":[AppGlobalConfig shareInstance].userId, @"groupId":groupID, @"groupName":[NSString stringWithFormat:@"超级群%@", groupID]};
    [NetWorkHandler startRequestMethod:POST parameters:dict url:URL_CreateUltraGroup success:^(id  _Nonnull responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"创建超级群成功"];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"创建超级群失败 %@", error.localizedDescription]];
    }];
}

// 创建频道（Server API）
- (void)createChannel {
    
    if(self.ultraGroupIdTextField.text.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入超级群ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    if(self.channelIdTextField.text.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入频道ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    NSString * groupID = self.ultraGroupIdTextField.text;
    NSString * channelID = self.channelIdTextField.text;
    //超级群
    NSDictionary *dict = @{@"userId":[AppGlobalConfig shareInstance].userId, @"groupId":groupID, @"busChannel":channelID,@"type":@"0"};
    [NetWorkHandler startRequestMethod:POST parameters:dict url:URL_CreateUltraGroupChannelToken success:^(id  _Nonnull responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"创建频道成功"];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"创建频道失败 %@", error.localizedDescription]];
    }];
}

// 加入超级群（Server API）
- (void)joinUltraGroup {
    //超级群
    if(self.ultraGroupIdTextField.text.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入超级群ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    NSString * groupID = self.ultraGroupIdTextField.text;
    NSDictionary *dict = @{@"userId":[AppGlobalConfig shareInstance].userId, @"groupId":groupID};
    [NetWorkHandler startRequestMethod:POST parameters:dict url:URL_JoinUltraGroup success:^(id  _Nonnull responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"加入超级群成功"];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"加入超级群失败 %@", error.localizedDescription]];
    }];
}

// 获取本地频道列表
- (void)getConversationListForAllChannel {
    //超级群
    if(self.ultraGroupIdTextField.text.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入超级群ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    NSString * groupID = self.ultraGroupIdTextField.text;
    NSArray<RCConversation *> * list = [[RCChannelClient sharedChannelManager] getConversationListForAllChannel:ConversationType_ULTRAGROUP targetId:groupID];
    
    NSLog(@"本地频道列表 = %@",list);
}

// 发送超级群消息
- (void)sendUltraGroupMessage {
    if(self.ultraGroupIdTextField.text.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入超级群ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    if(self.channelIdTextField.text.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入频道ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    NSString * groupID = self.ultraGroupIdTextField.text;
    NSString * channelID = self.channelIdTextField.text;
    
    RCTextMessage * message = [RCTextMessage messageWithContent:@"我是超级群文本消息"];
    
    [[RCChannelClient sharedChannelManager] sendMessage:ConversationType_ULTRAGROUP targetId:groupID channelId:channelID content:message pushContent:nil pushData:nil success:^(long messageId) {
        [SVProgressHUD showSuccessWithStatus:@"发送超级群消息成功"];
    } error:^(RCErrorCode nErrorCode, long messageId) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"发送超级群消息失败 %ld", (long)nErrorCode]];
    }];
}

// 多端同步消息阅读状态（清除未读数）
- (void)syncUltraGroupReadStatus {
    if(self.ultraGroupIdTextField.text.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入超级群ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    if(self.channelIdTextField.text.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入频道ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    NSString * groupID = self.ultraGroupIdTextField.text;
    NSString * channelID = self.channelIdTextField.text;
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970]*1000;
    [[RCChannelClient sharedChannelManager] syncUltraGroupReadStatus:groupID channelId:channelID time:currentTimestamp success:^{
        [SVProgressHUD showSuccessWithStatus:@"同步阅读时间成功"];
    } error:^(RCErrorCode errorCode) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"同步阅读时间失败：%@", @(errorCode)]];
    }];
}


// 升序获取历史消息
- (void)getMessagesByAscOrder:(long long)time {
    NSString * groupID = self.ultraGroupIdTextField.text;
    NSString * channelID = self.channelIdTextField.text;
    if(groupID.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入超级群ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    if(channelID.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入频道ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    
    RCHistoryMessageOption *option = [[RCHistoryMessageOption alloc] init];
    option.count = 20;
    option.order = RCHistoryMessageOrderAsc;
    option.recordTime = time;
    NSLog(@"Asc 传入的时间戳 %lld", option.recordTime);
    __weak typeof(self)weakSelf = self;
    [[RCChannelClient sharedChannelManager] getMessages:ConversationType_ULTRAGROUP targetId:groupID channelId:channelID option:option complete:^(NSArray *messages, long long timestamp, BOOL isRemaining, RCErrorCode code) {
        for (RCMessage *message in messages) {
            [weakSelf.uidArray addObject:message.messageUId];
            if ([message.objectName isEqualToString:@"RC:TxtMsg"]) {
                RCTextMessage *msg = (RCTextMessage *)message.content;
                NSLog(@"Asc objectName:%@, 消息内容：%@, messageUid:%@, 时间戳 %lld",message.objectName, msg.content, message.messageUId, message.sentTime);
            } else {
                NSLog(@"Asc objectName:%@, messageUid:%@, 时间戳 %lld",message.objectName, message.messageUId, message.sentTime);
            }
        }
        NSLog(@"Asc 返回的时间戳 %lld isRemaining: %d", timestamp, isRemaining);
        if (isRemaining) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf getMessagesByAscOrder:timestamp];
            });
        }
    } error:^(RCErrorCode status) {
        NSLog(@"Asc 不断档消息拉取错误，errorcode = %ld", status);
    }];
    
}

// 降序获取历史消息
- (void)getMessagesByDescOrder:(long long)time {
    NSString * groupID = self.ultraGroupIdTextField.text;
    NSString * channelID = self.channelIdTextField.text;
    if(groupID.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入超级群ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    if(channelID.length <= 0){
        [RCAlertView showAlertController:@"标题" message:@"请输入频道ID" cancelTitle:@"确定" inViewController:self];
        return;
    }
    
    RCHistoryMessageOption *option = [[RCHistoryMessageOption alloc] init];
    option.count = 20;
    option.order = RCHistoryMessageOrderDesc;
    option.recordTime = time;
    NSLog(@"Desc 传入的时间戳 %lld", option.recordTime);
    __weak typeof(self)weakSelf = self;
    [[RCChannelClient sharedChannelManager] getMessages:ConversationType_ULTRAGROUP targetId:groupID channelId:channelID option:option complete:^(NSArray *messages, long long timestamp, BOOL isRemaining, RCErrorCode code) {
        for (RCMessage *message in messages) {
            [weakSelf.uidArray addObject:message.messageUId];
            if ([message.objectName isEqualToString:@"RC:TxtMsg"]) {
                RCTextMessage *msg = (RCTextMessage *)message.content;
                NSLog(@"Desc objectName:%@, 消息内容：%@, messageUid:%@, 时间戳 %lld",message.objectName, msg.content, message.messageUId, message.sentTime);
            } else {
                NSLog(@"Desc objectName:%@, messageUid:%@, 时间戳 %lld",message.objectName, message.messageUId, message.sentTime);
            }
        }
        NSLog(@"Desc 返回的时间戳 %lld isRemaining: %d", timestamp, isRemaining);
        if (isRemaining) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf getMessagesByDescOrder:timestamp];
            });
        }

    } error:^(RCErrorCode status) {
        NSLog(@"Desc 不断档消息拉取错误，errorcode = %ld", status);
    }];
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
